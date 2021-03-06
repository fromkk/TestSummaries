import AppKit

/// show help
func printHelp() {
    let help: String
    #if os(macOS)
    help = """
    Usage: test-summaries [--resultDirectory <resultDirectory>] | [--bundlePath <bundlePath>] --outputPath <outputPath> --outputType <outputType> [--imageScale <imageScale>]
    
    Options:
    --resultDirectory     set the directory path that has multiple test results
    --bundlePath          set the bundle path for single test result
    --outputPath          set the path for output the generated HTML file
    --outputType          set output type [HTML, PNG]
    --imageScale          set image scale(1|2|3)
    --backgroundColor     set background color(RGB) e.g. #FFFFFF
    --textColor           set text color(RGB) e.g. #000000
    """
    #else
    help = """
Usage: test-summaries [--resultDirectory <resultDirectory>] | [--bundlePath <bundlePath>] --outputPath <outputPath>

Options:
    --resultDirectory     set the directory path that has multiple test results
    --bundlePath          set the bundle path for single test result
    --outputPath          set the path for output the generated HTML file
"""
    #endif
    print(help)
}

class Main {
    let arguments: [String: String]
    let outputPath: String
    let outputType: OutputType
    let scale: Int
    let backgroundColor: String
    let textColor: String
    init(arguments: [String: String]) {
        self.arguments = arguments
        
        guard let outputPath: String = arguments["outputPath"] else {
            printHelp()
            exit(1)
        }
        self.outputPath = outputPath
        
        let outputType = arguments["outputType"] ?? "HTML"
        self.outputType = OutputType(rawValue: outputType.uppercased()) ?? .html
        
        if let scale = arguments["imageScale"] {
            self.scale = Int(scale) ?? 1
        } else {
            self.scale = 1
        }
        
        if
            let backgroundColor = arguments["backgroundColor"],
            !backgroundColor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            NSColor.isValid(rgbColor: backgroundColor) {
            self.backgroundColor = backgroundColor
        } else {
            self.backgroundColor = "#FFFFFF"
        }
        
        if
            let textColor = arguments["textColor"],
            !textColor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            NSColor.isValid(rgbColor: textColor) {
            self.textColor = textColor
        } else {
            self.textColor = "#333333"
        }
    }
    
    func run() {
        setUp()
        
        if let resultDirectory: String = arguments["resultDirectory"] {
            performWith(directoryPath: resultDirectory)
        } else if let bundlePath: String = arguments["bundlePath"] {
            performWith(bundlePath: bundlePath)
        } else {
            printHelp()
            exit(0)
        }
    }
    
    func setUp() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: outputPath) {
            fileManager.createFile(atPath: outputPath, contents: nil, attributes: nil)
        }
        
        guard fileManager.isWritableFile(atPath: outputPath) else {
            print("\(outputPath) is't writable path")
            exit(1)
        }
    }
    
    /// support multiple bundles
    ///
    /// - Parameter directoryPath: String
    func performWith(directoryPath: String) {
        guard Documents.isDirectory(path: directoryPath) else {
            print("\(directoryPath) is not directory")
            exit(1)
        }
        
        let allDirectories = Documents.directories(in: directoryPath).map { directory -> String in
            let url = URL(fileURLWithPath: directory)
            return url.path
        }
        
        let testSummaries = allDirectories.compactMap { (bundlePath) -> TestSummaries? in
            do {
                return try loadTestSummary(with: bundlePath)
            } catch {
                print("load TestSummaries.plist failed with error", error)
                exit(1)
            }
        }
        
        render(testSummaries: testSummaries, directories: allDirectories)
    }
    
    /// support single bundle
    ///
    /// - Parameter bundlePath: String
    func performWith(bundlePath: String) {
        let directory = URL(fileURLWithPath: bundlePath).path
        guard let testSummary = try? loadTestSummary(with: directory) else {
            print("TestSummaries.plist load failed")
            exit(1)
        }
        
        render(testSummaries: [testSummary], directories: [directory])
    }
    
    /// rendering with test summaries and directories
    ///
    /// - Parameters:
    ///   - testSummaries: [TestSummaries]
    ///   - directories: [String]
    private func render(testSummaries: [TestSummaries], directories: [String]) {
//        let progressSpinner = createProgressSpinner(forStream: stdoutStream, header: " Progressing...", isShowStopped: false, spinner: Spinner(kind: .spin13))
//        progressSpinner.start()
        
        let absoluteOutputPath = URL(fileURLWithPath: outputPath).path
        let render = outputType.render(with: testSummaries, and: directories, scale: scale, backgroundColor: backgroundColor, textColor: textColor)
        do {
            try render?.writeTo(path: absoluteOutputPath)
        } catch {
            print("write to \(outputPath) failed")
            exit(1)
        }
        
//        progressSpinner.stop()
        exit(0)
    }
    
    /// load TestSummaries.plist from path
    ///
    /// - Parameter bundlePath: String
    /// - Returns: TestSummaries
    /// - Throws: Error
    func loadTestSummary(with bundlePath: String) throws -> TestSummaries {
        let testSummariesURL = URL(fileURLWithPath: bundlePath).appendingPathComponent("TestSummaries.plist")
        
        let isTestSummariesExists: Bool = {
            let fileManager = FileManager.default
            return fileManager.fileExists(atPath: testSummariesURL.path)
        }()
        
        guard isTestSummariesExists else {
            print("TestSummaries.plist not found in \(bundlePath)")
            exit(1)
        }
        
        let data = try Data(contentsOf: testSummariesURL)
        let plistDecoder = PropertyListDecoder()
        return try plistDecoder.decode(TestSummaries.self, from: data)
    }
}

let arguments: [String: String] = Arguments(arguments: CommandLine.arguments).parse()
let main = Main(arguments: arguments)
main.run()

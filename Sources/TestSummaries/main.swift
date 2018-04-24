import Foundation

/// show help
func printHelp() {
    let help = """
Usage: TestSummaries [--resultDirectory <resultDirectory>] | [--bundlePath <bundlePath>] --outputPath <outputPath>

Options:
    --resultDirectory     set the directory path that has multiple test results
    --bundlePath          set the bundle path for single test result
    --outputPath          set the path for output the generated HTML file
"""
    print(help)
}

class Main {
    let arguments: [String: String]
    let outputPath: String
    init(arguments: [String: String]) {
        self.arguments = arguments
        
        guard let outputPath: String = arguments["outputPath"] else {
            printHelp()
            exit(1)
        }
        self.outputPath = outputPath
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
    
    func performWith(directoryPath: String) {
        // support multiple bundles
        
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
        
        let absoluteOutputPath = URL(fileURLWithPath: outputPath).path
        let render = HTMLRender(testSummaries: testSummaries, paths: allDirectories)
        do {
            try render.writeTo(path: absoluteOutputPath)
        } catch {
            print("write to \(outputPath) failed")
            exit(1)
        }
        
        print("done!")
        
        exit(0)
    }
    
    func performWith(bundlePath: String) {
        // support single bundle
        
        let directory = URL(fileURLWithPath: bundlePath).path
        guard let testSummary = try? loadTestSummary(with: directory) else {
            print("TestSummaries.plist load failed")
            exit(1)
        }
        
        let absoluteOutputPath = URL(fileURLWithPath: outputPath).path
        let render = HTMLRender(testSummaries: [testSummary], paths: [directory])
        do {
            try render.writeTo(path: absoluteOutputPath)
        } catch {
            print("write to \(outputPath) failed")
            exit(1)
        }
        
        print("done!")
        
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

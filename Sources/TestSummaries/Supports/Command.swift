//
//  Command.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/27.
//

import Foundation

/// execute shell command
class Command {
    private static let which: String = "/usr/bin/which"
    
    /// perform shell command
    ///
    /// - Parameters:
    ///   - command: String
    ///   - arguments: [String]?
    /// - Returns: String?
    static func run(_ command: String, arguments: [String]? = nil) -> String? {
        let path: String
        if command.hasPrefix("/") {
            path = command
        } else {
            // get fullpath from which
            guard let command = self.run(self.which, arguments: [command]) else {
                return nil
            }
            path = command
        }
        
        let process = Process()
        process.launchPath = path
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

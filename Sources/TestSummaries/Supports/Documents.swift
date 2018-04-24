//
//  Documents.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/24.
//

import Foundation

/// Support file paths control
public class Documents {
    private static let fileManager = FileManager.default
    
    private enum Constants {
        static let directorySeparator = "/"
    }
    
    /// find contents in directory
    ///
    /// - Parameter directory: String
    /// - Returns: contents: [String]
    public static func contents(in directory: String) -> [String] {
        return (try? fileManager.contentsOfDirectory(atPath: directory).filter({ (path) -> Bool in
            return path.prefix(1) != "."
        })) ?? []
    }
    
    /// convert to paths in directories
    ///
    /// - Parameter directory: [String]
    /// - Returns: [String]
    public static func paths(in directory: String) -> [String] {
        return contents(in: directory).map {
            return directory + Constants.directorySeparator + $0
        }
    }
    
    /// find files in directory
    ///
    /// - Parameter directory: String
    /// - Returns: [String]
    public static func files(in directory: String) -> [String] {
        return paths(in: directory).filter { (path) -> Bool in
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: path, isDirectory: &isDirectory) {
                return !isDirectory.boolValue
            } else {
                return false
            }
        }
    }
    
    /// check is directory for path
    ///
    /// - Parameter path: String
    /// - Returns: Bool
    public static func isDirectory(path: String) -> Bool {
        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
    
    /// find directories in directory
    ///
    /// - Parameter directory: String
    /// - Returns: directories: [String]
    public static func directories(in directory: String) -> [String] {
        return paths(in: directory).filter { (path) -> Bool in
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: path, isDirectory: &isDirectory) {
                return isDirectory.boolValue
            } else {
                return false
            }
        }
    }
    
    /// file all files in directory
    ///
    /// - Parameters:
    ///   - directory: String
    ///   - result: [String]
    /// - Returns: [String]
    private static func recursiveFiles(in directory: String, result: [String]) -> [String] {
        var result = result
        result += files(in: directory)
        directories(in: directory).forEach { (currentDirectory) in
            result = self.recursiveFiles(in: currentDirectory, result: result)
        }
        return result
    }
    
    /// all files in directory
    ///
    /// - Parameter directory: String
    /// - Returns: [String]
    public static func allFiles(in directory: String) -> [String] {
        return recursiveFiles(in: directory, result: [])
    }
    
    /// rename all files in directory
    ///
    /// - Parameters:
    ///   - directory: String
    ///   - base: String
    ///   - replace: String
    public static func renameAllFiles(in directory: String, base: String, replace: String) {
        allFiles(in: directory).forEach { (path) in
            let old = path
            let new = old.replacingOccurrences(of: base, with: replace)
            
            if self.fileManager.fileExists(atPath: new) {
                do {
                    try self.fileManager.removeItem(atPath: new)
                } catch {
                    debugPrint(#function, "remove \(new) failed", error)
                }
            }
        }
        
        allFiles(in: directory).forEach { (path) in
            let old = path
            let new = old.replacingOccurrences(of: base, with: replace)
            
            do {
                try self.fileManager.moveItem(atPath: old, toPath: new)
            } catch {
                debugPrint(#function, error)
            }
        }
    }
}

//
//  File.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/27.
//

import Foundation

// image info structure
struct ImageInfo {
    let path: String
    var width: Int?
    var height: Int?
    
    init?(path: String) {
        self.path = path
        
        if let size = ImageInfo.file(with: path) {
            // first file command
            self.width = size.width
            self.height = size.height
        } else if let size = ImageInfo.exiftool(with: path) {
            // perform exiftool command
            self.width = size.width
            self.height = size.height
        } else {
            return nil
        }
    }
    
    private static func file(with path: String) -> Size? {
        guard let file = Command.run("which", arguments: ["file"]) else {
            return nil
        }
        
        guard let result = Command.run(file, arguments: [path]) else {
            return nil
        }
        
        let elements = result.components(separatedBy: ",")
        return elements.compactMap({ (element) -> Size? in
            let element = element.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let regexp = try! NSRegularExpression(pattern: "^([0-9]+)\\s*x\\s*([0-9]+)$", options: [])
            let range = (element as NSString).range(of: element)
            let matches = regexp.matches(in: element, options: [], range: range)
            
            guard let match = matches.first else { return nil }
            
            let widthRange = match.range(at: 1)
            let heightRange = match.range(at: 2)
            
            let width = Int((element as NSString).substring(with: widthRange))!
            let height = Int((element as NSString).substring(with: heightRange))!
            
            return Size(width: width, height: height)
        }).first
    }
    
    private static func exiftool(with path: String) -> Size? {
        guard let exiftool = Command.run("which", arguments: ["exiftool"]) else {
            return nil
        }
        
        guard let result = Command.run(exiftool, arguments: [path]) else {
            return nil
        }
        
        var size = Size(width: 0, height: 0)
        
        // set width and height
        result.components(separatedBy: "\n").forEach { (line) in
            let keyValue = line.components(separatedBy: ":")
            guard let key = keyValue.first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), let value = keyValue.last?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                return
            }
            
            if key == "Image Width" {
                size.width = Int(value)!
            } else if key == "Image Height" {
                size.height = Int(value)!
            }
        }
        
        return size
    }
}

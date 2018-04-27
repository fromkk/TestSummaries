//
//  File.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/27.
//

import Foundation

struct Image {
    let path: String
    var width: Int32?
    var height: Int32?
    
    init?(path: String) {
        guard let exiftool = Command.run("which", arguments: ["exiftool"]) else {
            return nil
        }
        
        guard let result = Command.run(exiftool, arguments: [path]) else {
            return nil
        }
        
        self.path = path
        
        result.components(separatedBy: "\n").forEach { (line) in
            let keyValue = line.components(separatedBy: ":")
            guard let key = keyValue.first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), let value = keyValue.last?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                return
            }
            
            if key == "Image Width" {
                self.width = Int32(value)
            } else if key == "Image Height" {
                self.height = Int32(value)
            }
        }
    }
}

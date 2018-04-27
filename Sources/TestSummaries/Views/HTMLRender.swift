//
//  HTMLRender.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/24.
//

import Foundation

struct HTMLRender: TestSummariesRenderable {
    
    var testSummaries: [TestSummaries]
    
    var paths: [String]
    
    /// convert testSummaries to HTML
    ///
    /// - Returns: String
    func toHTML() -> String {
        var result: String = HTMLTemplates.html
        
        let attachments: [String] = zip(testSummaries, paths).map({ item -> String in
            let testSummary = item.0
            let path = item.1
            let fileName = path.components(separatedBy: "/").last ?? ""
            
            var template = HTMLTemplates.attachments
            template = template.replacingOccurrences(of: "${filename}", with: fileName)
            
            let attachments: [AttachmentWithParent] = testSummary.attachments
            
            let attachmentItems: [String] = attachments.map({ (attachment) -> String in
                var item = HTMLTemplates.attachmentItem
                
                item = item.replacingOccurrences(of: "${path}", with: path)
                item = item.replacingOccurrences(of: "${fileName}", with: attachment.attachment.fileName)
                item = item.replacingOccurrences(of: "${title}", with: attachment.parent.testIdentifier)
                
                return item
            })
            
            template = template.replacingOccurrences(of: "${attachmentItem}", with: attachmentItems.joined())
            return template
        })
        result = result.replacingOccurrences(of: "${attachments}", with: attachments.joined())
        return result
    }
    
    /// write HTML to path
    ///
    /// - Parameter path: String
    /// - Throws: Error
    func writeTo(path: String) throws {
        var html = toHTML()
        
        let directoryPath = path.components(separatedBy: "/").dropLast().joined(separator: "/")
        html = html.replacingOccurrences(of: directoryPath, with: ".")
        
        let data = html.data(using: .utf8)!
        try data.write(to: URL(fileURLWithPath: path))
    }
}

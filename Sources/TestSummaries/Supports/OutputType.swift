//
//  OutputType.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/26.
//

import AppKit

enum OutputType: String {
    case html = "HTML"
    case png = "PNG"
    
    func render(with testSummaries: [TestSummaries], and directories: [String], scale: Int, backgroundColor: String, textColor: String) -> TestSummariesRenderable? {
        switch self {
        case .html:
            return HTMLRender(testSummaries: testSummaries, paths: directories, backgroundColor: backgroundColor, textColor: textColor)
        case .png:
            guard let backgroundColor = NSColor(rgbColor: backgroundColor), let textColor = NSColor(rgbColor: textColor) else { return nil }
            
            return ImageRender(testSummaries: testSummaries, paths: directories, scale: scale, backgroundColor: backgroundColor, textColor: textColor)
        }
    }
}

//
//  OutputType.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/26.
//

import Foundation

enum OutputType: String {
    case html = "HTML"
    case png = "PNG"
    
    func render(with testSummaries: [TestSummaries], and directories: [String], scale: Int32) -> TestSummariesRenderable {
        switch self {
        case .html:
            return HTMLRender(testSummaries: testSummaries, paths: directories)
        case .png:
            return ImageRender(testSummaries: testSummaries, paths: directories, scale: scale)
        }
    }
}

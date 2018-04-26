//
//  OutputType.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/26.
//

import Foundation

enum OutputType: String {
    case html = "HTML"
    
    func render(with testSummaries: [TestSummaries], and directories: [String]) -> TestSummariesRenderable {
        switch self {
        case .html:
            return HTMLRender(testSummaries: testSummaries, paths: directories)
        }
    }
}

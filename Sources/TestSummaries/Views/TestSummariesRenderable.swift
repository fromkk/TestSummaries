//
//  TestSummariesRenderable.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/26.
//

import Foundation

protocol TestSummariesRenderable {
    var testSummaries: [TestSummaries] { get }
    
    var paths: [String] { get }
    
    func writeTo(path: String) throws
}

//
//  TestSummariesRenderable.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/26.
//

import Foundation

protocol TestSummariesRenderable {
    
    /// test summaries
    var testSummaries: [TestSummaries] { get }
    
    /// bundle directory paths
    var paths: [String] { get }
    
    /// write to path
    ///
    /// - Parameter path: String
    /// - Throws: Error
    func writeTo(path: String) throws
}

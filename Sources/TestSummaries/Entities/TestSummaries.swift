//
//  TestSummaries.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/24.
//

import Foundation

typealias AttachmentWithParent = (attachment: Attachment, parent: Test)

struct TestSummaries: Codable, Equatable {
    
    let formatVersion: String
    
    let testableSummaries: [TestableSummary]
    
    private enum CodingKeys: String, CodingKey {
        case formatVersion = "FormatVersion"
        case testableSummaries = "TestableSummaries"
    }
}

struct TestableSummary: Codable, Equatable {
    let diagnosticsDirectory: String
    let projectPath: String
    let targetName: String
    let testName: String
    let testObjectCLass: String
    let tests: [Test]
    
    private enum CodingKeys: String, CodingKey {
        case diagnosticsDirectory = "DiagnosticsDirectory"
        case projectPath = "ProjectPath"
        case targetName = "TargetName"
        case testName = "TestName"
        case testObjectCLass = "TestObjectClass"
        case tests = "Tests"
    }
    
}

struct Test: Codable, Equatable {
    let duration: TimeInterval
    let subTests: [Test]?
    let activitySummaries: [ActicitySummary]?
    let testIdentifier: String
    let testName: String
    let testObjectClass: String
    let testStatus: String?
    let testSummaryGUID: String?
    
    private enum CodingKeys: String, CodingKey {
        case duration = "Duration"
        case subTests = "Subtests"
        case activitySummaries = "ActivitySummaries"
        case testIdentifier = "TestIdentifier"
        case testName = "TestName"
        case testObjectClass = "TestObjectClass"
        case testStatus = "TestStatus"
        case testSummaryGUID = "TestSummaryGUID"
    }
    
    var attachments: [AttachmentWithParent] {
        var result: [AttachmentWithParent] = []
        
        if let subTests = subTests {
            subTests.forEach { (test) in
                result += test.attachments
            }
        } else if let activitySummaries = activitySummaries {
            activitySummaries.forEach({ (activitySummary) in
                result += (activitySummary.attachments ?? []).map { attachment in
                    return (attachment, self)
                }
            })
        }
        
        return result
    }
    
}

struct ActicitySummary: Codable, Equatable {
    let activityType: String
    let finishTimeInterval: TimeInterval
    let startTimeInterval: TimeInterval
    let subActivities: [ActicitySummary]?
    let title: String
    let uuid: String
    let attachments: [Attachment]?
    
    private enum CodingKeys: String, CodingKey {
        case activityType = "ActivityType"
        case attachments = "Attachments"
        case finishTimeInterval = "FinishTimeInterval"
        case startTimeInterval = "StartTimeInterval"
        case subActivities = "SubActivities"
        case title = "Title"
        case uuid = "UUID"
    }
}

struct Attachment: Codable, Equatable {
    let fileName: String
    let hasPayload: Bool
    let inActivityIdentifier: Int
    let lifeime: Int
    let name: String
    let timestamp: TimeInterval
    let uniformTypeIdentifier: String
    let userInfo: UserInfo?
    
    private enum CodingKeys: String, CodingKey {
        case fileName = "Filename"
        case hasPayload = "HasPayload"
        case inActivityIdentifier = "InActivityIdentifier"
        case lifeime = "Lifetime"
        case name = "Name"
        case timestamp = "Timestamp"
        case uniformTypeIdentifier = "UniformTypeIdentifier"
        case userInfo = "UserInfo"
    }
}

struct UserInfo: Codable, Equatable {
    let scale: Double
    
    private enum CodingKeys: String, CodingKey {
        case scale = "Scale"
    }
}


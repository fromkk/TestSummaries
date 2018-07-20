//
//  Coordinate.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/27.
//

import Foundation

struct Point {
    var x: Int
    var y: Int
}

extension Point {
    static var zero: Point { return Point(x: 0, y: 0) }
}

struct Size {
    var width: Int
    var height: Int
}

extension Size {
    static var zero: Size { return Size(width: 0, height: 0) }
}

struct Rect {
    var point: Point
    var size: Size
}

extension Rect {
    static var zero: Rect { return Rect(point: .zero, size: .zero) }
}

struct EdgeInsets {
    var top: Int
    var left: Int
    var bottom: Int
    var right: Int
}

extension EdgeInsets {
    static var zero: EdgeInsets { return EdgeInsets(top: 0, left: 0, bottom: 0, right: 0) }
}

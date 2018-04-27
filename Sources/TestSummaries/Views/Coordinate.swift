//
//  Coordinate.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/27.
//

import Foundation

struct Point {
    var x: Int32
    var y: Int32
}

extension Point {
    static var zero: Point { return Point(x: 0, y: 0) }
}

struct Size {
    var width: Int32
    var height: Int32
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
    var top: Int32
    var left: Int32
    var bottom: Int32
    var right: Int32
}

extension EdgeInsets {
    static var zero: EdgeInsets { return EdgeInsets(top: 0, left: 0, bottom: 0, right: 0) }
}

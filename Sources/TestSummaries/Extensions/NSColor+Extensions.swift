//
//  NSColor+Extensions.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/08/27.
//

import AppKit

extension NSColor {
    private static func regularExpression(with pattern: String) -> NSRegularExpression {
        return try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    }
    
    static func isValid(rgbColor: String) -> Bool {
        let range = (rgbColor as NSString).range(of: rgbColor)
        let regexp = regularExpression(with: "^#?[0-9a-f]{6}$")
        return 0 < regexp.numberOfMatches(in: rgbColor, options: [], range: range)
    }
    
    static func isValid(rgbaColor: String) -> Bool {
        let range = (rgbaColor as NSString).range(of: rgbaColor)
        let regexp = regularExpression(with: "^#?[0-9a-f]{8}$")
        return 0 < regexp.numberOfMatches(in: rgbaColor, options: [], range: range)
    }
    
    convenience init?(rgbColor: String) {
        guard NSColor.isValid(rgbColor: rgbColor) else { return nil }
        
        let color = rgbColor.replacingOccurrences(of: "#", with: "")
        var r: CGFloat?
        var g: CGFloat?
        var b: CGFloat?
        (0..<3).forEach { (i) in
            let code = color[color.index(color.startIndex, offsetBy: i * 2)..<color.index(color.startIndex, offsetBy: i * 2 + 2)]
            
            let hex = CGFloat(Int(code, radix: 16)!) / 255.0
            switch i {
            case 0:
                r = hex
            case 1:
                g = hex
            case 2:
                b = hex
            default:
                break
            }
        }
        
        guard let _r = r, let _g = g, let _b = b else {
            return nil
        }
        
        self.init(red: _r, green: _g, blue: _b, alpha: 1)
    }
    
    convenience init?(rgbaColor: String) {
        guard NSColor.isValid(rgbaColor: rgbaColor) else { return nil }
        
        let color = rgbaColor.replacingOccurrences(of: "#", with: "")
        var r: CGFloat?
        var g: CGFloat?
        var b: CGFloat?
        var a: CGFloat?
        (0..<4).forEach { (i) in
            let code = color[color.index(color.startIndex, offsetBy: i * 2)..<color.index(color.startIndex, offsetBy: i * 2 + 2)]
            let hex = CGFloat(Int(code, radix: 16)!) / 255.0
            
            switch i {
            case 0:
                r = hex
            case 1:
                g = hex
            case 2:
                b = hex
            case 3:
                a = hex
            default:
                break
            }
        }
        
        guard let _r = r, let _g = g, let _b = b, let _a = a else {
            return nil
        }
        
        self.init(red: _r, green: _g, blue: _b, alpha: _a)
    }
}

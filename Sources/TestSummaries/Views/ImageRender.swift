//
//  ImageRender.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/27.
//

import Foundation
import Cocoa
import CoreGraphics

enum ImageRenderError: Error {
    case createFailed
    case imageSaveFailed
}

class ImageRender: TestSummariesRenderable {
    
    /// canvas margin
    var edgeInsets: EdgeInsets = EdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    /// draw point
    private lazy var currentPoint: Point = Point(x: edgeInsets.left, y: edgeInsets.top)
    
    /// row space
    var space: Int = 20
    
    /// file name height
    var headerHeight: Int = 40
    
    /// cell size
    var imageCell: Size {
        return Size(width: 375 * scale, height: 600 * scale)
    }
    
    /// Image scale
    var scale: Int = 1
    
    /// height of test name
    var testNameHeight: Int = 32
    
    /// list of TestSummary
    var testSummaries: [TestSummaries]
    
    /// directory paths
    var paths: [String]
    
    /// image background color
    var backgroundColor: NSColor
    
    /// text color
    var textColor: NSColor
    
    init(testSummaries: [TestSummaries], paths: [String], scale: Int, backgroundColor: NSColor, textColor: NSColor) {
        self.testSummaries = testSummaries
        self.paths = paths
        self.scale = scale
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
    
    private func makeContext(with size: Size) -> CGContext? {
        let width: Int = size.width
        let height: Int = size.height
        let bitsPerComponent: Int = 8
        let bytesPerRow: Int = Int(4) * width
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        return CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
    }
    
    private func draw(string: String, at point: CGPoint, with size: CGFloat) {
        let font = NSFont.systemFont(ofSize: size)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        let canvasSize = self.canvasSize
        
        let textSize = (string as NSString).boundingRect(with: NSSize(width: canvasSize.width, height: canvasSize.height), options: [], attributes: attributes)
        
        let drawBounds = NSRect(origin: CGPoint(x: point.x, y: CGFloat(canvasSize.height) - point.y - textSize.height), size: textSize.size)
        
        (string as NSString).draw(in: drawBounds, withAttributes: attributes)
    }
    
    /// image write to path
    ///
    /// - Parameter path: Output path
    /// - Throws: Error
    func writeTo(path: String) throws {
        let canvasSize = self.canvasSize
        
        /// create new image
        guard let context = makeContext(with: canvasSize) else {
            throw ImageRenderError.createFailed
        }
        
        // fill background color
        context.setFillColor(backgroundColor.cgColor)
        context.fill(CGRect(origin: .zero, size: CGSize(width: CGFloat(canvasSize.width), height: CGFloat(canvasSize.height))))
        
        guard let imageRef = context.makeImage() else {
            throw ImageRenderError.createFailed
        }
        
        let image = NSImage(cgImage: imageRef, size: NSSize(width: canvasSize.width, height: canvasSize.height))
        image.lockFocus()
        
        zip(testSummaries, paths).forEach({ item in
            let testSummary = item.0
            let path = item.1
            let fileName = path.components(separatedBy: "/").last ?? ""
            
            // add fileName
            _ = draw(string: fileName, at: CGPoint(x: currentPoint.x, y: currentPoint.y), with: 24)
            
            // move to after header position
            currentPoint = Point(x: currentPoint.x, y: currentPoint.y + headerHeight)

            // attachments images
            let attachments: [AttachmentWithParent] = testSummary.attachments
            
            attachments.enumerated().forEach({ (current) in
                let index = current.offset
                let attachment = current.element
                
                // add title
                let title = attachment.parent.testIdentifier
                _ = draw(string: title, at: CGPoint(x: currentPoint.x, y: currentPoint.y), with: 16)
                
                // open attachment bundle
                let fullPath = String(format: "%@/Attachments/%@", path, attachment.attachment.fileName)
                
                // setup image pointer from extension
                guard let currentImage = NSImage(contentsOfFile: fullPath) else {
                    return
                }
                
                let width = currentImage.size.width
                let height = currentImage.size.height
                
                // calculate image size
                let widthAspect = Double(imageCell.width) / Double(width)
                let heightAspect = Double(imageCell.height) / Double(height)
                
                let newWidth: Int
                let newHeight: Int
                if widthAspect < heightAspect {
                    newWidth = imageCell.width
                    newHeight = Int(widthAspect * Double(height))
                } else {
                    newHeight = imageCell.height
                    newWidth = Int(heightAspect * Double(width))
                }
                
                // write image
                currentImage.draw(in: NSRect(x: currentPoint.x, y: canvasSize.height - (currentPoint.y + testNameHeight) - newHeight, width: newWidth, height: newHeight))
                
                if index == attachments.count - 1 {
                    // last
                    currentPoint = Point(x: edgeInsets.left, y: currentPoint.y + imageCell.height + testNameHeight + space)
                } else {
                    // other
                    currentPoint = Point(x: currentPoint.x + imageCell.width, y: currentPoint.y)
                }
            })
        })
        
        image.unlockFocus()
        
        // write image
        guard let _data = image.tiffRepresentation, let png = NSBitmapImageRep(data: _data) else {
            throw ImageRenderError.imageSaveFailed
        }
        
        guard let data = png.representation(using: .png, properties: [:]) else {
            throw ImageRenderError.imageSaveFailed
        }
        
        do {
            try data.write(to: URL(fileURLWithPath: path))
        } catch {
            throw ImageRenderError.imageSaveFailed
        }
    }
    
    /// calculate canvas size with attachments
    var canvasSize: Size {
        var size: Size = Size(width: edgeInsets.left + edgeInsets.right, height: edgeInsets.top + edgeInsets.bottom)
        
        let numberOfCols: Int = Int(testSummaries.map { testSummary -> Int in
            return Int(testSummary.attachments.count)
        }.max() ?? 0)
        size.width += numberOfCols * imageCell.width
        
        let numberOfRows: Int = Int(testSummaries.count)
        size.height += (numberOfRows * (imageCell.height + headerHeight + testNameHeight)) + (numberOfRows - 1) * space
        
        return size
    }
}

//
//  ImageRender.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/27.
//

#if os(Linux)
    import Glibc
    import Cgdlinux
#else
    import Darwin
    import Cgdmac
#endif

import Foundation

enum ImageRenderError: Error {
    case createFailed
}

class ImageRender: TestSummariesRenderable {
    
    /// canvas margin
    var edgeInsets: EdgeInsets = EdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    /// draw point
    private lazy var currentPoint: Point = Point(x: edgeInsets.left, y: edgeInsets.top)
    
    /// row space
    var space: Int32 = 20
    
    /// file name height
    var headerHeight: Int32 = 40
    
    /// cell size
    var imageCell: Size = Size(width: 375, height: 600)
    
    /// height of test name
    var testNameHeight: Int32 = 32
    
    /// list of TestSummary
    var testSummaries: [TestSummaries]
    
    /// directory paths
    var paths: [String]
    
    init(testSummaries: [TestSummaries], paths: [String]) {
        self.testSummaries = testSummaries
        self.paths = paths
    }
    
    /// image write to path
    ///
    /// - Parameter path: Output path
    /// - Throws: Error
    func writeTo(path: String) throws {
        let canvasSize = self.canvasSize
        
        /// create new image
        guard let image = gdImageCreateTrueColor(canvasSize.width, canvasSize.height) else {
            throw ImageRenderError.createFailed
        }
        
        /// colors
        let white = gdImageColorAllocate(image, 255, 255, 255)
        let black = gdImageColorAllocate(image, 0, 0, 0)
        
        // fill white color
        gdImageFilledRectangle(image, 0, 0, canvasSize.width, canvasSize.height, white)
        
        zip(testSummaries, paths).forEach({ item in
            let testSummary = item.0
            let path = item.1
            let fileName = path.components(separatedBy: "/").last ?? ""
            let cPtr = UnsafeMutablePointer<UInt8>(mutating: fileName)
            
            // add fileName
            gdImageString(image, gdFontGetGiant(), currentPoint.x, currentPoint.y, cPtr, black)
            
            // move to after header position
            currentPoint = Point(x: currentPoint.x, y: currentPoint.y + headerHeight)

            // attachments images
            let attachments: [AttachmentWithParent] = testSummary.attachments
            
            attachments.enumerated().forEach({ (current) in
                let index = current.offset
                let attachment = current.element
                
                // add title
                let title = UnsafeMutablePointer<UInt8>(mutating: attachment.parent.testIdentifier)
                gdImageString(image, gdFontGetSmall(), currentPoint.x, currentPoint.y, title, black)
                
                // open attachment bundle
                let fullPath = String(format: "%@/Attachments/%@", path, attachment.attachment.fileName)
                let file = fopen(fullPath, "rb")
                defer { fclose(file) }
                
                // setup image pointer from extension
                let currentImage: gdImagePtr
                let ext = attachment.attachment.fileName.components(separatedBy: ".").last?.lowercased() ?? "png"
                if ext == "png" {
                    currentImage = gdImageCreateFromPng(file)
                } else if ext == "jpg" {
                    currentImage = gdImageCreateFromJpeg(file)
                } else {
                    return
                }
                
                // get image size
                let imageInfo = ImageInfo(path: fullPath)
                guard let width = imageInfo?.width, let height = imageInfo?.height else { return }
                
                // calculate image size
                let widthAspect = Double(imageCell.width) / Double(width)
                let heightAspect = Double(imageCell.height) / Double(height)
                
                let newWidth: Int32
                let newHeight: Int32
                if widthAspect < heightAspect {
                    newWidth = imageCell.width
                    newHeight = Int32(widthAspect * Double(height))
                } else {
                    newHeight = imageCell.height
                    newWidth = Int32(heightAspect * Double(width))
                }
                
                // write image
                gdImageCopyResized(image, currentImage, currentPoint.x, currentPoint.y + testNameHeight, 0, 0, newWidth, newHeight, width, height)

                if index == attachments.count - 1 {
                    // last
                    currentPoint = Point(x: edgeInsets.left, y: currentPoint.y + imageCell.height + testNameHeight + space)
                } else {
                    // other
                    currentPoint = Point(x: currentPoint.x + imageCell.width, y: currentPoint.y)
                }
            })
        })
        
        // write image
        let outputFile = fopen(path, "wb")
        defer {
            fclose(outputFile)
            gdImageDestroy(image)
        }
        
        gdImagePng(image, outputFile)
    }
    
    /// calculate canvas size with attachments
    var canvasSize: Size {
        var size: Size = Size(width: edgeInsets.left + edgeInsets.right, height: edgeInsets.top + edgeInsets.bottom)
        
        let numberOfCols: Int32 = Int32(testSummaries.map { testSummary -> Int32 in
            return Int32(testSummary.attachments.count)
        }.max() ?? 0)
        size.width += numberOfCols * imageCell.width
        
        let numberOfRows: Int32 = Int32(testSummaries.count)
        size.height += (numberOfRows * (imageCell.height + headerHeight + testNameHeight)) + (numberOfRows - 1) * space
        
        return size
    }
}

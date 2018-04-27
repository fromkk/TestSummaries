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

class ImageRender: TestSummariesRenderable {
    
    var edgeInsets: EdgeInsets = EdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    lazy var currentPoint: Point = Point(x: edgeInsets.left, y: edgeInsets.top)
    
    var space: Int32 = 20
    
    var imageCell: Size = Size(width: 375, height: 600)
    
    var testSummaries: [TestSummaries]
    
    var paths: [String]
    
    init(testSummaries: [TestSummaries], paths: [String]) {
        self.testSummaries = testSummaries
        self.paths = paths
    }
    
    func writeTo(path: String) throws {
        let canvasSize = self.canvasSize
        
        let image = gdImageCreateTrueColor(canvasSize.width, canvasSize.height)!
        
        let white = gdImageColorAllocate(image, 255, 255, 255)
        gdImageFilledRectangle(image, 0, 0, canvasSize.width, canvasSize.height, white)
        
        zip(testSummaries, paths).forEach({ item in
            let testSummary = item.0
            let path = item.1
            let fileName = path.components(separatedBy: "/").last ?? ""
            
//            template = template.replacingOccurrences(of: "${filename}", with: fileName)

            let attachments: [AttachmentWithParent] = testSummary.attachments
            
            attachments.enumerated().forEach({ (current) in
                let index = current.offset
                let attachment = current.element
                
//                item = item.replacingOccurrences(of: "${path}", with: path)
//                item = item.replacingOccurrences(of: "${fileName}", with: attachment.attachment.fileName)
//                item = item.replacingOccurrences(of: "${title}", with: attachment.parent.testIdentifier)
                let fullPath = String(format: "%@/Attachments/%@", path, attachment.attachment.fileName)
                
                let ext = attachment.attachment.fileName.components(separatedBy: ".").last?.lowercased() ?? "png"
                let currentImage: gdImagePtr
                let file = fopen(fullPath, "rb")
                defer { fclose(file) }

                if ext == "png" {
                    currentImage = gdImageCreateFromPng(file)
                } else if ext == "jpg" {
                    currentImage = gdImageCreateFromJpeg(file)
                } else {
                    return
                }
                
                let imageInfo = Image(path: fullPath)
                guard let width = imageInfo?.width, let height = imageInfo?.height else { return }
                
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
                
                gdImageCopyResized(image, currentImage, currentPoint.x, currentPoint.y, 0, 0, newWidth, newHeight, width, height)

                if index == attachments.count - 1 {
                    // last
                    currentPoint = Point(x: edgeInsets.left, y: currentPoint.y + imageCell.height + space)
                } else {
                    // other
                    currentPoint = Point(x: currentPoint.x + imageCell.width, y: currentPoint.y)
                }
            })
        })
        
        let outputFile = fopen(path, "wb")
        defer {
            fclose(outputFile)
            gdImageDestroy(image)
        }
        
        gdImagePng(image, outputFile)
    }
    
    var canvasSize: Size {
        var size: Size = Size(width: edgeInsets.left + edgeInsets.right, height: edgeInsets.top + edgeInsets.bottom)
        
        let numberOfCols: Int32 = Int32(testSummaries.map { testSummary -> Int32 in
            return Int32(testSummary.attachments.count)
        }.max() ?? 0)
        size.width += numberOfCols * imageCell.width
        
        let numberOfRows: Int32 = Int32(testSummaries.count)
        size.height += numberOfRows * imageCell.height + (numberOfRows - 1) * space
        
        return size
    }
}

//
//  ImageToPixelBufferConverter.swift
//  SmartGroceryList
//
//  Created by Meghan Kane on 7/31/17.
//  Copyright © 2017 Meghan Kane. All rights reserved.
//

import Foundation
import UIKit

// MARK: - ImageToPixelBufferConverter

class ImageToPixelBufferConverter {
    static func convertToPixelBuffer(image: UIImage) -> CVPixelBuffer? {
        let newSize = CGSize(width: 224.0, height: 224.0)
        if let resizedImage = resizeImage(image: image, newSize: newSize) {
            if let createdPixelBuffer = createPixelBuffer(image: image, newSize: newSize) {
                CVPixelBufferLockBaseAddress(createdPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
                let pixelData = CVPixelBufferGetBaseAddress(createdPixelBuffer)
                
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                guard let context = CGContext(data: pixelData,
                                              width: Int(newSize.width),
                                              height: Int(newSize.height),
                                              bitsPerComponent: 8,
                                              bytesPerRow: CVPixelBufferGetBytesPerRow(createdPixelBuffer),
                                              space: colorSpace,
                                              bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
                                                return nil
                }
                                                
                context.translateBy(x: 0, y: newSize.height)
                context.scaleBy(x: 1.0, y: -1.0)
                
                UIGraphicsPushContext(context)
                resizedImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
                UIGraphicsPopContext()
                CVPixelBufferUnlockBaseAddress(createdPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
                
                return createdPixelBuffer
                }
            }
        return nil
    }
    
    private static func resizeImage(image: UIImage, newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        UIGraphicsEndImageContext()
        return resizedImage
        
    }
    
    private static func createPixelBuffer(image: UIImage, newSize: CGSize) -> CVPixelBuffer? {
        let attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                          kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(newSize.width),
                                         Int(newSize.height),
                                         kCVPixelFormatType_32ARGB,
                                         attributes,
                                         &pixelBuffer)
        
        guard let createdPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil // TODO: raise error
        }
        
        return createdPixelBuffer
    }
    
}

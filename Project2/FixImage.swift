////
////  FixImage.swift
////  Project2
////
////  Created by chang-che-wei on 2018/9/3.
////  Copyright © 2018年 chang-che-wei. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//func fixOrientation(aImage: UIImage) -> UIImage {
//    // No-op if the orientation is already correct
//    if aImage.imageOrientation == .up {
//        return aImage
//    }
//    // We need to calculate the proper transformation to make the image upright.
//    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
//    var transform: CGAffineTransform = .identity
//    switch aImage.imageOrientation {
//    case .down, .downMirrored:
//        transform = transform.translatedBy(x: aImage.size.width, y: aImage.size.height)
//        transform = transform.rotated(by: CGFloat(Double.pi))
//    case .left, .leftMirrored:
//        transform = transform.translatedBy(x: aImage.size.width, y: 0)
//        transform = transform.rotated(by: CGFloat(Double.pi/2))
//    case .right, .rightMirrored:
//        transform = transform.translatedBy(x: 0, y: aImage.size.height)
//        transform = transform.rotated(by: CGFloat(-Double.pi/2))
//    default:
//        break
//    }
//    
//    switch aImage.imageOrientation {
//    case .upMirrored, .downMirrored:
//        transform = transform.translatedBy(x: aImage.size.width, y: 0)
//        transform = transform.scaledBy(x: -1, y: 1)
//    case .leftMirrored, .rightMirrored:
//        transform = transform.translatedBy(x: aImage.size.height, y: 0)
//        transform = transform.scaledBy(x: -1, y: 1)
//    default:
//        break
//    }
//    
//    // Now we draw the underlying CGImage into a new context, applying the transform
//    // calculated above.
//    
//    
//    //这里需要注意下CGImageGetBitmapInfo，它的类型是Int32的，CGImageGetBitmapInfo(aImage.CGImage).rawValue，这样写才不会报错
////    let ctx: CGContext = CGBitmapContextCreate(nil, Int(aImage.size.width), Int(aImage.size.height), CGImageGetBitsPerComponent(aImage.CGImage), 0, CGImageGetColorSpace(aImage.CGImage), CGImageGetBitmapInfo(aImage.CGImage).rawValue)!
//    let ctx: CGContext = CGBitmapInfo(rawValue: aImage.cgImage).rawValue
//    ctx.concatenate(transform)
//
//    switch aImage.imageOrientation {
//    case .left, .leftMirrored, .right, .rightMirrored:
//        // Grr...
//        CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.height, aImage.size.width), aImage.cgImage)
//    default:
//        CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.width, aImage.size.height), aImage.cgImage)
//    }
//    
//    // And now we just create a new UIImage from the drawing context
//    let cgimg: CGImage = ctx.makeImage()!
//    let img: UIImage = UIImage(CGImage: cgimg)
//    return img
//}

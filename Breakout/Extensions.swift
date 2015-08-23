//
//  Extenstions.swift
//  TwitterTimeline
//
//  Created by Arturs Derkintis on 8/10/15.
//  Copyright © 2015 Starfly. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
///THIS IS MY MUTIFUNCTIONAL EXTENSION FILE - MANY FUNCTIONS MAY NOT BE IN USE IN THIS PROJECT

extension UIColor{
    convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = advance(rgba.startIndex, 1)
            let hex : NSString    = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex as String)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                if (hex.length == 6) {
                    red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF) / 255.0
                } else if hex.length == 8 {
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                } else {
                    print("invalid rgb string, length should be 7 or 9", appendNewline: false)
                }
            } else {
                print("scan hex error")
            }
        } else {
            print("invalid rgb string, missing '#' as prefix", appendNewline: false)
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
}
public func accurateRound(value: CGFloat) -> Int {
    
    let d : CGFloat = value - CGFloat(Int(value))
    
    if d < 0.99 {
        return Int(value)
    } else {
        return Int(value) + 1
    }
}

extension SKSpriteNode{
    struct Velo {
        static var xPos : CGFloat = 0.0
    }
    
    var velocityX: CGFloat?{
        get{
            if Velo.xPos == 0.0{
                Velo.xPos = self.position.x
            }
            let xPosition = self.position.x - Velo.xPos
            Velo.xPos = self.position.x
            return xPosition
        }
    }
    
}
public func convertUIPointToSprite(point: CGPoint, node : SKSpriteNode) -> CGPoint{
    
    let height = node.size.height
    let y = height - point.y
    
    return CGPoint(x: point.x, y: y)
    
}
extension Int {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
}

extension UIImage{
    func sliceImageToPieces(imageSize : CGSize, pieceSize : CGSize) -> [UIImage]{
        let whole = resizeImage(imageSize, image: self)
        var imagesArray = [UIImage]()
       
        let imagesCountInLine = Int(imageSize.width / pieceSize.width)
        let tilesCount = Int(imagesCountInLine * imagesCountInLine)
        var line = 0
        var row = 0
        for var i = 0; i < tilesCount; ++i {
            let cgImg = CGImageCreateWithImageInRect(whole.CGImage, CGRectMake(CGFloat(row) * pieceSize.width, CGFloat(line) * pieceSize.width, pieceSize.width, pieceSize.height));
            let img = UIImage(CGImage: cgImg!)
            imagesArray.append(img)

            if row == imagesCountInLine - 1{
                line += 1
                row = 0
            }else{
                row += 1
            }
        }

        return imagesArray
    }
    func resizeImage(size: CGSize, image : UIImage) -> UIImage {
      
        UIGraphicsBeginImageContext(size);
        
        let context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0.0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextDrawImage(context, CGRectMake(0.0, 0.0, size.width, size.height), image.CGImage);
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();

        return scaledImage
    }

        func clipImage(path : UIBezierPath, image : UIImage) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        path.addClip()
        image.drawAtPoint(CGPointZero)
        let newIma = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return trimmed(newIma)
    }
    func trimmed(image : UIImage) -> UIImage{
        let inImage = image.CGImage
        let m_dataRef : CFDataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage))!
        let m_PixelBuf : UnsafePointer<UInt8> = CFDataGetBytePtr(m_dataRef)
        let width : size_t = CGImageGetWidth(inImage)
        let height : size_t = CGImageGetHeight(inImage)
        var top : CGPoint?
        var left : CGPoint?
        var right : CGPoint?
        var bottom : CGPoint?
        var breakOut = false
        for var x = 0; breakOut == false && x < width; ++x{
            for var y = 0; y < height; ++y{
                var loc = x + (y * width)
                loc *= 4
                if m_PixelBuf[loc + 3] != 0{
                    left = CGPoint(x: CGFloat(x), y: CGFloat(y))
                    breakOut = true
                    break
                }
                
               
            }
            
        }
        breakOut = false
        for var y = 0; breakOut == false && y < height; ++y{
            for var x = 0; x < width; ++x{
                var loc = x + (y * width)
                loc *= 4
                if m_PixelBuf[loc + 3] != 0{
                    top = CGPoint(x: CGFloat(x), y: CGFloat(y))
                    breakOut = true
                    break
                }
            }
        }
        breakOut = false
        for var y = height - 1; breakOut == false && y >= 0; --y{
            for var x = width - 1; x >= 0; --x{
                var loc = x + (y * width)
                loc *= 4
                if m_PixelBuf[loc + 3] != 0{
                    bottom = CGPoint(x: CGFloat(x), y: CGFloat(y))
                    breakOut = true
                    break
                }
            }
        }
        breakOut = false
        for var x = width - 1; breakOut == false && x >= 0; --x{
            for var y = height - 1; y >= 0; --y{
                var loc = x + (y * width)
                loc *= 4
                if m_PixelBuf[loc + 3] != 0{
                    right = CGPoint(x: CGFloat(x), y: CGFloat(y))
                    breakOut = true
                    break
                }
            }
        }
        let scale = image.scale
        let cropRect = CGRect(x: left!.x / scale, y: top!.y / scale, width: (right!.x - left!.x) / scale, height: (bottom!.y - top!.y) / scale)
        UIGraphicsBeginImageContextWithOptions(cropRect.size, false, scale)
        image.drawAtPoint(CGPoint(x: -cropRect.origin.x, y: -cropRect.origin.y), blendMode: CGBlendMode.Copy, alpha: 1.0)
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
        
       
    }
    
}

extension NSArray{
    func reversedArray() -> NSArray{
        let array = NSMutableArray(capacity: self.count)
        let enumeratore = self.reverseObjectEnumerator()
        for element in enumeratore {
            array.addObject(element)
            
        }
        return array
    }
    
}
extension UIBezierPath{
    func center() -> CGPoint{
        return CGPoint(x: CGRectGetMidX(self.bounds), y: CGRectGetMidY(self.bounds))
    }
}
public func abbreviateNumber(num: NSNumber) -> NSString {
    var ret: NSString = ""
    let abbrve: [String] = ["K", "M", "B"]
    
    let floatNum = num.floatValue
    
    if floatNum > 1000 {
        
        for i in 0..<abbrve.count {
            let size = pow(10.0, (Float(i) + 1.0) * 3.0)
            // print("\(size)   \(floatNum)")
            if (size <= floatNum) {
                let num = floatNum / size
                let str = floatToString(num)
                ret = NSString(format: "%@%@", str, abbrve[i])
            }
        }
    } else {
        ret = NSString(format: "%d", Int(floatNum))
    }
    
    return ret
}
public func floatToString(val: Float) -> NSString {
    var ret = NSString(format: "%.1f", val)
    var c = ret.characterAtIndex(ret.length - 1)
    
    while c == 48 {
        ret = ret.substringToIndex(ret.length - 1)
        c = ret.characterAtIndex(ret.length - 1)
        
        
        if (c == 46) {
            ret = ret.substringToIndex(ret.length - 1)
        }
    }
    return ret
}
public func distanceBetweenPoints(point1:CGPoint,point2:CGPoint)->CGFloat{
    return sqrt(pow(point1.x-point2.x,2) + pow(point1.y-point2.y,2));
}
extension CGSize{
    
    func containsPoint(point : CGPoint) -> Bool{
        if point.x >= 0 && point.x <= width && point.y >= 0 && point.y <= height{
            return true
        }
        return false
    }
    
}
extension CGPoint{
    static func randomPointInRect(rect : CGRect) -> CGPoint{
            var point = rect.origin
            point.x += CGFloat(arc4random_uniform(UInt32(CGRectGetWidth(rect))))
            point.y += CGFloat(arc4random_uniform(UInt32(CGRectGetHeight(rect))))
    
            return point
        
     
    }
}
extension CollectionType where Index == Int {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}
public func randomInRange (lower: Int , upper: Int) -> Int {
    return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
}
public func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}


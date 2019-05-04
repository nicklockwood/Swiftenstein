//
//  Images.swift
//
//  Created by Nick Lockwood on 22/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init?(bitmap: Bitmap) {
        let (pixels, width, height) = (bitmap.pixels, bitmap.width, bitmap.height)
        guard width > 0, height > 0, pixels.count == width * height else {
            return nil
        }

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bitsPerComponent = 8
        let bitsPerPixel = 32

        var data = [Color]()
        data.reserveCapacity(width * height)
        for y in 0 ..< height {
            for x in 0 ..< width {
                data.append(pixels[x * height + y])
            }
        }
        guard let providerRef = CGDataProvider(data: NSData(
            bytes: &data, length: data.count * MemoryLayout<Color>.size
        )) else {
            return nil
        }

        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * MemoryLayout<Color>.size,
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else {
            return nil
        }

        self.init(cgImage: cgImage)
    }
}

extension Bitmap {
    init?(image: UIImage) {
        guard let cgImage = image.cgImage else {
            return nil
        }

        let width = cgImage.width
        let height = cgImage.height

        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

        var data = [Color](repeating: Color(r: 0, g: 0, b: 0, a: 0), count: width * height)
        let context = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        )

        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context?.draw(cgImage, in: rect)

        // arrange in column order
        var pixels = [Color]()
        pixels.reserveCapacity(width * height)
        for y in 0 ..< height {
            for x in 0 ..< width {
                pixels.append(data[x * height + y])
            }
        }
        self.init(height: height, pixels: pixels)
    }
}

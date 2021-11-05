//
//  AppIconFactory.swift
//  Pomodocko
//
//  Created by Elijah Sawyers on 11/4/21.
//

import Cocoa

/// Handles the creation of app icons by layering images over one another.
class AppIconFactory {

    /// Create an app icon by composing the images with the given names.
    ///
    /// - Returns: The composed app icon (`NSImage`) is returned, but if any of the names are invalid, `nil` is returned.
    /// - Note: The images are composed in the order in which they're given (left-to-right).
    static func createIcon(withImagesNamed imageNames: [String]) -> NSImage? {
        guard imageNames.count > 1 else { return NSImage(named: imageNames.first!) }

        var images: [NSImage] = []

        for imageName in imageNames {
            guard let image = NSImage(named: imageName) else { return nil }
            images.append(image)
        }

        var result = images.removeFirst()

        while !images.isEmpty {
            guard let composedImage = compose(image: images.removeFirst(), over: result) else { return nil }
            result = composedImage
        }

        return result
    }

    /// Layer `image` over `background` and return the result.
    private static func compose(image: NSImage, over background: NSImage) -> NSImage? {
        guard let background = background.ciImage else { return nil }
        guard let image = image.ciImage else { return nil }
        let composite = image.composited(over: background)

        let representation = NSCIImageRep(ciImage: composite)
        let result = NSImage(size: representation.size)
        result.addRepresentation(representation)
        return result
    }

}

// MARK: NSImage+CIImage Extension[s]

extension NSImage {

    /// Convert `NSImage` to `CIImage`.
    var ciImage: CIImage? {
        guard let tiffRepresentation = tiffRepresentation else { return nil }
        guard let bitmap = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return CIImage(bitmapImageRep: bitmap)
    }

}

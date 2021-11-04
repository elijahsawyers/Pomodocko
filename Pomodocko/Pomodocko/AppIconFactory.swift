//
//  AppIconFactory.swift
//  Pomodocko
//
//  Created by Elijah Sawyers on 11/4/21.
//

import Cocoa

class AppIconFactory {

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

extension NSImage {
    var ciImage: CIImage? {
        guard let tiffRepresentation = tiffRepresentation else { return nil }
        guard let bitmap = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return CIImage(bitmapImageRep: bitmap)
    }
}

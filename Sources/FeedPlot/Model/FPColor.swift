//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation
import simd

public extension FPColor {
    static let gray = FPColor(0.463, 0.514, 0.456, 1)
    static let pink = FPColor(0.992, 0.071, 0.486, 1)
    static let gold = FPColor(0.984, 0.745, 0.412, 1)
    static let blue = FPColor(0.016, 0.796, 0.957, 1)
}

// MARK: - SwiftUI

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
extension Color {

    /// Returns a placeholder clear color if decoding fails.
    /// Patterned colors and colors that cannot be converted to sRGB will fail.
    public func asFeedPlotColor() -> FPColor {
#if !targetEnvironment(macCatalyst) && canImport(AppKit)
        NSColor(self).asFeedPlotColor()
#elseif canImport(UIKit)
        UIColor(self).asFeedPlotColor()
#endif
    }
}
#endif

// MARK: - AppKit

#if !targetEnvironment(macCatalyst) && canImport(AppKit)
extension NSColor {

    /// Returns a placeholder clear color if decoding fails.
    /// Patterned colors and colors that cannot be converted to sRGB will fail.
    public func asFeedPlotColor() -> FPColor {
        guard let color = asValid_sRGBComponentBased() else { return .zero }

        switch color.numberOfComponents {
            case 4...:
                let c = [color.redComponent,
                         color.greenComponent,
                         color.blueComponent,
                         color.alphaComponent]
                    .map(Float.init)
                return .init(c[0...3])

            case ...2:
                return .init(.init(repeating: Float(color.whiteComponent)),
                             Float(color.alphaComponent))

            default:
                return .zero
        }
    }

    internal func asValid_sRGBComponentBased() -> NSColor? {
        guard let rgb = usingType(.componentBased)
        else { return nil }

        guard rgb.colorSpace == .extendedSRGB || rgb.colorSpace == .sRGB
        else { return rgb.usingColorSpace(.extendedSRGB) }

        return rgb
    }
}

// MARK: - UIKit
#elseif canImport(UIKit)

extension UIColor {

    /// Returns a placeholder clear color if decoding fails.
    /// Patterned colors and colors that cannot be converted to sRGB will fail.
    public func asFeedPlotColor() -> FPColor {
        self.cgColor.asFeedPlotColor()
    }

}

#endif

// MARK: - CoreGraphics
#if canImport(CoreGraphics)

extension CGColor {

    /// Returns a placeholder clear color if decoding fails.
    /// Patterned colors and colors that cannot be converted to sRGB will fail.
    public func asFeedPlotColor() -> FPColor {

        guard let components = asValid_sRGB()?.components?.map(Float.init),
              components.count == 4
        else { return .zero }

        return .init(components[0...3])
    }

    internal func asValid_sRGB() -> CGColor? {
        guard colorSpace == srgb || colorSpace == esrgb
        else { return converted(to: srgb, intent: .defaultIntent, options: nil) }
        return self
    }
}

internal let esrgb = CGColorSpace(name: CGColorSpace.extendedSRGB)!
internal let srgb = CGColorSpace(name: CGColorSpace.extendedSRGB)!

#endif

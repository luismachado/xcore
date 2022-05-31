//
// Xcore
// Copyright © 2021 Xcore
// MIT license, see LICENSE file for details
//

import SwiftUI

extension Color.RGBColorSpace {
    public static var `default`: Self = .sRGB
}

extension Color {
    public init(_ colorSpace: Color.RGBColorSpace = .default, hex: Int64) {
        self.init(UIColor(colorSpace, hex: hex))
    }

    public init(_ colorSpace: Color.RGBColorSpace = .default, hex: Int64, opacity: CGFloat) {
        self.init(UIColor(colorSpace, hex: hex, alpha: opacity))
    }

    public init(_ colorSpace: Color.RGBColorSpace = .default, hex: String) {
        self.init(UIColor(colorSpace, hex: hex))
    }

    public init(_ colorSpace: Color.RGBColorSpace = .default, hex: String, opacity: CGFloat) {
        self.init(UIColor(colorSpace, hex: hex, alpha: opacity))
    }
}

// MARK: - Random

extension Color {
    /// Returns a random color.
    public static func random() -> Self {
        let hue = CGFloat(arc4random() % 256) / 256
        let saturation = CGFloat(arc4random() % 128) / 256 + 0.5
        let brightness = CGFloat(arc4random() % 128) / 256 + 0.5
        return Color(hue: hue, saturation: saturation, brightness: brightness, opacity: 1)
    }
}

// MARK: - Color Scheme Mode

extension Color {
    /// Creates a color object that generates its color data dynamically using the
    /// specified colors.
    ///
    /// - Parameters:
    ///   - light: The color for light color scheme.
    ///   - dark: The color for dark color scheme.
    public init(
        light: @autoclosure @escaping () -> Color,
        dark: @autoclosure @escaping () -> Color
    ) {
        self.init(UIColor {
            switch $0.userInterfaceStyle {
                case .dark:
                    return UIColor(dark())
                default:
                    return UIColor(light())
            }
        })
    }

    /// Creates a color object that generates its color data dynamically using the
    /// specified colors.
    ///
    /// - Parameters:
    ///   - light: The color for light color scheme.
    ///   - dark: The color for dark color scheme.
    @_disfavoredOverload
    public init(
        light: @autoclosure @escaping () -> UIColor,
        dark: @autoclosure @escaping () -> UIColor
    ) {
        self.init(UIColor {
            switch $0.userInterfaceStyle {
                case .dark:
                    return dark()
                default:
                    return light()
            }
        })
    }
}

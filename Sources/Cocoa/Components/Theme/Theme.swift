//
// Xcore
// Copyright © 2016 Xcore
// MIT license, see LICENSE file for details
//

import UIKit

@dynamicMemberLookup
public struct Theme: MutableAppliable, UserInfoContainer {
    public typealias Identifier = Xcore.Identifier<Self>
    public typealias ButtonColor = (ButtonIdentifier, ElementPosition) -> UIColor

    /// A unique id for the theme.
    public var id: Identifier

    /// A color that represents the system or application accent color.
    public var accentColor: UIColor

    /// The color for divider lines that hides any underlying content.
    public var separatorColor: UIColor

    /// The color for border lines that hides any underlying content.
    public var borderColor: UIColor

    /// The color for toggle controls (e.g., Switch or Checkbox).
    public var toggleColor: UIColor

    /// The color for links.
    public var linkColor: UIColor

    /// The color for placeholder text in controls or text views.
    public var placeholderTextColor: UIColor

    // MARK: - Sentiment Color

    /// The color for representing positive sentiment.
    public var positiveSentimentColor: UIColor

    /// The color for representing negative sentiment.
    public var negativeSentimentColor: UIColor

    // MARK: - Text

    /// The color for text labels that contain primary content.
    public var textColor: UIColor

    /// The color for text labels that contain secondary content.
    public var textSecondaryColor: UIColor

    /// The color for text labels that contain tertiary content.
    public var textTertiaryColor: UIColor

    /// The color for text labels that contain quaternary content.
    public var textQuaternaryColor: UIColor

    // MARK: - Background

    /// The color for the main background of your interface.
    public var backgroundColor: UIColor

    /// The color for content layered on top of the main background.
    public var backgroundSecondaryColor: UIColor

    /// The color for content layered on top of secondary backgrounds.
    public var backgroundTertiaryColor: UIColor

    // MARK: - Buttons
    public var buttonBackgroundColor: ButtonColor
    public var buttonPressedBackgroundColor: ButtonColor
    public var buttonDisabledBackgroundColor: ButtonColor

    // MARK: - Chrome
    public var statusBarStyle: UIStatusBarStyle
    public var chrome: Chrome.Style

    /// Additional info which may be used to describe the theme further.
    public var userInfo: UserInfo

    public init(
        id: Identifier,
        accentColor: UIColor,
        separatorColor: UIColor,
        borderColor: UIColor,
        toggleColor: UIColor,
        linkColor: UIColor,
        placeholderTextColor: UIColor,

        // Sentiment
        positiveSentimentColor: UIColor,
        negativeSentimentColor: UIColor,

        // Text
        textColor: UIColor,
        textSecondaryColor: UIColor,
        textTertiaryColor: UIColor,
        textQuaternaryColor: UIColor,

        // Background
        backgroundColor: UIColor,
        backgroundSecondaryColor: UIColor,
        backgroundTertiaryColor: UIColor,

        // Button
        buttonBackgroundColor: @escaping ButtonColor,
        buttonPressedBackgroundColor: @escaping ButtonColor,
        buttonDisabledBackgroundColor: @escaping ButtonColor,

        // Chrome
        statusBarStyle: UIStatusBarStyle,
        chrome: Chrome.Style,

        // UserInfo
        userInfo: UserInfo = [:]
    ) {
        self.id = id
        self.accentColor = accentColor
        self.separatorColor = separatorColor
        self.borderColor = borderColor
        self.toggleColor = toggleColor
        self.linkColor = linkColor
        self.placeholderTextColor = placeholderTextColor

        // Sentiment
        self.positiveSentimentColor = positiveSentimentColor
        self.negativeSentimentColor = negativeSentimentColor

        // Text
        self.textColor = textColor
        self.textSecondaryColor = textSecondaryColor
        self.textTertiaryColor = textTertiaryColor
        self.textQuaternaryColor = textQuaternaryColor

        // Background
        self.backgroundColor = backgroundColor
        self.backgroundSecondaryColor = backgroundSecondaryColor
        self.backgroundTertiaryColor = backgroundTertiaryColor

        // Button
        self.buttonBackgroundColor = buttonBackgroundColor
        self.buttonPressedBackgroundColor = buttonPressedBackgroundColor
        self.buttonDisabledBackgroundColor = buttonDisabledBackgroundColor

        // Chrome
        self.statusBarStyle = statusBarStyle
        self.chrome = chrome

        // UserInfo
        self.userInfo = userInfo
    }
}

// MARK: - Convenience

extension Theme {
    public func buttonBackgroundColor(_ id: ButtonIdentifier) -> UIColor {
        buttonBackgroundColor(id, .primary)
    }

    public func buttonPressedBackgroundColor(_ id: ButtonIdentifier) -> UIColor {
        buttonPressedBackgroundColor(id, .primary)
    }

    public func buttonDisabledBackgroundColor(_ id: ButtonIdentifier) -> UIColor {
        buttonDisabledBackgroundColor(id, .primary)
    }
}

// MARK: - KeyPath

extension Theme {
    public static subscript<T>(dynamicMember keyPath: KeyPath<Self, T>) -> T {
        `default`[keyPath: keyPath]
    }

    public static subscript<T>(dynamicMember keyPath: WritableKeyPath<Self, T>) -> T {
        get { `default`[keyPath: keyPath] }
        set { `default`[keyPath: keyPath] = newValue }
    }
}

// MARK: - Hashable

extension Theme: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Equatable

extension Theme: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Default

extension Theme {
    /// The default theme for the interface.
    public static var `default`: Theme = .system

    /// The system theme using [UI Element Colors] for the interface.
    ///
    /// [UI Element Colors]: https://developer.apple.com/documentation/uikit/uicolor/ui_element_colors
    private static let system = Theme(
        id: "system",
        accentColor: .systemTint,
        separatorColor: .separator,
        borderColor: .separator,
        toggleColor: .systemGreen,
        linkColor: .link,
        placeholderTextColor: .placeholderText,

        // Sentiment
        positiveSentimentColor: .systemGreen,
        negativeSentimentColor: .systemRed,

        // Text
        textColor: .label,
        textSecondaryColor: .secondaryLabel,
        textTertiaryColor: .tertiaryLabel,
        textQuaternaryColor: .quaternaryLabel,

        // Background
        backgroundColor: .systemBackground,
        backgroundSecondaryColor: .secondarySystemBackground,
        backgroundTertiaryColor: .tertiarySystemBackground,

        // Button
        buttonBackgroundColor: { _, _ in
            .systemTint
        },
        buttonPressedBackgroundColor: { _, _ in
            .systemTint
        },
        buttonDisabledBackgroundColor: { _, _ in
            .secondarySystemBackground
        },

        // Chrome
        statusBarStyle: .default,
        chrome: .blurred
    )
}

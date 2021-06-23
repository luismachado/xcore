//
// Xcore
// Copyright © 2019 Xcore
// MIT license, see LICENSE file for details
//

import Foundation

extension ValidationRule {
    /// No validation rule is applied.
    public static var none: Self {
        .init { _ in true }
    }
}

// MARK: - Input: Collection

extension ValidationRule where Input: Collection {
    /// A validation rule that checks whether the input count is contained within the range expression.
    ///
    /// This validation rule can be used guard minimum or maximum length:
    ///
    /// ```swift
    /// let name = "John Doe"
    /// name.validate(rule: .range(1...)) // length >= 1
    ///
    /// let password = "***"
    /// password.validate(rule: .range(8...50)) // length between 8 - 50
    /// ```
    ///
    /// - Parameter range: The range expression to check against input count.
    /// - Returns: The validation rule.
    public static func range<T: RangeExpression>(_ range: T) -> Self where T.Bound == Int {
        .init { range.contains($0.count) }
    }

    /// A validation rule that checks whether the input is not empty.
    ///
    /// - Returns: The validation rule.
    public static var notEmpty: Self {
        .init { !$0.isEmpty }
    }
}

// MARK: - Input: Equatable

extension ValidationRule where Input: Equatable {
    /// A validation rule that checks whether the input is equal to the given
    /// value.
    ///
    /// - Parameter value: The value to compare against input.
    /// - Returns: The validation rule.
    public static func equals(_ value: Input) -> Self {
        .init { $0 == value }
    }
}

// MARK: - Input: Comparable

extension ValidationRule where Input: Comparable {
    /// A validation rule that checks whether the input is less than the given
    /// value.
    ///
    /// - Parameter value: The value to compare against input.
    /// - Returns: The validation rule.
    public static func lessThan(_ value: Input) -> Self {
        .init { $0 < value }
    }

    /// A validation rule that checks whether the input is less than or equal to the
    /// given value.
    ///
    /// - Parameter value: The value to compare against input.
    /// - Returns: The validation rule.
    public static func lessThanOrEqual(_ value: Input) -> Self {
        .init { $0 <= value }
    }

    /// A validation rule that checks whether the input is greater than the given
    /// value.
    ///
    /// - Parameter value: The value to compare against input.
    /// - Returns: The validation rule.
    public static func greaterThan(_ value: Input) -> Self {
        .init { $0 > value }
    }

    /// A validation rule that checks whether the input is greater than or equal to
    /// the given value.
    ///
    /// - Parameter value: The value to compare against input.
    /// - Returns: The validation rule.
    public static func greaterThanOrEqual(_ value: Input) -> Self {
        .init { $0 >= value }
    }
}

// MARK: - Input: String

extension ValidationRule where Input == String {
    /// A validation rule that checks whether the input satisfy the given regex.
    ///
    /// - Parameter pattern: Regex pattern used to find matches in the input.
    /// - Returns: The validation rule.
    public static func regex(_ pattern: String) -> Self {
        .init { $0.isMatch(pattern) }
    }

    /// A validation rule that checks whether the input contains the given string.
    ///
    /// - Parameters:
    ///   - other: The other string to search for in the input string.
    ///   - options: The String `ComparisonOptions`. The default value `[]`.
    /// - Returns: The validation rule.
    public static func contains<T: StringProtocol>(_ other: T, options: String.CompareOptions = []) -> Self {
        .init { $0.contains(other, options: options) }
    }

    /// A validation rule that checks whether the input begins with the specified
    /// prefix.
    ///
    /// - Parameter prefix: A possible prefix to test against this string.
    /// - Returns: The validation rule.
    static func hasPrefix<T: StringProtocol>(_ prefix: T) -> Self {
        .init { $0.hasPrefix(prefix) }
    }

    /// A validation rule that checks whether the input ends with the specified
    /// suffix.
    ///
    /// - Parameter suffix: A possible suffix to test against this string.
    /// - Returns: The validation rule.
    static func hasSuffix<T: StringProtocol>(_ suffix: T) -> Self {
        .init { $0.hasSuffix(suffix) }
    }

    /// A validation rule that checks whether the input is a subset of the given
    /// set.
    ///
    /// - Parameter other: The superset of the input.
    /// - Returns: The validation rule.
    public static func subset(of other: CharacterSet) -> Self {
        .init { input in
            let input = CharacterSet(charactersIn: input)
            return other.isSuperset(of: input)
        }
    }
}

// MARK: - Regex Based Rules

extension ValidationRule where Input == String {
    /// A validation rule that checks whether the input is not blank.
    public static var notBlank: Self {
        .init { !$0.isBlank }
    }

    /// A validation rule that checks whether the input is a valid email address.
    public static var email: Self {
        "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    }

    /// A validation rule that checks whether the input is a valid SSN.
    public static var ssn: Self {
        .init(
            pattern: "^(?!000)(?!666)^([0-8]\\d{2})((?!00)(\\d{2}))((?!0000)(\\d{4}))",
            transform: { $0.replacing("-", with: "") }
        )
    }

    /// A validation rule that checks whether the input is a valid ITIN.
    ///
    /// **Individual Taxpayer Identification Number**
    ///
    /// Format: `9XX-7X-XXXX`
    ///
    /// **What is an ITIN?**
    ///
    /// An Individual Taxpayer Identification Number (ITIN) is a tax processing
    /// number issued by the Internal Revenue Service. The IRS issues ITINs to
    /// individuals who are required to have a U.S. taxpayer identification number
    /// but who do not have, and are not eligible to obtain, a Social Security
    /// number (SSN) from the Social Security Administration (SSA).
    public static var itin: Self {
        .init(
            pattern: "^(9\\d{2})([ \\-]?)(7\\d|8[0-8]|9[0-2]|9[4-9])([ \\-]?)(\\d{4})$",
            transform: { $0.replacing("-", with: "") }
        )
    }

    public static var name: Self {
        .init { input in
            let range = 1...50
            return range.contains(input.count) && !input.isMatch("[0-9]")
        }
    }

    /// A validation rule that checks whether the input is equal to the given
    /// range.
    ///
    /// - Parameter range: The range of the input.
    /// - Returns: The validation rule.
    public static func number<T: RangeExpression>(range: T) -> Self where T.Bound == Int {
        .init { range.contains($0.count) && $0.isMatch("[0-9]") }
    }

    /// A validation rule that checks whether the input is equal to the given
    /// count.
    ///
    /// - Parameter count: The maximum count of the input.
    /// - Returns: The validation rule.
    public static func number(count: Int) -> Self {
        number(range: 1...count)
    }
}

// MARK: - Data Detector

extension ValidationRule where Input == String {
    /// A validation rule that checks whether the input is equal to the given
    /// data detector type.
    ///
    /// - Parameter value: The value to compare against input.
    /// - Returns: The validation rule.
    public static func isValid(_ type: NSTextCheckingResult.CheckingType) -> Self {
        .init { input in
            guard let detector = try? NSDataDetector(types: type.rawValue) else {
                return false
            }

            if let match = detector.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.count)) {
                return match.range.length == input.count
            }

            return false
        }
    }
}

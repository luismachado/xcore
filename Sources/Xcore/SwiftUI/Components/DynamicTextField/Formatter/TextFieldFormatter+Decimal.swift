//
// Xcore
// Copyright © 2021 Xcore
// MIT license, see LICENSE file for details
//

import Foundation

/// A formatter that converts between decimal values and their textual
/// representations.
public struct DecimalTextFieldFormatter: TextFieldFormatter {
    private let isCurrency: Bool
    private let isEmptyZero: Bool
    private let numberFormatter = NumberFormatter().apply {
        $0.allowsFloats = true
        $0.numberStyle = .decimal
        $0.maximumFractionDigits = .maxFractionDigits
    }

    public init(isCurrency: Bool, isEmptyZero: Bool) {
        self.isCurrency = isCurrency
        self.isEmptyZero = isEmptyZero
    }

    public func string(from value: Double) -> String {
        if isEmptyZero, value == 0 {
            return ""
        }

        return numberFormatter.string(from: value) ?? ""
    }

    public func value(from string: String) -> Double {
        numberFormatter.number(from: string)?.doubleValue ?? 0.0
    }

    public func format(_ string: String) -> String? {
        let components = string.components(separatedBy: ".")

        guard
            let wholeNumberPartString = components.at(0),
            let wholeNumberPart = Int(wholeNumberPartString)
        else {
            return string.isEmpty ? "" : nil
        }

        let symbol = isCurrency ? currency.currencySymbol : nil
        let wholeNumber = numberFormatter.string(from: wholeNumberPart)
        let decimalPoint = string.contains(".") ? "." : ""
        var fractionPart: String? = components.at(1)

        // Fraction part can't be more then 2 decimal places for currency type.
        if isCurrency, let fraction = fractionPart {
            fractionPart = String(fraction.prefix(2))
        }

        return [
            symbol,
            wholeNumber,
            decimalPoint,
            fractionPart
        ].joined()
    }

    public func unformat(_ string: String) -> String {
        string
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: currency.currencySymbol, with: "")
    }

    private var currency: CurrencySymbolsProvider {
        CurrencyFormatter.shared
    }
}
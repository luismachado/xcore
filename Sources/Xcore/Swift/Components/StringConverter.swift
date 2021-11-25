//
// Xcore
// Copyright © 2019 Xcore
// MIT license, see LICENSE file for details
//

import Foundation

public struct StringConverter {
    private let string: String

    public init?(_ value: String?) {
        guard let value = value else {
            return nil
        }

        self.string = value
    }

    public init<T: LosslessStringConvertible>(_ value: T) {
        self.string = value.description
    }

    public init?(_ value: Any) {
        if let value = value as? LosslessStringConvertible {
            self.string = value.description
            return
        }

        // Captures NSString
        if let value = value as? String {
            self.string = value
            return
        }

        if let value = value as? NSNumber {
            self.string = value.stringValue
            return
        }

        return nil
    }

    private var url: URL? {
        URL(string: string)
    }

    private var json: Any? {
        guard !string.isBlank else {
            return nil
        }

        return JSONHelpers.decode(string)
    }

    private var nsNumber: NSNumber? {
        let formatter = NumberFormatter().apply {
            $0.numberStyle = .decimal
        }
        return formatter.number(from: string)
    }
}

extension StringConverter {
    public func get<T>() -> T? {
        switch T.self {
            case is String.Type, is Optional<String>.Type:
                return string as? T
            case is Bool.Type, is Optional<Bool>.Type:
                return Bool(string) as? T
            case is Double.Type, is Optional<Double>.Type:
                return Double(string) as? T
            case is Float.Type, is Optional<Float>.Type:
                return Float(string) as? T
            case is Int.Type, is Optional<Int>.Type:
                return Int(string) as? T
            case is URL.Type, is Optional<URL>.Type:
                return url as? T
            case is NSNumber.Type, is Optional<NSNumber>.Type:
                return nsNumber as? T
            case is NSString.Type, is Optional<NSString>.Type:
                return string as? T
            default:
                return json as? T
        }
    }

    public func get<T>() -> T? where T: RawRepresentable, T.RawValue == String {
        T(rawValue: string)
    }
}

// MARK: - JSONDecoder

extension StringConverter {
    /// Returns a value of the type you specify, decoded from an object.
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode from the string.
    ///   - decoder: The decoder used to decode the data. If set to `nil`, it uses
    ///     ``JSONDecoder`` with `convertFromSnakeCase` key decoding strategy.
    /// - Returns: A value of the specified type, if the decoder can parse the data.
    public func get<T>(_ type: T.Type = T.self, decoder: JSONDecoder? = nil) -> T? where T: Decodable {
        guard let data = string.data(using: .utf8) else {
            return nil
        }

        let decoder = decoder ?? makeDecoder()

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            #if DEBUG
            if AppInfo.isDebuggerAttached {
                print("Failed to decode \(type):")
                print("---")
                dump(error)
                print("---")
            }
            #endif
            return nil
        }
    }

    private func makeDecoder() -> JSONDecoder {
        JSONDecoder().apply {
            $0.keyDecodingStrategy = .convertFromSnakeCase
        }
    }
}

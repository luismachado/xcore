//
// InterstitialCompatibleViewController.swift
// Copyright © 2018 Xcore
// MIT license, see LICENSE file for details
//

import Foundation

public protocol InterstitialCompatibleViewController: UIViewController, ObstructableView {
    var didComplete: (() -> Void)? { get set }

    /// A method invoked when the interstitial is canceled by the user using the
    /// dismiss button.
    func didDismiss()
}

extension InterstitialCompatibleViewController {
    public func didDismiss() { }
}

// MARK: - Identifier

extension InterstitialCompatibleViewController {
    public var interstitialId: Interstitial.Identifier {
        get {
            guard let id = objc_getAssociatedObject(
                self,
                &Interstitial.AssociatedKey.interstitialId
            ) as? Interstitial.Identifier else {
                return Identifier(rawValue: name(of: self))
            }

            return id
        }
        set {
            objc_setAssociatedObject(
                self,
                &Interstitial.AssociatedKey.interstitialId,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

extension Interstitial {
    fileprivate struct AssociatedKey {
        static var interstitialId = "InterstitialCompatibleViewController.interstitialId"
    }
}

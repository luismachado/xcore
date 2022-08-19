//
// Xcore
// Copyright © 2022 Xcore
// MIT license, see LICENSE file for details
//

import Foundation
import Combine

public final class LiveSessionCounterClient: SessionCounterClient {
    fileprivate static let shared = LiveSessionCounterClient()
    @Dependency(\.pond) private var pond
    @Dependency(\.appStatus) private var appStatus
    @Dependency(\.requestReview) private var requestReview
    private var cancellable: AnyCancellable?

    init() {
        withDelay(0.3) { [weak self] in
            // Delay to avoid:
            // Thread 1: Simultaneous accesses to 0x1107dbc18, but modification requires
            // exclusive access. This is a client that invokes other clients.
            self?.addAppStatusObserver()
        }
    }

    private func addAppStatusObserver() {
        cancellable = appStatus
            .receive
            .when(.session(.unlocked))
            .sink { [weak self] in
                self?.increment()
            }
    }

    public var count: Int {
        pond.sessionCount
    }

    public func increment() {
        pond.incrementSessionCount()
        requestReviewIfNeeded()
    }

    private func requestReviewIfNeeded() {
        let multipleOfValue = FeatureFlag.reviewPromptVisitMultipleOf

        guard
            multipleOfValue > 0,
            count > 0,
            count.isMultiple(of: multipleOfValue)
        else {
            return
        }

        requestReview()
    }
}

// MARK: - Dot Syntax Support

extension SessionCounterClient where Self == LiveSessionCounterClient {
    /// Returns noop variant of `SessionCounterClient`.
    public static var live: Self {
        .shared
    }
}

// MARK: - Pond

extension Pond {
    fileprivate var sessionCount: Int {
        `get`(sessionCountKey, default: 0)
    }

    fileprivate func incrementSessionCount() {
        let currentValue = sessionCount
        try? set(sessionCountKey, value: currentValue + 1)
    }

    private var sessionCountKey: PondKey {
        userDefaultsKey(#function)
    }
}

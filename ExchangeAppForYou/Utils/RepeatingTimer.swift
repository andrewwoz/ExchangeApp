//
//  RepeatingTimer.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation
import Combine

protocol RepeatingTimer {
    func start(handler: @escaping () -> Void)
    func stop()
}

final class DefaultRepeatingTimer: RepeatingTimer {
    private var cancellable: AnyCancellable?
    private let interval: TimeInterval

    init(interval: TimeInterval) {
        self.interval = interval
    }

    func start(handler: @escaping () -> Void) {
        handler()
        
        cancellable = Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in handler() }
    }

    func stop() {
        cancellable?.cancel()
        cancellable = nil
    }
}

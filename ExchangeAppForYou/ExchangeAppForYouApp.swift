//
//  ExchangeAppForYouApp.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import SwiftUI

@main
struct ExchangeAppForYouApp: App {
    @StateObject var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            coordinator.buildMainView()
                .environmentObject(coordinator)
        }
    }
}

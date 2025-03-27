//
//  AppCoordinator.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/27/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class AppCoordinator: ObservableObject {
    enum Route: Hashable {
        case currencySearch
    }
    
    @Published var path = NavigationPath()

    private let userDefaultsService = DefaultUserDefaultsService.shared
    private let coreDataStack = PersistanceCoreDataStack.shared
    private let networkService = DefaultNetworkingService()

    private var repository: CurrencyExchangeRepository {
        let crypto = CryptoExchangeGateway(networkingService: networkService)
        let fiat = FiatExchangeGateway(networkingService: networkService)

        return CurrencyExchangeRepositoryImpl(
            cryptoGateway: crypto,
            fiatGateway: fiat,
            coreDataStack: coreDataStack
        )
    }
    
    func showAddCurrency() {
        path.append(Route.currencySearch)
    }

    func buildMainView() -> some View {
        let observeUseCase = ObserveSeletedCurrenciesUseCaseImpl(
            repository: repository,
            repeater: DefaultRepeatingTimer(interval: 60), // 60 seconds between updates due to API limitations
            userDefaultsService: userDefaultsService
        )

        let deleteUseCase = DeleteCurrencyUseCaseImpl(
            userDefaults: userDefaultsService
        )

        let viewModel = MainScreenViewModel(
            observeUseCase: observeUseCase,
            deleteUseCase: deleteUseCase
        )

        return MainScreenView(viewModel: viewModel)
    }

    func buildCurrencySearchView() -> some View {
        let searchUseCase = SearchCurrenciesUseCaseImpl(
            currencyExchangeRepository: repository,
            userDefaultsService: userDefaultsService
        )

        let saveUseCase = SaveSelectedCurrenciesUseCaseImpl(
            userDefaults: userDefaultsService
        )
        
        let listUseCase = GetListOfCurrenciesUseCaseImpl(
            currencyExchangeRepository: repository,
            userDefaultsService: userDefaultsService
        )
            
        let viewModel = CurrencySearchViewModel(
            searchUseCase: searchUseCase,
            saveUseCase: saveUseCase,
            listUseCase: listUseCase
        )

        return CurrencySearchView(viewModel: viewModel)
    }
}

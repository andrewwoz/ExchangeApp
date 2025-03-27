//
//  ObserveSelectedCurrenciesUseCase.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation
import Combine

protocol ObserveSelectedCurrenciesUseCase {
    func observe() -> AnyPublisher<[CurrencyExchangeItem], UserFriendlyError>
}

class ObserveSeletedCurrenciesUseCaseImpl: ObserveSelectedCurrenciesUseCase {
    let repository: CurrencyExchangeRepository
    let repeater: RepeatingTimer
    let userDefaultsService: UserDefaultsService
    
    private let subject = CurrentValueSubject<[CurrencyExchangeItem]?, UserFriendlyError>(nil)
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: CurrencyExchangeRepository, repeater: RepeatingTimer, userDefaultsService: UserDefaultsService) {
        self.repository = repository
        self.repeater = repeater
        self.userDefaultsService = userDefaultsService
    }
    
    func observe() -> AnyPublisher<[CurrencyExchangeItem], UserFriendlyError> {
        repeater.start { [weak self] in
            guard let self = self else { return }
            
            let ids = (try? self.userDefaultsService.read(FavoriteCurrencies())) ?? []
            guard !ids.isEmpty else {
                self.subject.send([])
                self.repeater.stop()
                return
            }
            
            self.repository.getCurrencies(forIDs: ids)
                .mapError { _ in UserFriendlyError(title: "Failed to load", message: "Please try again later.") }
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        self.subject.send(completion: .failure(error))
                    }
                }, receiveValue: { items in
                    self.subject.send(items.sorted { $0.universalId < $1.universalId && $0.quote < $1.quote })
                })
                .store(in: &self.cancellables)
        }
        
        return subject
            .handleEvents(receiveCancel: { [weak self] in
                self?.repeater.stop()
                self?.cancellables.removeAll()
            })
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}

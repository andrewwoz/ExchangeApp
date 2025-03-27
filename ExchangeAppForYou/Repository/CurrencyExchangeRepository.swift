//
//  CurrencyExchangeRepository.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation
import CoreData
import Combine

protocol CurrencyExchangeRepository {
    func getCurrencies() -> AnyPublisher<[CurrencyExchangeItem], GatewayError>
    func getCurrencies(forIDs currencyIDs: [String]) -> AnyPublisher<[CurrencyExchangeItem], GatewayError>
    func search(with term: String) -> AnyPublisher<[CurrencyExchangeItem], GatewayError>
}

final class CurrencyExchangeRepositoryImpl: CurrencyExchangeRepository {
    let cryptoGateway: CurrencyExchangeGateway
    let fiatGateway: CurrencyExchangeGateway
    let coreDataStack: CoreDataStack
    
    init(cryptoGateway: CurrencyExchangeGateway, fiatGateway: CurrencyExchangeGateway, coreDataStack: CoreDataStack) {
        self.cryptoGateway = cryptoGateway
        self.fiatGateway = fiatGateway
        self.coreDataStack = coreDataStack
    }
    
    func getCurrencies() -> AnyPublisher<[CurrencyExchangeItem], GatewayError> {
        Publishers.Zip(
            fiatGateway.getCurrencies(),
            cryptoGateway.getCurrencies()
        )
        .map { fiat, crypto in
            fiat + crypto
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func search(with term: String) -> AnyPublisher<[CurrencyExchangeItem], GatewayError> {
        Publishers.Zip(
            fiatGateway.search(with: term),
            cryptoGateway.search(with: term)
        )
        .map { fiat, crypto in
            fiat + crypto
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func getCurrencies(forIDs currencyIDs: [String]) -> AnyPublisher<[CurrencyExchangeItem], GatewayError> {
        let fiatIDs = currencyIDs
            .filter { $0.hasPrefix(CurrencyType.fiat.rawValue) }
            .map { $0.replacingOccurrences(of: CurrencyType.fiat.rawValue + "_", with: "")}
        let cryptoIDs = currencyIDs
            .filter { $0.hasPrefix(CurrencyType.crypto.rawValue) }
            .map { $0.replacingOccurrences(of: CurrencyType.crypto.rawValue + "_", with: "")}

        let fiatPublisher = fiatGateway.getCurrencies(forIDs: fiatIDs)
        let cryptoPublisher = cryptoGateway.getCurrencies(forIDs: cryptoIDs)

        return Publishers.Zip(fiatPublisher, cryptoPublisher)
            .map { fiat, crypto in
                let merged = fiat + crypto
                self.saveToCoreData(merged)
                return merged
            }
            .catch { [weak self] _ in
                guard let self = self else {
                    return Fail<[CurrencyExchangeItem], GatewayError>(error: .failedToLoad).eraseToAnyPublisher()
                }
                return self.loadFromCoreData(for: fiatIDs + cryptoIDs)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func saveToCoreData(_ items: [CurrencyExchangeItem]) {
        let context = coreDataStack.newBackgroundContext()
        context.perform {
            for item in items {
                let request = CurrencyExchangeCDObject.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", item.id)

                let existing = try? context.fetch(request).first
                let objectToSave = existing ?? CurrencyExchangeCDObject(context: context)
                objectToSave.id = item.id
                objectToSave.base = item.base
                objectToSave.quote = item.quote
                objectToSave.rate = item.rate
            }

            do {
                try context.save()
            } catch {
                print("Saving error: \(error)")
            }
        }
    }
    
    private func loadFromCoreData(for ids: [String]) -> AnyPublisher<[CurrencyExchangeItem], GatewayError> {
        let context = coreDataStack.newBackgroundContext()

        return Future { promise in
            context.perform {
                let request: NSFetchRequest<CurrencyExchangeCDObject> = CurrencyExchangeCDObject.fetchRequest()
                request.predicate = NSPredicate(format: "id IN %@", ids)

                do {
                    let results = try context.fetch(request)
                    let items: [CurrencyExchangeItem] = results.compactMap { object in
                        guard
                            let id = object.id,
                            let base = object.base,
                            let quote = object.quote
                        else { return nil }

                        let type: CurrencyType = id.hasPrefix(CurrencyType.crypto.rawValue) ? .crypto : .fiat
                        return CurrencyExchangeItem(base: base, quote: quote, rate: object.rate, id: id, type: type)
                    }
                    promise(.success(items))
                } catch {
                    promise(.failure(.failedToLoad))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
}

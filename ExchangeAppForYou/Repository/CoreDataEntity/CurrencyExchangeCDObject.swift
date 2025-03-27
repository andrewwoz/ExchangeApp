//
//  CurrencyExchangeCDObject.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//
//

import Foundation
import CoreData

@objc(CurrencyExchangeCDObject)
public class CurrencyExchangeCDObject: NSManagedObject, Identifiable {
    @NSManaged public var id: String?
    @NSManaged public var base: String?
    @NSManaged public var quote: String?
    @NSManaged public var rate: Double
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyExchangeCDObject> {
        return NSFetchRequest<CurrencyExchangeCDObject>(entityName: "CurrencyExchangeCDObject")
    }
}

//
//  Car+CoreDataProperties.swift
//  MyCar
//
//  Created by white4ocolate on 15.12.2023.
//
//

import Foundation
import CoreData


extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var lastStarted: Date?
    @NSManaged public var mark: String?
    @NSManaged public var model: String?
    @NSManaged public var myChoice: Bool
    @NSManaged public var rating: Double
    @NSManaged public var timesDriven: Int16
    @NSManaged public var tintColor: NSObject?

}

extension Car : Identifiable {

}

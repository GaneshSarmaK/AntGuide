//
//  History+CoreDataProperties.swift
//  
//
//  Created by Ganesh on 19/4/20.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var antName: String?
    @NSManaged public var date: Date?
    @NSManaged public var favourite: Bool

}

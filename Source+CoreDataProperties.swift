//
//  Source+CoreDataProperties.swift
//  
//
//  Created by Jayashree on 23/10/18.
//
//

import Foundation
import CoreData


extension Source {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Source> {
        return NSFetchRequest<Source>(entityName: "Source")
    }

    @NSManaged public var source_id: Int64
    @NSManaged public var source_name: String?

}

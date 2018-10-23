//
//  Category+CoreDataProperties.swift
//  
//
//  Created by Jayashree on 23/10/18.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var cat_id: Int64
    @NSManaged public var name: String?

}

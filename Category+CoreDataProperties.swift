//
//  Category+CoreDataProperties.swift
//  
//
//  Created by Jayashree on 28/01/19.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var cat_id: Int16
    @NSManaged public var title: String?

}

//
//  Category+CoreDataProperties.swift
//  
//
//  Created by Jayashri on 22/02/19.
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

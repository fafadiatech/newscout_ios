//
//  Category+CoreDataProperties.swift
//  
//
//  Created by Jayashri on 22/10/18.
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

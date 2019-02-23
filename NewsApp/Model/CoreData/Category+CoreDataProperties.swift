//
//  Category+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 23/02/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
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

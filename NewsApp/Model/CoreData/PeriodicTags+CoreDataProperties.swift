//
//  PeriodicTags+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 09/03/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//
//

import Foundation
import CoreData


extension PeriodicTags {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PeriodicTags> {
        return NSFetchRequest<PeriodicTags>(entityName: "PeriodicTags")
    }

    @NSManaged public var count: Int64
    @NSManaged public var tagName: String?
    @NSManaged public var type: String?

}

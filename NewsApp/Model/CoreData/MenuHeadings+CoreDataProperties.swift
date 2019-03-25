//
//  MenuHeadings+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 09/03/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//
//

import Foundation
import CoreData


extension MenuHeadings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MenuHeadings> {
        return NSFetchRequest<MenuHeadings>(entityName: "MenuHeadings")
    }

    @NSManaged public var headingId: Int64
    @NSManaged public var headingName: String?

}

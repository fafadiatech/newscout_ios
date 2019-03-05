//
//  HeadingSubMenu+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 05/03/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//
//

import Foundation
import CoreData


extension HeadingSubMenu {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HeadingSubMenu> {
        return NSFetchRequest<HeadingSubMenu>(entityName: "HeadingSubMenu")
    }

    @NSManaged public var headingId: Int64
    @NSManaged public var subMenuId: Int64
    @NSManaged public var subMenuName: String?

}

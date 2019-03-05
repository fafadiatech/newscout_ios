//
//  MenuHashTag+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 05/03/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//
//

import Foundation
import CoreData


extension MenuHashTag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MenuHashTag> {
        return NSFetchRequest<MenuHashTag>(entityName: "MenuHashTag")
    }

    @NSManaged public var hashTagId: Int64
    @NSManaged public var hashTagName: String?

}

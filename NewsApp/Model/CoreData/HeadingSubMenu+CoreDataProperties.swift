//
//  HeadingSubMenu+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 06/03/19.
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
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for tags
extension HeadingSubMenu {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: MenuHashTag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: MenuHashTag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

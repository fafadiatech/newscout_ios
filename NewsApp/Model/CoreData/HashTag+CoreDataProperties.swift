//
//  HashTag+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 23/02/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//
//

import Foundation
import CoreData


extension HashTag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HashTag> {
        return NSFetchRequest<HashTag>(entityName: "HashTag")
    }

    @NSManaged public var articleId: Int64
    @NSManaged public var name: String?
    @NSManaged public var tagId: Int64
    @NSManaged public var articleCount: Int64

}

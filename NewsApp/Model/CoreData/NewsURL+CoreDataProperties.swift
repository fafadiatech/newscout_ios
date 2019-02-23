//
//  NewsURL+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 23/02/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//
//

import Foundation
import CoreData


extension NewsURL {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsURL> {
        return NSFetchRequest<NewsURL>(entityName: "NewsURL")
    }

    @NSManaged public var category: String?
    @NSManaged public var nextURL: String?
    @NSManaged public var prevURL: String?

}

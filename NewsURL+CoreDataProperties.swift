//
//  NewsURL+CoreDataProperties.swift
//  
//
//  Created by Jayashri on 22/02/19.
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

//
//  BookmarkArticles+CoreDataProperties.swift
//  
//
//  Created by Jayashree on 28/01/19.
//
//

import Foundation
import CoreData


extension BookmarkArticles {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookmarkArticles> {
        return NSFetchRequest<BookmarkArticles>(entityName: "BookmarkArticles")
    }

    @NSManaged public var article_id: Int16
    @NSManaged public var blurb: String?
    @NSManaged public var category: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var isBookMark: Bool
    @NSManaged public var isLike: Int16
    @NSManaged public var published_on: String?
    @NSManaged public var source: String?
    @NSManaged public var source_url: String?
    @NSManaged public var title: String?

}

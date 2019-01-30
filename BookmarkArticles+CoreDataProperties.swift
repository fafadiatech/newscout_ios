//
//  BookmarkArticles+CoreDataProperties.swift
//  
//
//  Created by Jayashree on 30/01/19.
//
//

import Foundation
import CoreData


extension BookmarkArticles {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookmarkArticles> {
        return NSFetchRequest<BookmarkArticles>(entityName: "BookmarkArticles")
    }

    @NSManaged public var article_id: Int16
    @NSManaged public var isBookmark: Bool
    @NSManaged public var articles: NewsArticle?

}

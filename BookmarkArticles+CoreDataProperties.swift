//
//  BookmarkArticles+CoreDataProperties.swift
//  
//
//  Created by Jayashree on 01/02/19.
//
//

import Foundation
import CoreData


extension BookmarkArticles {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookmarkArticles> {
        return NSFetchRequest<BookmarkArticles>(entityName: "BookmarkArticles")
    }

    @NSManaged public var article_id: Int16
    @NSManaged public var isBookmark: Int16
    @NSManaged public var row_id: Int16
    @NSManaged public var article: NSSet?

}

// MARK: Generated accessors for article
extension BookmarkArticles {

    @objc(addArticleObject:)
    @NSManaged public func addToArticle(_ value: NewsArticle)

    @objc(removeArticleObject:)
    @NSManaged public func removeFromArticle(_ value: NewsArticle)

    @objc(addArticle:)
    @NSManaged public func addToArticle(_ values: NSSet)

    @objc(removeArticle:)
    @NSManaged public func removeFromArticle(_ values: NSSet)

}

//
//  BookmarkArticles+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 28/02/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//
//

import Foundation
import CoreData


extension BookmarkArticles {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookmarkArticles> {
        return NSFetchRequest<BookmarkArticles>(entityName: "BookmarkArticles")
    }

    @NSManaged public var article_id: Int64
    @NSManaged public var isBookmark: Int16
    @NSManaged public var row_id: Int16
    @NSManaged public var article: NSSet?
    @NSManaged public var searchArticle: NSSet?

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

// MARK: Generated accessors for searchArticle
extension BookmarkArticles {

    @objc(addSearchArticleObject:)
    @NSManaged public func addToSearchArticle(_ value: SearchArticles)

    @objc(removeSearchArticleObject:)
    @NSManaged public func removeFromSearchArticle(_ value: SearchArticles)

    @objc(addSearchArticle:)
    @NSManaged public func addToSearchArticle(_ values: NSSet)

    @objc(removeSearchArticle:)
    @NSManaged public func removeFromSearchArticle(_ values: NSSet)

}

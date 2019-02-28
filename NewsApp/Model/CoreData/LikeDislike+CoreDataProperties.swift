//
//  LikeDislike+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 28/02/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//
//

import Foundation
import CoreData


extension LikeDislike {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LikeDislike> {
        return NSFetchRequest<LikeDislike>(entityName: "LikeDislike")
    }

    @NSManaged public var article_id: Int64
    @NSManaged public var isLike: Int16
    @NSManaged public var row_id: Int16
    @NSManaged public var likedArticle: NSSet?
    @NSManaged public var searchlikeArticles: NSSet?

}

// MARK: Generated accessors for likedArticle
extension LikeDislike {

    @objc(addLikedArticleObject:)
    @NSManaged public func addToLikedArticle(_ value: NewsArticle)

    @objc(removeLikedArticleObject:)
    @NSManaged public func removeFromLikedArticle(_ value: NewsArticle)

    @objc(addLikedArticle:)
    @NSManaged public func addToLikedArticle(_ values: NSSet)

    @objc(removeLikedArticle:)
    @NSManaged public func removeFromLikedArticle(_ values: NSSet)

}

// MARK: Generated accessors for searchlikeArticles
extension LikeDislike {

    @objc(addSearchlikeArticlesObject:)
    @NSManaged public func addToSearchlikeArticles(_ value: SearchArticles)

    @objc(removeSearchlikeArticlesObject:)
    @NSManaged public func removeFromSearchlikeArticles(_ value: SearchArticles)

    @objc(addSearchlikeArticles:)
    @NSManaged public func addToSearchlikeArticles(_ values: NSSet)

    @objc(removeSearchlikeArticles:)
    @NSManaged public func removeFromSearchlikeArticles(_ values: NSSet)

}

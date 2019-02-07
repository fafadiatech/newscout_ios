//
//  LikeDislike+CoreDataProperties.swift
//  
//
//  Created by Jayashree on 01/02/19.
//
//

import Foundation
import CoreData


extension LikeDislike {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LikeDislike> {
        return NSFetchRequest<LikeDislike>(entityName: "LikeDislike")
    }

    @NSManaged public var article_id: Int16
    @NSManaged public var isLike: Int16
    @NSManaged public var row_id: Int16
    @NSManaged public var likedArticle: NSSet?

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

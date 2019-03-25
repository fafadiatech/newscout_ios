//
//  NewsArticle+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 09/03/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//
//

import Foundation
import CoreData


extension NewsArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsArticle> {
        return NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
    }

    @NSManaged public var article_id: Int64
    @NSManaged public var blurb: String?
    @NSManaged public var category: String?
    @NSManaged public var current_page: Int64
    @NSManaged public var imageURL: String?
    @NSManaged public var published_on: String?
    @NSManaged public var source: String?
    @NSManaged public var source_url: String?
    @NSManaged public var title: String?
    @NSManaged public var total_pages: Int64
    @NSManaged public var bookmark: BookmarkArticles?
    @NSManaged public var hashTags: NSSet?
    @NSManaged public var likeDislike: LikeDislike?

}

// MARK: Generated accessors for hashTags
extension NewsArticle {

    @objc(addHashTagsObject:)
    @NSManaged public func addToHashTags(_ value: HashTag)

    @objc(removeHashTagsObject:)
    @NSManaged public func removeFromHashTags(_ value: HashTag)

    @objc(addHashTags:)
    @NSManaged public func addToHashTags(_ values: NSSet)

    @objc(removeHashTags:)
    @NSManaged public func removeFromHashTags(_ values: NSSet)

}

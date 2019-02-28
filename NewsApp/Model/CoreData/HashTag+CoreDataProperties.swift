//
//  HashTag+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 28/02/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//
//

import Foundation
import CoreData

extension HashTag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HashTag> {
        return NSFetchRequest<HashTag>(entityName: "HashTag")
    }

    @NSManaged public var name: String?
    @NSManaged public var articleId: Int64
    @NSManaged public var articleTags: NSSet?

}

// MARK: Generated accessors for articleTags
extension HashTag {

    @objc(addArticleTagsObject:)
    @NSManaged public func addToArticleTags(_ value: NewsArticle)

    @objc(removeArticleTagsObject:)
    @NSManaged public func removeFromArticleTags(_ value: NewsArticle)

    @objc(addArticleTags:)
    @NSManaged public func addToArticleTags(_ values: NSSet)

    @objc(removeArticleTags:)
    @NSManaged public func removeFromArticleTags(_ values: NSSet)

}

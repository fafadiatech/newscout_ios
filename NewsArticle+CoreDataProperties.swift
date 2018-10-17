//
//  NewsArticle+CoreDataProperties.swift
//  
//
//  Created by Jayashri on 17/10/18.
//
//

import Foundation
import CoreData


extension NewsArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsArticle> {
        return NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
    }

    @NSManaged public var imageURL: String?
    @NSManaged public var isBookmarked: Bool
    @NSManaged public var isLiked: Bool
    @NSManaged public var news_description: String?
    @NSManaged public var publishedAt: String?
    @NSManaged public var source: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var categories: NSSet?

}

// MARK: Generated accessors for categories
extension NewsArticle {

    @objc(addCategoriesObject:)
    @NSManaged public func addToCategories(_ value: Category)

    @objc(removeCategoriesObject:)
    @NSManaged public func removeFromCategories(_ value: Category)

    @objc(addCategories:)
    @NSManaged public func addToCategories(_ values: NSSet)

    @objc(removeCategories:)
    @NSManaged public func removeFromCategories(_ values: NSSet)

}

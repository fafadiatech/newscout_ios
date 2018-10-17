//
//  Category+CoreDataProperties.swift
//  
//
//  Created by Jayashri on 17/10/18.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var cat_id: Int16
    @NSManaged public var title: String?
    @NSManaged public var newsArticle: NSSet?

}

// MARK: Generated accessors for newsArticle
extension Category {

    @objc(addNewsArticleObject:)
    @NSManaged public func addToNewsArticle(_ value: NewsArticle)

    @objc(removeNewsArticleObject:)
    @NSManaged public func removeFromNewsArticle(_ value: NewsArticle)

    @objc(addNewsArticle:)
    @NSManaged public func addToNewsArticle(_ values: NSSet)

    @objc(removeNewsArticle:)
    @NSManaged public func removeFromNewsArticle(_ values: NSSet)

}

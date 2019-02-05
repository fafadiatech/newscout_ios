//
//  NewsArticle+CoreDataProperties.swift
//  
//
//  Created by Jayashree on 05/02/19.
//
//

import Foundation
import CoreData


extension NewsArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsArticle> {
        return NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
    }

    @NSManaged public var article_id: Int16
    @NSManaged public var blurb: String?
    @NSManaged public var category: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var published_on: String?
    @NSManaged public var source: String?
    @NSManaged public var source_url: String?
    @NSManaged public var title: String?
    @NSManaged public var category_id: Int16
    @NSManaged public var bookmark: BookmarkArticles?
    @NSManaged public var likeDislike: LikeDislike?

}

//
//  NewsArticle+CoreDataProperties.swift
//  
//
//  Created by Jayashri on 16/10/18.
//
//

import Foundation
import CoreData


extension NewsArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsArticle> {
        return NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
    }

    @NSManaged public var source: String?
    @NSManaged public var title: String?
    @NSManaged public var news_description: String?
    @NSManaged public var url: String?
    @NSManaged public var publishedAt: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var isLiked: Bool
    @NSManaged public var isBookmarked: Bool

}

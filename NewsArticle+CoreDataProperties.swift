//
//  NewsArticle+CoreDataProperties.swift
//  
//
//  Created by Jayashree on 23/10/18.
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
    @NSManaged public var category_id: Int64
    @NSManaged public var imageURL: String?
    @NSManaged public var news_description: String?
    @NSManaged public var published_on: String?
    @NSManaged public var source_id: Int64
    @NSManaged public var source_url: String?
    @NSManaged public var title: String?

}

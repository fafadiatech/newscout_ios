//
//  RecommendationID+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 15/04/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//
//

import Foundation
import CoreData


extension RecommendationID {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecommendationID> {
        return NSFetchRequest<RecommendationID>(entityName: "RecommendationID")
    }

    @NSManaged public var articleID: Int64
    @NSManaged public var recomArticleID: Int64

}

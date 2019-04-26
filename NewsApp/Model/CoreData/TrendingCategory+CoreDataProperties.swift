//
//  TrendingCategory+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 26/04/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//
//

import Foundation
import CoreData


extension TrendingCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrendingCategory> {
        return NSFetchRequest<TrendingCategory>(entityName: "TrendingCategory")
    }

    @NSManaged public var articleID: Int64
    @NSManaged public var trendingID: Int64
    @NSManaged public var count: Int64

}

//
//  Trending+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashri on 16/04/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//
//

import Foundation
import CoreData


extension TrendingCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrendingCategory> {
        return NSFetchRequest<TrendingCategory>(entityName: "TrendingCategory")
    }

    @NSManaged public var trendingID: Int64
    @NSManaged public var articleID: Int64

}

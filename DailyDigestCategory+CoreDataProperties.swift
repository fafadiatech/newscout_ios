//
//  DailyDigestCategory+CoreDataProperties.swift
//  
//
//  Created by Prasen on 19/02/20.
//
//

import Foundation
import CoreData


extension DailyDigestCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyDigestCategory> {
        return NSFetchRequest<DailyDigestCategory>(entityName: "DailyDigestCategory")
    }

    @NSManaged public var article_id: Int64
    @NSManaged public var published_on: String?

}

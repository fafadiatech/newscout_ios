//
//  DailyDigest+CoreDataProperties.swift
//  
//
//  Created by Prasen on 19/02/20.
//
//

import Foundation
import CoreData


extension DailyDigest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyDigest> {
        return NSFetchRequest<DailyDigest>(entityName: "DailyDigest")
    }

    @NSManaged public var article_id: Int64
    @NSManaged public var published_on: String?

}

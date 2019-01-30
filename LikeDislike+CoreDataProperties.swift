//
//  LikeDislike+CoreDataProperties.swift
//  
//
//  Created by Jayashree on 30/01/19.
//
//

import Foundation
import CoreData


extension LikeDislike {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LikeDislike> {
        return NSFetchRequest<LikeDislike>(entityName: "LikeDislike")
    }

    @NSManaged public var article_id: Int16
    @NSManaged public var isLike: Int16

}

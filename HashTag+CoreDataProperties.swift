//
//  HashTag+CoreDataProperties.swift
//  
//
//  Created by Jayashri on 22/02/19.
//
//

import Foundation
import CoreData


extension HashTag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HashTag> {
        return NSFetchRequest<HashTag>(entityName: "HashTag")
    }

    @NSManaged public var articleId: Int64
    @NSManaged public var name: String?

}

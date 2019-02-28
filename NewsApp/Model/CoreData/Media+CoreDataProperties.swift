//
//  Media+CoreDataProperties.swift
//  NewsApp
//
//  Created by Jayashree on 28/02/19.
//  Copyright © 2019 Fafadia Tech. All rights reserved.
//
//

import Foundation
import CoreData


extension Media {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Media> {
        return NSFetchRequest<Media>(entityName: "Media")
    }

    @NSManaged public var articleId: Int64
    @NSManaged public var imageURL: String?
    @NSManaged public var mediaId: Int64
    @NSManaged public var type: String?
    @NSManaged public var videoURL: String?

}

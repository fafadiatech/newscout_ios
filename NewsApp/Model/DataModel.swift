//
//  DataModel.swift
//  NewsApp
//
//  Created by Jayashree on 08/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import Foundation

struct ArticleStatus : Decodable
{
    let articles : [Article]
}

struct Article: Decodable
{
    //let categories: [String]?
    let article_id : Int64?
    let category_id : Int64?
    let subCategory_id: Int64?
    let source_id: Int64?
    let description : String?
    let title : String?
    let imageURL : String?
    let url : String?
    let published_on : String?
    let blurb : String?
    
    enum CodingKeys: String, CodingKey{
        case article_id = "id"
        case category_id = "category"
        case source_id = "source"
        case imageURL = "cover_image"
        case url = "source_url"
        case subCategory_id = "sub_category"
        case description = "full_text"
        case title
        case published_on
        case blurb
    }
}

struct ArticleDetails: Decodable
{
    let article : ArticleDict 
}

struct ArticleDict: Decodable{
    let article_id : Int64?
    let category_id : Int64?
    let source_id: Int64?
    let description : String?
    let title : String?
    let imageURL : String?
    let url : String?
    let published_on : String?
    let blurb : String?
    
    enum CodingKeys: String, CodingKey{
        case article_id = "id"
        case category_id = "category"
        case source_id = "source"
        case imageURL = "cover_image"
        case url = "source_url"
        case description = "full_text"
        case title
        case published_on
        case blurb
    }
}

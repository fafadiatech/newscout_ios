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

struct CategoryList: Decodable
{
    let categories : [CategoryDetails]
}

struct CategoryDetails : Decodable
{
    let cat_id: Int64?
    let name: String?
    
    enum CodingKeys: String, CodingKey{
        case cat_id = "id"
        case name
    }
}

struct ArticleDetails
{
    let article : [String: Any]?
}

struct article: Decodable{
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

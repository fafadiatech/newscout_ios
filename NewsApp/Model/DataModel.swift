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
    let category : String?
    let source: String?
    let title : String?
    let imageURL : String?
    let url : String?
    let published_on : String?
    let blurb : String?
    
    enum CodingKeys: String, CodingKey{
        case article_id = "id"
        case imageURL = "cover_image"
        case url = "source_url"
        case category
        case source
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
    let category : String?
    let source: String?
    let title : String?
    let imageURL : String?
    let url : String?
    let published_on : String?
    let blurb : String?
    
    enum CodingKeys: String, CodingKey{
        case article_id = "id"
        case imageURL = "cover_image"
        case url = "source_url"
        case source
        case category
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
    let title: String?
    
    enum CodingKeys: String, CodingKey{
        case cat_id = "id"
        case title = "name"
    }
}

enum ArticleAPIResult {
    case Success([ArticleStatus])
    case Failure(String)
}

enum ArticleDBfetchResult {
    case Success([NewsArticle])
    case Failure(String)
}
enum CategoryAPIResult {
    case Success([CategoryList])
    case Failure(String)
}
enum CategoryDBfetchResult {
    case Success([Category])
    case Failure(String)
}

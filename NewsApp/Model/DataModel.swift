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
    // let articles : [Article]
    let header : Header
    var body: articleBody
    
}
struct articleBody : Decodable
{
    let count :  Int?
    let next : String?
    let previous : String?
    var articles : [Article]
    
    enum CodingKeys: String, CodingKey{
        case articles = "results"
        case count
        case next
        case previous
    }
}
struct Article: Decodable
{
    let article_id : Int?
    let category : String?
    let source: String?
    let title : String?
    let imageURL : String?
    let url : String?
    let published_on : String?
    let blurb : String?
    var isBookmark : Bool?
    var isLike : Int?
    
    enum CodingKeys: String, CodingKey{
        case article_id = "id"
        case imageURL = "cover_image"
        case url = "source_url"
        case category
        case source
        case title
        case published_on
        case blurb
        case isBookmark = "isBookMark"
        case isLike
    }
}
//for news detail
struct ArticleDetails: Decodable
{
    let header : Header
    let body :  DetailedArticle
}
struct DetailedArticle : Decodable{
    let article : ArticleDict
}
struct ArticleDict: Decodable{
    let article_id : Int?
    let category : String?
    let source: String?
    let title : String?
    let imageURL : String?
    let url : String?
    let published_on : String?
    let blurb : String?
    let isBookmark : Bool?
    let isLike : Int?
    
    enum CodingKeys: String, CodingKey{
        case article_id = "id"
        case imageURL = "cover_image"
        case url = "source_url"
        case source
        case category
        case title
        case published_on
        case blurb
        case isBookmark = "isBookMark"
        case isLike
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

struct MainModel: Decodable
{
    let header : Header
    let errors: ErrorList?
    let body: Body?
}

struct Header : Decodable
{
    let status: String
}

struct ErrorList : Decodable
{
    let errorList : [ErrorItem]?
    let invalid_credentials : String?
    let Msg : String?
}

struct ErrorItem : Decodable
{
    let field: String
    let field_error : String
}
struct Body : Decodable{
    //signup
    let Msg : String?
    //login
    let token : String?
    let user_id : Int?
    let first_name : String?
    let last_name : String?
    
}

enum MainModelError {
    case Failure(String)
}
enum ArticleAPIResult {
    case Success([ArticleStatus])
    case Failure(String)
    case Change(Int)
}

enum ArticleDetailAPIResult {
    case Success(ArticleDetails)
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
enum SaveRemoveCategoryResult {
    case Success(String)
    case Failure(String)
}

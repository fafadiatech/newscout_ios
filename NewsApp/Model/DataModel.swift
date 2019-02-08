//
//  DataModel.swift
//  NewsApp
//
//  Created by Jayashree on 08/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import Foundation
import CoreData

struct ArticleStatus : Decodable{
    let header : Header
    var body: articleBody?
    var errors : ErrorList?
}

struct articleBody : Decodable{
    let count :  Int?
    let next : String?
    let previous : String?
    var articles : [Article]
    var categoryDetail : CategoryDetails?
    
    enum CodingKeys: String, CodingKey{
        case articles = "results"
        case count
        case next
        case previous
        case categoryDetail = "category"
    }
}

struct Article: Decodable{
    var article_id : Int!
    var category : String?
    var source: String?
    var title : String?
    var imageURL : String?
    var url : String?
    var published_on : String?
    var blurb : String?
    
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

//for news detail
struct ArticleDetails: Decodable{
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

struct CategoryList: Decodable{
    let categories : [CategoryDetails]
}

struct CategoryDetails : Decodable{
    let cat_id: Int64?
    let title: String?
    
    enum CodingKeys: String, CodingKey{
        case cat_id = "id"
        case title = "name"
    }
}

struct MainModel: Decodable{
    let header : Header
    let errors: ErrorList?
    let body: Body?
}

struct Header : Decodable{
    let status: String
}

struct ErrorList : Decodable{
    let errorList : [ErrorItem]?
    let invalid_credentials : String?
    let Msg : String?
}

struct ErrorItem : Decodable{
    let field: String
    let field_error : String
}

struct User : Decodable{
    let token : String?
    let user_id : Int?
    let first_name : String?
    let last_name : String?
    let passion: [Passion]?
    
    enum CodingKeys: String, CodingKey{
        case user_id = "id"
        case token = "token"
        case first_name = "first_name"
        case last_name = "last_name"
        case passion = "passion"
    }
}

struct  Passion: Decodable {
    let id : Int
    let name : String
}

struct Body : Decodable{
    let Msg : String?
    let user: User?
    let listResult: [LikeBookmarkList]?
    
    enum CodingKeys: String, CodingKey{
        case Msg = "Msg"
        case user =  "user"
        case listResult = "results"
    }
}

struct GetLikeBookmarkList: Decodable{
    let header : Header
    let body : Body?
    let errors : ErrorList?
}
struct LikeBookmarkList: Decodable{
    let row_id: Int
    let article_id: Int
    let isLike : Int?
    let status : Int?
    
    enum CodingKeys: String, CodingKey{
        case row_id = "id"
        case article_id = "article"
        case isLike = "is_like"
        case status = "status"
    }
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

enum BookmarkArticleDBfetchResult {
    case Success([BookmarkArticles])
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

enum LikeBookmarkListAPIResult {
    case Success(GetLikeBookmarkList)
    case Failure(String)
}
enum SearchDBfetchResult {
    case Success([SearchArticles])
    case Failure(String)
}

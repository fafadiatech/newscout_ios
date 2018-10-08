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
    let status : String
    let totalResults : Int
    let articles : [Article]
}

struct Article: Decodable
{
    let topics: [String]
    let categories: String
    let source: String?
    let author: String?
    let description : String?
    let title : String?
    let urlToImage : String?
    let url : String?
    let publishedAt : String?
    let isBookmarked : Bool?
}

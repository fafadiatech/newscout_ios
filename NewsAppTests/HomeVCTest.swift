//
//  HomeVCTest.swift
//  NewsAppTests
//
//  Created by Jayashree on 28/11/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import Foundation
import XCTest
import Alamofire

@testable import NewsApp

class HomeVCTest: XCTestCase{
     var homeObj = HomeVC()
    
    func testNewsBycategoryAPI(){
        let url = "http://192.168.2.204/api/v1/articles/?categories=" + homeObj.selectedCategory
        let expectedURL = APPURL.ArticlesByCategoryURL + homeObj.selectedCategory
        XCTAssertEqual(url, expectedURL)
        
    }
    }


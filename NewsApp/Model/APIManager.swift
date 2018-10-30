//
//  APIManager.swift
//  NewsApp
//
//  Created by Jayashree on 23/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import SwiftyJSON

class APICall{
    //API call to load all articles on HomeVC
    func loadNewsAPI(_ completion : @escaping (ArticleAPIResult) -> ()){
        let url = APPURL.ArticlesURL
        
        Alamofire.request(url,method: .get).responseJSON{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                        completion(ArticleAPIResult.Success([jsonData]))
                    }
                    catch {
                        print("Error: \(error)")
                        completion(ArticleAPIResult.Failure(error as! String))
                    }
                }
            }
        }
    }
    
    func loadCategoriesAPI(_ completion : @escaping (CategoryAPIResult) -> ()){
        let url = APPURL.CategoriesURL
        
        Alamofire.request(url,method: .get).responseJSON{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(CategoryList.self, from: data)
                        completion(CategoryAPIResult.Success([jsonData]))
                    }
                    catch {
                        print("Error: \(error)")
                        completion(CategoryAPIResult.Failure(error as! String))
                    }
                }
            }
        }
    }
    
    func loadSearchAPI(searchTxt: String,_ completion : @escaping (ArticleAPIResult) -> ())
    {
        let url = APPURL.SearchURL + searchTxt
        Alamofire.request(url,method: .get).responseJSON{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                        print(jsonData)
                        completion(ArticleAPIResult.Success([jsonData]))
                    }
                    catch {
                        print("Error: \(error)")
                        completion(ArticleAPIResult.Failure(error as! String))
                    }
                }
            }
        }
    }
    
    //Signup API
    func SignupAPI(fname : String, lname : String, email: String, pswd: String,_ completion : @escaping (String) ->()) {
        let url = APPURL.SignUpURL
        let param = ["first_name": fname,
                     "last_name": lname,
                     "email" : email,
                     "password" : pswd]
        
        Alamofire.request(url,method: .post, parameters: param).responseJSON{
            response in
            if(response.result.isSuccess){
                let output = JSON(response.result.value!)
                if(output["header"]["status"] == "1"){
                    completion(output["body"]["Msg"].stringValue)
                }
                else{
                    output["errors"]["error_list"] as? [[String: Any]]
                    completion(output["errors"]["errorList"].stringValue)
                }
            }
        }
    }
}

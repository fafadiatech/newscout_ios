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
                        completion(ArticleAPIResult.Failure(error.localizedDescription
                        ))
                    }
                }
            }
        }
    }
    
    func loadRecommendationNewsAPI(_ completion : @escaping (ArticleAPIResult) -> ()){
        let url = APPURL.recommendationURL
        print(url)
        Alamofire.request(url,method: .post).responseJSON{
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
                        completion(ArticleAPIResult.Failure(error.localizedDescription
                        ))
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
        print(param)
        Alamofire.request(url,method: .post, parameters: param).responseString{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(MainModel.self, from: data)
                        print(jsonData)
                        if jsonData.header.status == "0"{
                            completion(jsonData.errors!.errorList![0].field_error)
                        }
                        else{
                            completion(jsonData.body!.Msg!)
                        }
                    }
                    catch {
                        print("Error: \(error)")
                    }
                }
            }
            else{
                print(response.result.error!)
            }
        }
    }
    
    //Login API
    func LoginAPI(email : String, pswd : String,_ completion : @escaping (String) ->()) {
        let url = APPURL.LoginURL
        let param = ["email" : email,
                     "password" : pswd]
        print(param)
        Alamofire.request(url,method: .post, parameters: param).responseString{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(MainModel.self, from: data)
                        print(jsonData)
                        if jsonData.header.status == "0"{
                            completion(jsonData.errors!.invalid_credentials!)
                        }
                        else{
                            UserDefaults.standard.set(jsonData.body?.first_name, forKey: "first_name")
                            UserDefaults.standard.set(jsonData.body?.last_name, forKey: "last_name")
                            UserDefaults.standard.set(jsonData.body?.token, forKey: "token")
                            UserDefaults.standard.set(jsonData.body?.user_id, forKey: "user_id")
                             UserDefaults.standard.set(email, forKey: "email")
                            completion("successfully logged in ..")
                        }
                    }
                    catch {
                        print("Error: \(error)")
                    }
                }
            }
            else{
                print(response.result.error!)
            }
        }
    }
    
}

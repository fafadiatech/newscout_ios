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

extension URLResponse {
    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}

class APICall{
    let imageCache = NSCache<NSString, UIImage>()
    
    //API call to load all articles on HomeVC
    func loadNewsAPI(page: Int, _ completion : @escaping (ArticleAPIResult) -> ()){
        let url = APPURL.ArticlesURL + "\(page)"
        Alamofire.request(url,method: .get).responseString{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                        completion(ArticleAPIResult.Success([jsonData]))
                    }
                    catch {
                        completion(ArticleAPIResult.Failure(error.localizedDescription
                        ))
                    }
                }
            }
        }
    }
    //load articles by category
    func loadNewsbyCategoryAPI(url: String, _ completion : @escaping (String, ArticleAPIResult) -> ()){
        var headers : [String: String]
        if UserDefaults.standard.value(forKey: "token") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "token")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "googleToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "googleToken")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "FBToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "FBToken")!)"
            headers = ["Authorization": token]
        }
        else{
            headers = ["Authorization": ""]
        }
        let newurl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        Alamofire.request(newurl,method: .get, headers: headers).responseString{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                     let jsonDecoder = JSONDecoder()
                    do {
                        if response.response?.statusCode == 404{
                            completion("error 404",ArticleAPIResult.Change(404))
                        }
                        else{
                            let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                            completion(String((response.response?.statusCode)!), ArticleAPIResult.Success([jsonData]))
                        }
                    }
                    catch {
                        completion(String((response.response?.statusCode)!), ArticleAPIResult.Failure(error.localizedDescription))
                    }
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion("no net", ArticleAPIResult.Failure(err.localizedDescription))
                }
                else{
                    let err = response.result.error as? URLError
                    print(err)
                }
            }
        }
    }
    
    func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
        }
    }
    
    func loadRecommendationNewsAPI(articleId : Int,_ completion : @escaping (String, ArticleAPIResult) -> ()){
        let url = APPURL.recommendationURL + "\(articleId)" + "/recommendations/"
        Alamofire.request(url,method: .post).responseJSON{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                        completion(String((response.response?.statusCode)!),ArticleAPIResult.Success([jsonData]))
                    }
                    catch {
                        completion(String((response.response?.statusCode)!), ArticleAPIResult.Failure(error.localizedDescription))
                    }
                }
                
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion("no net", ArticleAPIResult.Failure(err.localizedDescription))
                }
                else{
                    completion(String((response.response?.statusCode)!), ArticleAPIResult.Failure("\(String(describing: response.response?.statusCode))"))
                }
            }
        }
    }
    
    func loadCategoriesAPI(_ completion : @escaping (Int, CategoryAPIResult) -> ()){
        let url = APPURL.CategoriesURL
        Alamofire.request(url,method: .get).responseJSON{
            response in
            if(response.result.isSuccess){
                if response.response?.statusCode == 200{
                    if let data = response.data {
                        let jsonDecoder = JSONDecoder()
                        do {
                            let jsonData = try jsonDecoder.decode(CategoryList.self, from: data)
                            
                            completion((response.response?.statusCode)!, CategoryAPIResult.Success([jsonData]))
                        }
                        catch {
                            completion((response.response?.statusCode)!, CategoryAPIResult.Failure(error as! String))
                        }
                    }
                }
                else{
                    completion((response.response?.statusCode)!, CategoryAPIResult.Failure(""))
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion(0, CategoryAPIResult.Failure(Constants.InternetErrorMsg))
                }
            }
        }
    }
    
    func loadSearchAPI(url: String,_ completion : @escaping (String, ArticleAPIResult) -> ()){
        Alamofire.request(url,method: .get, encoding: URLEncoding.default).responseJSON{
            response in
            if(response.result.isSuccess){
                //if response.response?.statusCode == 200{
                if let data = response.data {
                    let  jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                        if jsonData.header.status == "0" {
                            completion(String((response.response?.statusCode)!), ArticleAPIResult.Failure((jsonData.errors?.Msg)!))
                        }else{
                            completion(String((response.response?.statusCode)!), ArticleAPIResult.Success([jsonData]))
                        }
                    }
                    catch {
                        completion(String((response.response?.statusCode)!), ArticleAPIResult.Failure(error as! String))
                    }
                }
                    // }
                else{
                    completion(String((response.response?.statusCode)!), ArticleAPIResult.Failure("\(response.response?.statusCode)"))
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion("no net", ArticleAPIResult.Failure(err.localizedDescription))
                }
            }
        }
    }
    
    //Signup API
    func SignupAPI(param : Dictionary<String, String>, _ completion : @escaping (String, String) ->()) {
        let url = APPURL.SignUpURL
        Alamofire.request(url,method: .post, parameters: param).responseString{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(MainModel.self, from: data)
                        if jsonData.header.status == "0"{
                            completion(String((response.response?.statusCode)!),jsonData.errors!.errorList![0].field_error)
                        }
                        else{
                            completion(String((response.response?.statusCode)!), jsonData.body!.Msg!)
                        }
                        
                    }
                    catch {
                        completion("0",error.localizedDescription)
                    }
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion("no net", Constants.InternetErrorMsg)
                }
            }
        }
    }
    
    //Login API
    func LoginAPI(param : Dictionary<String, String>,_ completion : @escaping (Int , String) ->()) {
        let url = APPURL.LoginURL
        var categories : [String] = []
        Alamofire.request(url,method: .post, parameters: param).responseString{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(MainModel.self, from: data)
                        if jsonData.header.status == "0"{
                            if jsonData.errors?.invalid_credentials != nil{
                                completion((response.response?.statusCode)!, (jsonData.errors?.invalid_credentials)!)
                            }
                            else{
                                completion((response.response?.statusCode)!, (jsonData.errors?.errorList![0].field_error)!)
                            }
                        }
                        else{
                            UserDefaults.standard.removeObject(forKey: "categories")
                            UserDefaults.standard.synchronize()
                            categories = ["For You"]
                            UserDefaults.standard.setValue(categories, forKey: "categories")
                            for cat in (jsonData.body?.user?.passion)!{
                                categories.append(cat.name)
                            }
                            UserDefaults.standard.setValue(categories, forKey: "categories")
                            UserDefaults.standard.set(jsonData.body!.user!.token, forKey: "token")
                            UserDefaults.standard.set(jsonData.body!.user!.first_name, forKey: "first_name")
                            UserDefaults.standard.set(jsonData.body!.user!.last_name, forKey: "last_name")
                            UserDefaults.standard.set(jsonData.body!.user!.user_id, forKey: "user_id")
                            UserDefaults.standard.set(param["email"], forKey: "email")
                            completion((response.response?.statusCode)!, jsonData.header.status)
                        }
                    }
                    catch {
                        completion(0,error.localizedDescription)
                    }
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion(0,Constants.InternetErrorMsg)
                }
            }
        }
    }
    
    //Logout API
    func LogoutAPI(_ completion : @escaping (String, String) ->()) {
        let url = APPURL.LogoutURL
        var headers : [String: String]
        if UserDefaults.standard.value(forKey: "token") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "token")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "googleToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "googleToken")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "FBToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "FBToken")!)"
            headers = ["Authorization": token]
        }
        else{
            headers = ["Authorization": ""]
        }
        
        Alamofire.request(url,method: .get, parameters: nil, headers: headers).responseString{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(MainModel.self, from: data)
                        if jsonData.header.status == "0"{
                            completion(jsonData.header.status,jsonData.errors!.Msg!)
                        }
                        else{
                            let defaultList = ["token", "first_name", "last_name", "user_id", "email"]
                            Helper().clearDefaults(list : defaultList)
                            var categoryList : [String] = []
                            
                            categoryList = UserDefaults.standard.value(forKey: "categories") as! [String]
                            categoryList.remove(at: 0)
                            if !categoryList.contains("Trending"){
                                categoryList.insert("Trending", at: 0)
                            }
                            UserDefaults.standard.setValue(categoryList, forKey: "categories")
                            completion(jsonData.header.status,jsonData.body!.Msg!)
                        }
                    }
                    catch {
                        completion("0", error.localizedDescription)
                    }
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion("0",Constants.InternetErrorMsg)
                }
            }
        }
    }
    
    //bookmark API
    func bookmarkAPI(id : Int, _ completion : @escaping (String, String) -> ()){
        let url = APPURL.bookmarkURL
        let param = ["article_id" : id]
        var headers : [String: String]
        if UserDefaults.standard.value(forKey: "token") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "token")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "googleToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "googleToken")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "FBToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "FBToken")!)"
            headers = ["Authorization": token]
        }
        else{
            headers = ["Authorization": ""]
        }
        
        Alamofire.request(url,method: .post, parameters: param, headers: headers).responseJSON{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(MainModel.self, from: data)
                        if jsonData.header.status == "1"{
                            completion(jsonData.header.status,(jsonData.body?.Msg)!)
                        }else{
                            completion(jsonData.header.status,(jsonData.errors?.Msg)!)
                        }
                    }
                    catch {
                        completion("0", error.localizedDescription)
                    }
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion("0", Constants.InternetErrorMsg)
                }
            }
        }
    }
    
    // Like/dislike API
    func LikeDislikeAPI(param : Dictionary<String, Int>, _ completion : @escaping (String, String) -> ()){
        let url = APPURL.likeDislikeURL
        var headers : [String: String]
        if UserDefaults.standard.value(forKey: "token") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "token")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "googleToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "googleToken")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "FBToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "FBToken")!)"
            headers = ["Authorization": token]
        }
        else{
            headers = ["Authorization": ""]
        }
        Alamofire.request(url,method: .post, parameters: param, headers: headers).responseJSON{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(MainModel.self, from: data)
                        if jsonData.header.status == "1"{
                            completion(jsonData.header.status, (jsonData.body?.Msg)!)
                        }else{
                            completion(jsonData.header.status, (jsonData.errors?.Msg)!)
                        }
                    }
                    catch {
                        completion("0", error.localizedDescription)
                    }
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion("0", Constants.InternetErrorMsg)
                }
            }
        }
    }
    
    //Forgot Password
    func ForgotPasswordAPI(email: String,_ completion : @escaping (String, String) ->()) {
        let url = APPURL.forgotPasswordURL
        let param = ["email" : email]
        
        Alamofire.request(url,method: .post, parameters: param).responseString{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(MainModel.self, from: data)
                        if jsonData.header.status == "0"{
                            completion(jsonData.header.status, jsonData.errors!.Msg!)
                        }
                        else{
                            completion(jsonData.header.status, (jsonData.body?.Msg)!)
                        }
                    }
                    catch {
                        completion("0", error.localizedDescription)
                    }
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion("No internet", Constants.InternetErrorMsg)
                }
            }
        }
    }
    
    //Change Password
    func ChangePasswordAPI(param : Dictionary<String, String>, _ completion : @escaping (String, String) ->()) {
        let url = APPURL.changePasswordURL
        var headers : [String: String]
        if UserDefaults.standard.value(forKey: "token") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "token")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "googleToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "googleToken")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "FBToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "FBToken")!)"
            headers = ["Authorization": token]
        }
        else{
            headers = ["Authorization": ""]
        }
        Alamofire.request(url,method: .post, parameters: param, headers: headers).responseString{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(MainModel.self, from: data)
                        if jsonData.header.status == "0"{
                            completion(jsonData.header.status, jsonData.errors!.Msg!)
                        }
                        else{
                            completion(jsonData.header.status, (jsonData.body?.Msg)!)
                        }
                    }
                    catch {
                        completion("0", error.localizedDescription)
                    }
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion("0", Constants.InternetErrorMsg)
                }
            }
        }
    }
    
    //get list of bookmarked articles
    func BookmarkedArticlesAPI(url: String,_ completion : @escaping (ArticleAPIResult) -> ()) {
        
        var headers : [String: String]
        if UserDefaults.standard.value(forKey: "token") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "token")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "googleToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "googleToken")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "FBToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "FBToken")!)"
            headers = ["Authorization": token]
        }
        else{
            headers = ["Authorization": ""]
        }
        Alamofire.request(url,method: .get,headers: headers).responseString{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                        completion(ArticleAPIResult.Success([jsonData]))
                    }
                    catch {
                        completion(ArticleAPIResult.Failure(error.localizedDescription
                        ))
                    }
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion(ArticleAPIResult.Failure(Constants.InternetErrorMsg))
                }
            }
        }
    }
    
    func articleDetailAPI(articleId : Int,_ completion : @escaping (String, ArticleDetailAPIResult) -> ()){
        var headers : [String: String]
        if UserDefaults.standard.value(forKey: "token") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "token")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "googleToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "googleToken")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "FBToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "FBToken")!)"
            headers = ["Authorization": token]
        }
        else{
            headers = ["Authorization": ""]
        }
        let url = APPURL.ArticleDetailURL + "\(articleId)"
        Alamofire.request(url,method: .get, headers: headers).responseJSON{
            response in
            if(response.result.isSuccess){
                if response.response?.statusCode == 200{
                    if let data = response.data {
                        let jsonDecoder = JSONDecoder()
                        do {
                            let jsonData = try jsonDecoder.decode(ArticleDetails.self, from: data)
                            completion(String((response.response?.statusCode)!),ArticleDetailAPIResult.Success(jsonData))
                        }
                        catch {
                            completion(String((response.response?.statusCode)!), ArticleDetailAPIResult.Failure(error.localizedDescription))
                        }
                    }
                } else{
                    completion(String((response.response?.statusCode)!), ArticleDetailAPIResult.Failure("\(String(describing: response.response?.statusCode))"))
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion("no net", ArticleDetailAPIResult.Failure(err.localizedDescription))
                }
            }
        }
    }
    
    //save and remove category (user specific)
    func saveRemoveCategoryAPI(category: String,type: String,_ completion : @escaping (SaveRemoveCategoryResult) -> ()){
        var headers : [String: String]
        var method : HTTPMethod
        if UserDefaults.standard.value(forKey: "token") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "token")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "googleToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "googleToken")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "FBToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "FBToken")!)"
            headers = ["Authorization": token]
        }
        else{
            headers = ["Authorization": ""]
        }
        
        let url = APPURL.saveRemoveCategoryURL
        let param = ["category" : category]
        if type == "save"{
            method = .post
        }
        else{
            method = .delete
        }
        Alamofire.request(url,method: method, parameters: param,encoding: URLEncoding.httpBody, headers: headers).responseString{
            response in
            if(response.result.isSuccess){
                
                if let data = response.data {
                    let  jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(MainModel.self, from: data)
                        
                        if jsonData.header.status == "1" {
                            completion(SaveRemoveCategoryResult.Success((jsonData.body?.Msg)!))
                        }
                        else{
                            var error_msg = ""
                            if response.response?.statusCode == 400{
                                error_msg = (jsonData.errors?.Msg)!
                            }
                            else if response.response?.statusCode == 404{
                                error_msg = (jsonData.errors!.invalid_credentials!)
                            }
                            completion(SaveRemoveCategoryResult.Failure(error_msg))
                        }
                    }
                    catch {
                        completion(SaveRemoveCategoryResult.Failure(("error")))
                    }
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion(SaveRemoveCategoryResult.Failure(err.localizedDescription))
                }
            }
        }
    }
    
    func getLikeBookmarkList(url: String, _ completion : @escaping (LikeBookmarkListAPIResult) -> ()){
        
        var headers : [String: String]
        if UserDefaults.standard.value(forKey: "token") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "token")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "googleToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "googleToken")!)"
            headers = ["Authorization": token]
        }
        else if UserDefaults.standard.value(forKey: "FBToken") != nil{
            let token = "Token " + "\(UserDefaults.standard.value(forKey: "FBToken")!)"
            headers = ["Authorization": token]
        }
        else{
            headers = ["Authorization": ""]
        }
        
        Alamofire.request(url,method: .get,headers: headers).responseJSON{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(GetLikeBookmarkList.self, from: data)
                        completion(LikeBookmarkListAPIResult.Success(jsonData))
                    }
                    catch {
                        completion(LikeBookmarkListAPIResult.Failure(error.localizedDescription
                        ))
                    }
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion(LikeBookmarkListAPIResult.Failure(Constants.InternetErrorMsg))
                }
            }
        }
    }
    
    //get daily,weekly and monthly tags
    func getTags(url : String,type : String, _ completion : @escaping (DailyTagAPIResult) ->()){
        let param = [type : 1]
        Alamofire.request(url,method: .get, parameters: param).responseString{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(DailyTags.self, from: data)
                        completion(DailyTagAPIResult.Success([jsonData]))
                    }
                    catch {
                        completion(DailyTagAPIResult.Failure(error.localizedDescription
                        ))
                    }
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion(DailyTagAPIResult.Failure(Constants.InternetErrorMsg))
                }
            }
        }
    }
    
    func getMenu(_ completion : @escaping (MenuAPIResult) ->()){
        Alamofire.request(APPURL.getMenus, method: .get).responseString{
            response in
            print("menu response: \(response)")
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(Menu.self, from: data)
                        completion(MenuAPIResult.Success([jsonData]))
                    }
                    catch {
                        completion(MenuAPIResult.Failure(error.localizedDescription
                        ))
                    }
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion(MenuAPIResult.Failure(Constants.InternetErrorMsg))
                }
            }
        }
    }
}

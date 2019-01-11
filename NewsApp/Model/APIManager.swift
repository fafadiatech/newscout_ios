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
        print("Load API url: \(url)")
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
                        print("Error: \(error)")
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
        print(headers)
        Alamofire.request(url,method: .get, headers: headers).responseString{
            response in
            print(response)
            if(response.result.isSuccess){
                print(response.result)
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        if response.response?.statusCode == 404{
                            //if let httpResponse = response as? HTTPURLResponse {
                            print("error \(response.response?.statusCode)")
                            completion("error 404",ArticleAPIResult.Change(404))
                        }
                        else{
                            let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                            print(jsonData)
                            completion(String((response.response?.statusCode)!), ArticleAPIResult.Success([jsonData]))
                        }
                    }
                    catch {
                        print("Error: \(error)")
                        completion(String((response.response?.statusCode)!), ArticleAPIResult.Failure(error.localizedDescription))
                    }
                }
            }
            else{
                print(response.result.error!)
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion(String((response.response?.statusCode)!), ArticleAPIResult.Failure(err.localizedDescription))
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
        print(url)
        Alamofire.request(url,method: .post).responseJSON{
            response in
            if(response.result.isSuccess){
                if response.response?.statusCode == 200{
                    if let data = response.data {
                        let jsonDecoder = JSONDecoder()
                        do {
                            let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                            completion(String((response.response?.statusCode)!),ArticleAPIResult.Success([jsonData]))
                        }
                        catch {
                            print("Error: \(error)")
                            completion(String((response.response?.statusCode)!), ArticleAPIResult.Failure(error.localizedDescription))
                        }
                    }
                } else{
                    completion(String((response.response?.statusCode)!), ArticleAPIResult.Failure("\(String(describing: response.response?.statusCode))"))
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion(String((response.response?.statusCode)!), ArticleAPIResult.Failure(err.localizedDescription))
                }
            }
        }
    }
    
    func loadCategoriesAPI(_ completion : @escaping (Int, CategoryAPIResult) -> ()){
        let url = APPURL.CategoriesURL
        print(url)
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
                            print("Error: \(error)")
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
                    completion((response.response?.statusCode)!, CategoryAPIResult.Failure(Constants.InternetErrorMsg))
                }
            }
        }
    }
    
    func loadSearchAPI(searchTxt: String,_ completion : @escaping (String, ArticleAPIResult) -> ()){
        var search = searchTxt
       // search = searchTxt.replacingOccurrences(of: "'", with: "%27")
        let whitespace = NSCharacterSet.whitespaces
        var range = search.rangeOfCharacter(from: whitespace)
        
        if let test = range {
            print("whitespace found")
            search = search.trimmingCharacters(in: .whitespacesAndNewlines)
            search = search.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*();:@&=+$,/?%#[]").inverted)
        
        if let escapedString = search.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
            search = escapedString
        }
        let url = APPURL.SearchURL + search
        print("search url : \(url)")
        Alamofire.request(url,method: .get).responseJSON{
            response in
            if(response.result.isSuccess){
                if response.response?.statusCode == 200{
                    if let data = response.data {
                        let  jsonDecoder = JSONDecoder()
                        do {
                            let jsonData = try jsonDecoder.decode(ArticleStatus.self, from: data)
                            print(jsonData)
                            completion(String((response.response?.statusCode)!), ArticleAPIResult.Success([jsonData]))
                            
                        }
                        catch {
                            print("Error: \(error)")
                            completion(String((response.response?.statusCode)!), ArticleAPIResult.Failure(error as! String))
                        }
                    }
                }
                else{
                    completion(String((response.response?.statusCode)!), ArticleAPIResult.Failure("\(response.response?.statusCode)"))
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion(String((response.response?.statusCode)!), ArticleAPIResult.Failure(err.localizedDescription))
                }
            }
        }
    }
    
    //Signup API
    func SignupAPI(param : Dictionary<String, String>, _ completion : @escaping (String, String) ->()) {
        let url = APPURL.SignUpURL
        print(param)
        Alamofire.request(url,method: .post, parameters: param).responseString{
            response in
            if(response.result.isSuccess){
//                if response.response?.statusCode != 200{
//                    completion(String((response.response?.statusCode)!),"")
//                }
//                else{
                    if let data = response.data {
                        let jsonDecoder = JSONDecoder()
                        do {
                            let jsonData = try jsonDecoder.decode(MainModel.self, from: data)
                            print(jsonData)
                            if jsonData.header.status == "0"{
                                completion(String((response.response?.statusCode)!),jsonData.errors!.errorList![0].field_error)
                            }
                            else{
                                completion(String((response.response?.statusCode)!), jsonData.body!.Msg!)
                            }
                            
                        }
                        catch {
                            print("Error: \(error)")
                        }
                    }
                //}
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion(String((response.response?.statusCode)!), Constants.InternetErrorMsg)
                }
            }
        }
    }
    
    //Login API
    func LoginAPI(param : Dictionary<String, String>,_ completion : @escaping (Int , String) ->()) {
        let url = APPURL.LoginURL
        print(param)
        Alamofire.request(url,method: .post, parameters: param).responseString{
            response in
            if(response.result.isSuccess){
               // if response.response?.statusCode == 200{
                    
                    if let data = response.data {
                        let jsonDecoder = JSONDecoder()
                        do {
                            let jsonData = try jsonDecoder.decode(MainModel.self, from: data)
                            print(jsonData)
                            if jsonData.header.status == "0"{
                                if jsonData.errors?.invalid_credentials != nil{
                                    completion((response.response?.statusCode)!, (jsonData.errors?.invalid_credentials)!)
                                }
                                else{
                                    completion((response.response?.statusCode)!, (jsonData.errors?.errorList![0].field_error)!)
                                }
                            }
                            else{
                                UserDefaults.standard.set(jsonData.body?.first_name, forKey: "first_name")
                                UserDefaults.standard.set(jsonData.body?.last_name, forKey: "last_name")
                                UserDefaults.standard.set(jsonData.body?.token, forKey: "token")
                                UserDefaults.standard.set(jsonData.body?.user_id, forKey: "user_id")
                                UserDefaults.standard.set(param["email"], forKey: "email")
                                completion((response.response?.statusCode)!, jsonData.header.status)
                            }
                        }
                        catch {
                            print("Error: \(error)")
                        }
                    }
           //     }
//                else{
//                    completion((response.response?.statusCode)!,"")
//                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion((response.response?.statusCode)!,Constants.InternetErrorMsg)
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
                        print(jsonData)
                        if jsonData.header.status == "0"{
                            completion(jsonData.header.status,jsonData.errors!.invalid_credentials!)
                        }
                        else{
                            let defaults = UserDefaults.standard
                            defaults.removeObject(forKey: "token")
                            defaults.removeObject(forKey: "first_name")
                            defaults.removeObject(forKey: "last_name")
                            defaults.removeObject(forKey: "user_id")
                            defaults.removeObject(forKey: "email")
                            defaults.synchronize()
                            completion(jsonData.header.status,jsonData.body!.Msg!)
                        }
                    }
                    catch {
                        print("Error: \(error)")
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
        print(url)
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
                        print("Error: \(error)")
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
        print(url)
        print(param)
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
                        print("Error: \(error)")
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
                            completion(jsonData.header.status, jsonData.errors!.Msg!)
                        }
                        else{
                            completion(jsonData.header.status, (jsonData.body?.Msg)!)
                        }
                    }
                    catch {
                        print("Error: \(error)")
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
        print(param)
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
        print(headers)
        Alamofire.request(url,method: .post, parameters: param, headers: headers).responseString{
            response in
            if(response.result.isSuccess){
                if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(MainModel.self, from: data)
                        print(jsonData)
                        if jsonData.header.status == "0"{
                            completion(jsonData.header.status, jsonData.errors!.Msg!)
                        }
                        else{
                            completion(jsonData.header.status, (jsonData.body?.Msg)!)
                        }
                    }
                    catch {
                        print("Error: \(error)")
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
                        print("Error: \(error)")
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
        print(url)
        Alamofire.request(url,method: .get, headers: headers).responseJSON{
            response in
            print("response of articleDetailAPI: \(response)")
            if(response.result.isSuccess){
                if response.response?.statusCode == 200{
                    if let data = response.data {
                        let jsonDecoder = JSONDecoder()
                        do {
                            let jsonData = try jsonDecoder.decode(ArticleDetails.self, from: data)
                            completion(String((response.response?.statusCode)!),ArticleDetailAPIResult.Success(jsonData))
                        }
                        catch {
                            print("Error: \(error)")
                            completion(String((response.response?.statusCode)!), ArticleDetailAPIResult.Failure(error.localizedDescription))
                        }
                    }
                } else{
                    completion(String((response.response?.statusCode)!), ArticleDetailAPIResult.Failure("\(String(describing: response.response?.statusCode))"))
                }
            }
            else{
                if let err = response.result.error as? URLError, err.code == .notConnectedToInternet {
                    completion(String((response.response?.statusCode)!), ArticleDetailAPIResult.Failure(err.localizedDescription))
                }
            }
        }
    }
    
}

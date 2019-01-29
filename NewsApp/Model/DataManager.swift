//
//  DataManager.swift
//  NewsApp
//
//  Created by Jayashree on 23/10/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DBManager{
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var ArticleData = [ArticleStatus]()
    var CategoryData = [CategoryList]()
    
    //save articles in DB
    func SaveDataDB(nextUrl:String,_ completion : @escaping (Bool) -> ())
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        APICall().loadNewsbyCategoryAPI(url : nextUrl){
            (status, response)  in
            switch response {
            case .Success(let data) :
                self.ArticleData = data
                
            case .Failure(let errormessage) :
                print(errormessage)
            case .Change(let code):
                print(code)
            }
            if self.ArticleData.count != 0{
                for news in self.ArticleData[0].body.articles{ 
                    if  self.someEntityExists(id: Int(news.article_id!), entity: "NewsArticle") == false
                    {
                        let newArticle = NewsArticle(context: managedContext!)
                        newArticle.article_id = Int16(news.article_id!)
                        newArticle.title = news.title
                        newArticle.source = news.source!
                        newArticle.imageURL = news.imageURL
                        newArticle.source_url = news.url
                        newArticle.published_on = news.published_on
                        newArticle.blurb = news.blurb
                        newArticle.category = news.category!
                        do {
                            try managedContext?.save()
                        }
                        catch let error as NSError  {
                            print("Could not save \(error)")
                        }
                    }
                }
                if self.ArticleData[0].body.next != nil{
                    // self.someEntityExists(id: 0 , entity: String)
                }
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    //check for existing entry in DB
    func someEntityExists(id: Int, entity : String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        if entity == "NewsArticle" || entity == "BookmarkArticles"{
            fetchRequest.predicate = NSPredicate(format: "article_id == \(id)")
            
        }
        else{
            fetchRequest.predicate = NSPredicate(format: "cat_id == \(id)")
            
        }
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        var results: [NSManagedObject] = []
        
        do {
            results = (try managedContext?.fetch(fetchRequest))!
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        if results.count == 0{
            return false
        }
        else{
            return true
        }
    }
    
    //check for nexturl entry in DB
    func nextURLExists(catName: String, entity : String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        if entity == "NewsArticle"{
            fetchRequest.predicate = NSPredicate(format: "article_id == \(catName)")
            
        }
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        var results: [NSManagedObject] = []
        
        do {
            results = (try managedContext?.fetch(fetchRequest))!
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        if results.count == 0{
            return false
        }
        else{
            return true
        }
    }
    
    //fetch articles from DB
    func FetchDataFromDB(entity: String) -> ArticleDBfetchResult
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: entity)
        do {
            let ShowArticle = try (managedContext?.fetch(fetchRequest))!
            return ArticleDBfetchResult.Success(ShowArticle as! [NewsArticle])
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return ArticleDBfetchResult.Failure(error as! String)
        }
    }
    
    //fetch bookmarked articles
    func FetchBookmarkFromDB() -> BookmarkArticleDBfetchResult
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<BookmarkArticles>(entityName: "BookmarkArticles")
        do {
            let ShowArticle = try (managedContext?.fetch(fetchRequest))!
            return BookmarkArticleDBfetchResult.Success(ShowArticle as! [BookmarkArticles])
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return BookmarkArticleDBfetchResult.Failure(error as! String)
        }
    }
    
    // check if DB is empty
    func IsCoreDataEmpty(entity: String) -> Int
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        var records = [NewsArticle]()
        do {
            records = (try managedContext?.fetch(fetchRequest)) as! [NewsArticle]
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return records.count
    }
    
    //check if category table is empty
    func IsCategoryDataEmpty() -> Int
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        var records = [Category]()
        do {
            records = (try managedContext?.fetch(fetchRequest)) as! [Category]
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return records.count
    }
    
    //save categories in DB
    func SaveCategoryDB(_ completion : @escaping (Bool) -> ())
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        APICall().loadCategoriesAPI{
            (status,response) in
            switch response {
            case .Success(let data) :
                self.CategoryData = data
            case .Failure(let errormessage) :
                print(errormessage)
            }
            
            if self.CategoryData.count != 0{
                for cat in self.CategoryData[0].categories{
                    if  self.someEntityExists(id: Int(cat.cat_id!), entity: "Category") == false
                    {
                        let newCategory = Category(context: managedContext!)
                        newCategory.cat_id = Int16(cat.cat_id!)
                        newCategory.title = cat.title
                        do {
                            try managedContext?.save()
                        } catch let error as NSError  {
                            print("Could not save \(error)")
                        }
                    }
                }
                completion(true)
            }
            else{
                completion(false)
            }
        }
    }
    
    //fetch categories from DB
    func FetchCategoryFromDB() -> CategoryDBfetchResult
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<Category>(entityName: "Category")
        do {
            let ShowCategory = try (managedContext?.fetch(fetchRequest))!
            return CategoryDBfetchResult.Success(ShowCategory)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return CategoryDBfetchResult.Failure(error as! String)
        }
    }
    
    func SaveBookmarkArticles(nextUrl:String,_ completion : @escaping (Bool) -> ())
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        APICall().BookmarkedArticlesAPI(url: APPURL.bookmarkedArticlesURL){
            response  in
            switch response {
            case .Success(let data) :
                self.ArticleData = data
                
            case .Failure(let errormessage) :
                print(errormessage)
            case .Change(let code):
                print(code)
            }
            if self.ArticleData.count != 0{
                for news in self.ArticleData[0].body.articles{
                    if  self.someEntityExists(id: Int(news.article_id!), entity: "BookmarkArticles") == false
                    {
                        let newArticle = BookmarkArticles(context: managedContext!)
                        newArticle.article_id = Int16(news.article_id!)
                        newArticle.title = news.title
                        newArticle.source = news.source!
                        newArticle.imageURL = news.imageURL
                        newArticle.source_url = news.url
                        newArticle.published_on = news.published_on
                        newArticle.blurb = news.blurb
                        newArticle.category = news.category!
                        do {
                            try managedContext?.save()
                        }
                        catch let error as NSError  {
                            print("Could not save \(error)")
                        }
                    }
                }
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
}

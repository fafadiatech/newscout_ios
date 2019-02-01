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
    func FetchBookmarkFromDB() -> ArticleDBfetchResult
    {
        var BookmarkArticle = [BookmarkArticles]()
        var ShowArticle = [NewsArticle]()
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
        let bookmarkfetchRequest =
            NSFetchRequest<BookmarkArticles>(entityName: "BookmarkArticles")
        do {
             BookmarkArticle = try (managedContext?.fetch(bookmarkfetchRequest))!
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
       var i = 1
        for book in BookmarkArticle{
       
        fetchRequest.predicate = NSPredicate(format: "article_id  = %d", book.article_id)
        do {
             let ShowArticle1 = try (managedContext?.fetch(fetchRequest))!
            ShowArticle.append(contentsOf: ShowArticle1)
            
            if ShowArticle1.count != 0 {
            book.addToArticle(ShowArticle1[0])
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return ArticleDBfetchResult.Failure(error as! String)
        }
            // book.addToArticle(ShowArticle[0])
        }
            return ArticleDBfetchResult.Success(ShowArticle)
    }
    
    // check if DB is empty
    func IsCoreDataEmpty(entity: String) -> Int
    {
        var recordCount = 0
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        if entity == "NewsArticle"{
        var records = [NewsArticle]()
        do {
            records = (try managedContext?.fetch(fetchRequest)) as! [NewsArticle]
        }
        catch {
            print("error executing fetch request: \(error)")
        }
            recordCount = records.count
        }
        else{
            var records = [BookmarkArticles]()
            do {
                records = (try managedContext?.fetch(fetchRequest)) as! [BookmarkArticles]
            }
            catch {
                print("error executing fetch request: \(error)")
            }
            recordCount = records.count
        }
        return recordCount
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
    
    func SaveBookmarkArticles(_ completion : @escaping (Bool) -> ())
    {
        var BookmarkData : GetLikeBookmarkList!
        let managedContext =
            appDelegate?.persistentContainer.viewContext
         APICall().getLikeBookmarkList(url : APPURL.getBookmarkListURL){
            response  in
            switch response {
            case .Success(let data) :
                 BookmarkData = data
                
            case .Failure(let errormessage) :
                print(errormessage)
    
            }
           
            if BookmarkData.body?.listResult!.count != 0{
                for news in (BookmarkData.body?.listResult)!{
                    if  self.someEntityExists(id: Int(news.article_id), entity: "BookmarkArticles") == false
                    {
                        let newArticle = BookmarkArticles(context: managedContext!)
                        newArticle.article_id = Int16(news.article_id)
                        newArticle.isBookmark = Int16(news.status!)
                        newArticle.row_id = Int16(news.row_id)
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
    
    func addBookmarkedArticles(id : Int){
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        if  self.someEntityExists(id: id, entity: "BookmarkArticles") == false{
            let newArticle = BookmarkArticles(context: managedContext!)
            newArticle.article_id = Int16(id)
            newArticle.isBookmark = 1
            do {
                try managedContext?.save()
            }
            catch let error as NSError  {
                print("Could not save \(error)")
            }
        }
    }
    
    func deleteBookmarkedArticle(id : Int){
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let bookmarkfetchRequest =
            NSFetchRequest<BookmarkArticles>(entityName: "BookmarkArticles")
        var bookmark = [BookmarkArticles]()
        bookmarkfetchRequest.predicate = NSPredicate(format: "article_id  = %d", id)
        do {
            bookmark = try ((managedContext?.fetch(bookmarkfetchRequest))!)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        do {
            for book in bookmark{
            managedContext!.delete(book)
            }
          
        } catch {
            print("Failed")
        }
        do {
            try managedContext?.save()
        }
        catch let error as NSError  {
            print("Could not save \(error)")
        }
    }
}

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
        let managedContext = appDelegate?.persistentContainer.viewContext
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
                if self.ArticleData[0].header.status == "1" {
                for news in self.ArticleData[0].body!.articles{ 
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
                
                        self.saveBlock()
                    }
                }
                if self.ArticleData[0].body!.next != nil{
                    // self.someEntityExists(id: 0 , entity: String)
                }
                completion(true)
                }
                else{
                    completion(false)
                }
            }else{
                completion(false)
            }
        }
    }
    
    //check for existing entry in DB
    func someEntityExists(id: Int, entity : String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        if entity == "NewsArticle" || entity == "BookmarkArticles" || entity == "LikeDislike" || entity == "SearchArticles"{
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
        else if entity == "BookmarkArticles" {
            var records = [BookmarkArticles]()
            do {
                records = (try managedContext?.fetch(fetchRequest)) as! [BookmarkArticles]
            }
            catch {
                print("error executing fetch request: \(error)")
            }
            recordCount = records.count
        }
        else if entity == "LikeDislike"{
            var records = [LikeDislike]()
            do {
                records = (try managedContext?.fetch(fetchRequest)) as! [LikeDislike]
            }
            catch {
                print("error executing fetch request: \(error)")
            }
            recordCount = records.count
        }
        else if entity == "SearchArticles"{
            var records = [SearchArticles]()
            do {
                records = (try managedContext?.fetch(fetchRequest)) as! [SearchArticles]
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
                        self.saveBlock()
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
    
    //fetch bookmarked articles
    func FetchLikeBookmarkFromDB() -> ArticleDBfetchResult
    {
        var BookmarkArticle = [BookmarkArticles]()
        var LikeArticle = [LikeDislike]()
        var ShowArticle = [NewsArticle]()
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
        let bookmarkfetchRequest =
            NSFetchRequest<BookmarkArticles>(entityName: "BookmarkArticles")
        let likefetchRequest =
            NSFetchRequest<LikeDislike>(entityName: "LikeDislike")
        do {
            BookmarkArticle = try (managedContext?.fetch(bookmarkfetchRequest))!
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        do {
            LikeArticle =  try (managedContext?.fetch(likefetchRequest))!
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
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
        }
        for like in LikeArticle{
            
            fetchRequest.predicate = NSPredicate(format: "article_id  = %d", like.article_id)
            do {
                let ShowArticle1 = try (managedContext?.fetch(fetchRequest))!
                if ShowArticle1.count != 0 {
                    like.addToLikedArticle(ShowArticle1[0])
                }
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                return ArticleDBfetchResult.Failure(error as! String)
            }
        }
        return ArticleDBfetchResult.Success(ShowArticle)
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
                        //newArticle.row_id = Int16(news.row_id)
                        self.saveBlock()
                    }
                }
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    func SaveLikeDislikeArticles(_ completion : @escaping (Bool) -> ())
    {
        var LikeData : GetLikeBookmarkList!
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        APICall().getLikeBookmarkList(url : APPURL.getLikeListURL){
            response  in
            switch response {
            case .Success(let data) :
                LikeData = data
                
            case .Failure(let errormessage) :
                print(errormessage)
                
            }
            
            if LikeData.body?.listResult!.count != 0{
                for news in (LikeData.body?.listResult)!{
                    if  self.someEntityExists(id: Int(news.article_id), entity: "LikeDislike") == false
                    {
                        let newArticle = LikeDislike(context: managedContext!)
                        newArticle.article_id = Int16(news.article_id)
                        newArticle.isLike = Int16(news.isLike!)
                      //  newArticle.row_id = Int16(news.row_id)
                        self.saveBlock()
                    }
                }
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    func addLikedArticle(tempentity: String,id : Int, status : Int){
        var Article = [NewsArticle]()
        var SearchArticle = [SearchArticles]()
        var likeDislike = [LikeDislike]()
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NewsArticle>(entityName: tempentity)
        let searchFetchRequest = NSFetchRequest<SearchArticles>(entityName: tempentity)

        fetchRequest.predicate = NSPredicate(format: "article_id  = %d", id)
        searchFetchRequest.predicate = NSPredicate(format: "article_id  = %d", id)
        let likefetchRequest =
            NSFetchRequest<LikeDislike>(entityName: "LikeDislike")
        likefetchRequest.predicate = NSPredicate(format: "article_id  = %d", id)
        fetchRequest.predicate = NSPredicate(format: "article_id  = %d", id)
        do {
            if tempentity == "NewsArticle"{
            Article = try (managedContext?.fetch(fetchRequest))!
            }
            else if tempentity == "SearchArticles"{
             SearchArticle = try (managedContext?.fetch(searchFetchRequest))!
            }
        }catch {
            print("Failed")
        }
        if  self.someEntityExists(id: id, entity: "LikeDislike") == false{
            let newArticle = LikeDislike(context: managedContext!)
            newArticle.article_id = Int16(id)
            newArticle.isLike = Int16(status)
             if tempentity == "NewsArticle"{
            newArticle.addToLikedArticle(Article[0])
             }else if tempentity == "SearchArticles"{
                newArticle.addToSearchlikeArticles(SearchArticle[0])
            }
        }
        else{
            do {
                likeDislike = try ((managedContext?.fetch(likefetchRequest))!)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            do {
                for article in likeDislike{
                    if article.article_id == Int16(id){
                        article.isLike = Int16(status)
                    }
                }
                
            } catch {
                print("Failed")
            }
        }
        saveBlock()
    }
    
    func deleteLikedDislikedArticle(id : Int,_ completion : @escaping (Bool) -> ()){
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let likefetchRequest =
            NSFetchRequest<LikeDislike>(entityName: "LikeDislike")
        var likeDislike = [LikeDislike]()
        likefetchRequest.predicate = NSPredicate(format: "article_id  = %d", id)
        do {
            likeDislike = try ((managedContext?.fetch(likefetchRequest))!)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        do {
            for status in likeDislike{
                managedContext!.delete(status)
            }
            
        } catch {
            print("Failed")
        }
        do {
            try managedContext?.save()
            completion(true)
        }
        catch let error as NSError  {
            print("Could not save \(error)")
            completion(false)
        }
    }
    
    func addBookmarkedArticles(currentEntity : String, id : Int){
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
        var Article = [NewsArticle]()
        var SearchArticle = [SearchArticles]()
        let searchRequest = NSFetchRequest<SearchArticles>(entityName: "SearchArticles")
        fetchRequest.predicate = NSPredicate(format: "article_id  = %d", id)
        do {
            if currentEntity == "NewsArticle"{
            Article = try (managedContext?.fetch(fetchRequest))!
            }
            else if currentEntity == "SearchArticles"{
                SearchArticle = try (managedContext?.fetch(searchRequest))!
            }
        }catch {
            print("Failed")
        }
        if  self.someEntityExists(id: id, entity: "BookmarkArticles") == false{
            let newArticle = BookmarkArticles(context: managedContext!)
            newArticle.article_id = Int16(id)
            newArticle.isBookmark = 1
            if currentEntity == "NewsArticle"{
            newArticle.addToArticle(Article[0])
            }else{
                newArticle.addToSearchArticle(SearchArticle[0])
            }
            saveBlock()
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
        saveBlock()
    }
    
    func saveBlock()
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        do {
            try managedContext?.save()
        }
        catch let error as NSError  {
            print("Could not save \(error)")
        }
    }
   
    func SaveSearchDataDB(nextUrl:String,_ completion : @escaping (Bool) -> ())
    {
        let managedContext = appDelegate?.persistentContainer.viewContext
        APICall().loadSearchAPI(url : nextUrl){
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
                for news in self.ArticleData[0].body!.articles{
                    if  self.someEntityExists(id: Int(news.article_id!), entity: "SearchArticles") == false
                    {
                        let newArticle = SearchArticles(context: managedContext!)
                        newArticle.article_id = Int16(news.article_id!)
                        newArticle.title = news.title
                        newArticle.source = news.source!
                        newArticle.imageURL = news.imageURL
                        newArticle.source_url = news.url
                        newArticle.published_on = news.published_on
                        newArticle.blurb = news.blurb
                        newArticle.category = news.category!
                        
                        self.saveBlock()
                    }
                }
                if self.ArticleData[0].body!.next != nil{
                    // self.someEntityExists(id: 0 , entity: String)
                }
                completion(true)
            }else{
                completion(false)
            }
        }
        
    }
    func FetchSearchDataFromDB(entity: String) -> SearchDBfetchResult
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: entity)
        
        do {
            let ShowArticle = try (managedContext?.fetch(fetchRequest))!
            return SearchDBfetchResult.Success(ShowArticle as! [SearchArticles])
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return SearchDBfetchResult.Failure(error as! String)
        }
    }
    //fetch bookmarked articles
    func FetchSearchLikeBookmarkFromDB() -> SearchDBfetchResult
    {
        var BookmarkArticle = [BookmarkArticles]()
        var LikeArticle = [LikeDislike]()
        var ShowArticle = [SearchArticles]()
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<SearchArticles>(entityName: "SearchArticles")
        let bookmarkfetchRequest =
            NSFetchRequest<BookmarkArticles>(entityName: "BookmarkArticles")
        let likefetchRequest =
            NSFetchRequest<LikeDislike>(entityName: "LikeDislike")
        do {
            BookmarkArticle = try (managedContext?.fetch(bookmarkfetchRequest))!
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        do {
            LikeArticle =  try (managedContext?.fetch(likefetchRequest))!
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for book in BookmarkArticle{
            
            fetchRequest.predicate = NSPredicate(format: "article_id  = %d", book.article_id)
            do {
                let ShowArticle1 = try (managedContext?.fetch(fetchRequest))!
                ShowArticle.append(contentsOf: ShowArticle1)
                
                if ShowArticle1.count != 0 {
                    book.addToSearchArticle(ShowArticle1[0])
                }
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                return SearchDBfetchResult.Failure(error as! String)
            }
        }
        for like in LikeArticle{
            
            fetchRequest.predicate = NSPredicate(format: "article_id  = %d", like.article_id)
            do {
                let ShowArticle1 = try (managedContext?.fetch(fetchRequest))!
                if ShowArticle1.count != 0 {
                    like.addToSearchlikeArticles(ShowArticle1[0])
                }
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                return SearchDBfetchResult.Failure(error as! String)
            }
        }
        return SearchDBfetchResult.Success(ShowArticle)
    }
    
    func deleteAllData(entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        do {
            let results = try managedContext!.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                managedContext?.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
}

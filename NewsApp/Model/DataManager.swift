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
    
    //save articles in DB
    func SaveDataDB()
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        
        if ArticleData.count != 0
        {
            for news in ArticleData[0].articles{
                if  someEntityExists(title: news.title!, entity: "NewsArticle") == false
                {
                    let newArticle = NewsArticle(context: managedContext!)
                    newArticle.article_id = news.article_id!
                    newArticle.title = news.title
                    newArticle.source = news.source!
                    newArticle.imageURL = news.imageURL
                    newArticle.source_url = news.url
                    newArticle.published_on = news.published_on
                    newArticle.blurb = news.blurb
                    newArticle.category = news.category!
                    do {
                        try managedContext?.save()
                        print("successfully saved ..")
                        
                    } catch let error as NSError  {
                        print("Could not save \(error)")
                    }
                }
            }
        }
    }
    
    //check for existing entry in DB
    func someEntityExists(title: String, entity : String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: "title = %@",title)
        
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
    func FetchDataFromDB() -> ArticleDBfetchResult
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
        do {
            let ShowArticle = try (managedContext?.fetch(fetchRequest))!
            return ArticleDBfetchResult.Success(ShowArticle)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return ArticleDBfetchResult.Failure(error as! String)
        }
    }
    
    // chjeck if DB is empty
    func IsCoreDataEmpty() -> Int
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewsArticle")
        var records = [NewsArticle]()
        do {
            records = (try managedContext?.fetch(fetchRequest)) as! [NewsArticle]
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return records.count
    }
    
    //save categories in DB
    func SaveCategoryDB()
    {
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        for cat in CategoryData[0].categories{
            if  someEntityExists(title: cat.title!, entity: "Category") == false
            {
                let newCategory = Category(context: managedContext!)
                newCategory.cat_id = cat.cat_id!
                newCategory.title = cat.title
                do {
                    try managedContext?.save()
                    print("successfully saved ..")
                    
                } catch let error as NSError  {
                    print("Could not save \(error)")
                }
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
            print(ShowCategory)
            return CategoryDBfetchResult.Success(ShowCategory)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return CategoryDBfetchResult.Failure(error as! String)
        }
    }
}

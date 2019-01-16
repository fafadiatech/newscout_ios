//
//  AppDelegate.swift
//  NewsApp
//
//  Created by Jayashri on 22/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import CoreData
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    var categories : [String] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GIDSignIn.sharedInstance().clientID = "424337192018-pnik0j5sm85mjg48uf0u02ucrb64e6lc.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self as! GIDSignInDelegate
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        if UserDefaults.standard.value(forKey: "darkModeEnabled") == nil{
            UserDefaults.standard.set(false, forKey: "darkModeEnabled")
        }
        if UserDefaults.standard.value(forKey: "categories") == nil{
            
            if UserDefaults.standard.value(forKey: "token") == nil || UserDefaults.standard.value(forKey: "FBToken") == nil || UserDefaults.standard.value(forKey: "googleToken") == nil{
                categories = ["Trending"]
                UserDefaults.standard.setValue(categories, forKey: "categories")
            }
            else{
                categories = ["For You"]
                UserDefaults.standard.setValue(categories, forKey: "categories")
            }
        }
        if UserDefaults.standard.value(forKey: "darkModeEnabled") == nil{
            UserDefaults.standard.setValue(false, forKey: "darkModeEnabled")
        }
        
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
      
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        
        if UserDefaults.standard.value(forKey: "googleToken") != nil{
            return GIDSignIn.sharedInstance().handle(url as URL?,
                                                     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: options[UIApplicationOpenURLOptionsKey.annotation])
            
        }
        else{
            let sourceApplication: String? = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: nil)
        }
    }
    
    /* func application(application: UIApplication,
     openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
     var options: [String: AnyObject] = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject,
     UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation!]
     return GIDSignIn.sharedInstance().handle(url as URL!,
     sourceApplication: sourceApplication,
     annotation: annotation)
     }*/
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.hexString
        print(deviceTokenString)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        }
        else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            let pic1 = user.profile.imageURL(withDimension: 50)
            let pic = (pic1?.relativeString)!
            UserDefaults.standard.set(idToken, forKey: "googleToken")
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(givenName, forKey: "first_name")
            UserDefaults.standard.set(familyName, forKey: "last_name")
            // ...
            print("\(userId!) \n \(idToken) \n \(fullName!) \n \(email!) \n \(pic)")
            print("google sign in successful..")

        /*  let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let HomeVc = mainStoryboard.instantiateViewController(withIdentifier: "HomeParentID") as! HomeParentVC
            self.window?.rootViewController = HomeVc*/
        }
    }
    
   
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        // Add any custom logic here.
        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "NewsApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


//
//  File.swift
//  NewsApp
//
//  Created by Jayashri on 25/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//
import UIKit
import XLPagerTabStrip

var newsCurrentIndex = 0
var textSizeSelected = 1
var categories = ["FOR YOU"]
var selectedCat = "FOR YOU"
var isSearch = false
var articleId = 0

struct Constants{
    static let isPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone)
    static let fontSize:CGFloat = isPhone ? 12 :20
    static let fontxLarge:CGFloat = isPhone ? 16:20
    static let fontxNormal:CGFloat = isPhone ? 14 :20
    static let fontxSmall:CGFloat = isPhone ? 12 :20
    static let fontLargeHeading:CGFloat = isPhone ? 25:20
    static let fontNormalHeading:CGFloat = isPhone ? 22 :20
    static let fontSmallHeading:CGFloat = isPhone ? 18 :20
    static let fontLargeTitle:CGFloat = isPhone ? 21:20
    static let fontNormalTitle:CGFloat = isPhone ? 18 :20
    static let fontSmallTitle:CGFloat = isPhone ? 14 :20
    static let fontLargeContent:CGFloat = isPhone ? 18 :20
    static let fontNormalContent:CGFloat = isPhone ? 14 :20
    static let fontSmallContent:CGFloat = isPhone ? 10 :20
    static let  xsmallFont = UIFont(name: AppFontName.regular, size: Constants.fontxSmall)
    static let xLargeFont = UIFont(name: AppFontName.regular, size: Constants.fontxLarge)
    static let xNormalFont = UIFont(name: AppFontName.regular, size: Constants.fontxNormal)
    static let smallFont = UIFont(name: AppFontName.regular, size: Constants.fontSmallTitle)
    static let LargeFont = UIFont(name: AppFontName.regular, size: Constants.fontLargeTitle)
    static let NormalFont = UIFont(name: AppFontName.regular, size: Constants.fontNormalTitle)
    static let smallFontHeading = UIFont(name: AppFontName.regular, size: Constants.fontSmallTitle)
    static let LargeFontHeading = UIFont(name: AppFontName.regular, size: Constants.fontLargeTitle)
    static let NormalFontHeading = UIFont(name: AppFontName.regular, size: Constants.fontNormalTitle)
    static let smallFontMedium = UIFont(name: AppFontName.medium, size: Constants.fontSmallTitle)
    static let LargeFontMedium = UIFont(name: AppFontName.medium, size: Constants.fontLargeTitle)
    static let NormalFontMedium = UIFont(name: AppFontName.medium, size: Constants.fontNormalTitle)
    static let xsmallFontMedium = UIFont(name: AppFontName.medium, size: Constants.fontxSmall)
    static let xLargeFontMedium = UIFont(name: AppFontName.medium, size: Constants.fontxLarge)
    static let xNormalFontMedium = UIFont(name: AppFontName.medium, size: Constants.fontxNormal)
}

struct AppFontName {
    static let regular = "HelveticaNeue-Light"
    static let bold = "HelveticaNeue-Bold"
    static let medium = "HelveticaNeue-Medium"
    
}
struct themeColor{
    static let commonColor = UIColor.gray
}
extension UIFont {
    
    class func myFontName() -> String { return "HelveticaNeue" }
    class func myBoldFontName() -> String { return "System"}
    class func smallFont(fontSize :Int) -> UIFont {
        return UIFont.systemFont(ofSize: CGFloat(fontSize - 10))
        
    }
    class func myNormalFont() -> UIFont {
        return UIFont(name: "HelveticaNeue-Thin", size: 20)!
        //return UIFont.systemFont(ofSize: 20)
    }
    
    class func largeFont(fontSize :Int) -> UIFont {
        return UIFont.systemFont(ofSize: CGFloat(fontSize + 10))
    }
}
struct APPURL {
    
    private struct Domains {
        static let Local = "http://192.168.2.204"
        static let Server = ""
        static let version = "/api/v1/"
    }
    
    private  struct Routes {
        static let Articles = Domains.version + "articles/?page="
        static let ArticlesByCategory = Domains.version + "articles/?categories="
        static let Login = Domains.version + "login/"
        static let SignUp = Domains.version + "signup/"
        static let Logout = Domains.version + "logout/"
        static let Categories = Domains.version + "categories"
        static let Search = Domains.version + "search/?q="
        static let recommendation = Domains.version + "articles/" + "\(articleId)" + "/recommendations/"
    }
    
    static let ArticlesURL = Domains.Local + Routes.Articles
    static let ArticlesByCategoryURL = Domains.Local + Routes.ArticlesByCategory
    static let LoginURL = Domains.Local + Routes.Login
    static let SignUpURL =  Domains.Local + Routes.SignUp
    static let LogoutURL =  Domains.Local + Routes.Logout
    static let CategoriesURL =  Domains.Local + Routes.Categories
    static let SearchURL =  Domains.Local + Routes.Search
    static let recommendationURL = Domains.Local + Routes.recommendation
}


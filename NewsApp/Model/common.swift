//
//  File.swift
//  NewsApp
//
//  Created by Jayashri on 25/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//
import UIKit
import XLPagerTabStrip

struct colorConstants{
    static let backgroundGray = UIColor(hexFromString: "F5F5F5")
    static let redColor = UIColor(hexFromString: "ed1c24")
    static let blackColor = UIColor(hexFromString: "383839")
    static let whiteColor = UIColor.white
    static let txtlightGrayColor = UIColor(hexFromString: "9B9B9B")
    static let txtDarkGrayColor = UIColor(hexFromString: "424242")
}

struct FontConstants{
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
    static let  xsmallFont = UIFont(name: AppFontName.regular, size: FontConstants.fontxSmall)
    static let xLargeFont = UIFont(name: AppFontName.regular, size: FontConstants.fontxLarge)
    static let xNormalFont = UIFont(name: AppFontName.regular, size: FontConstants.fontxNormal)
    static let smallFont = UIFont(name: AppFontName.regular, size: FontConstants.fontSmallTitle)
    static let LargeFont = UIFont(name: AppFontName.regular, size: FontConstants.fontLargeTitle)
    static let NormalFont = UIFont(name: AppFontName.regular, size: FontConstants.fontNormalTitle)
    static let smallFontHeading = UIFont(name: AppFontName.regular, size: FontConstants.fontSmallTitle)
    static let LargeFontHeading = UIFont(name: AppFontName.regular, size: FontConstants.fontLargeTitle)
    static let NormalFontHeading = UIFont(name: AppFontName.regular, size: FontConstants.fontNormalTitle)
    static let smallFontMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontSmallTitle)
    static let LargeFontMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontLargeTitle)
    static let NormalFontMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontNormalTitle)
    static let xsmallFontMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontxSmall)
    static let xLargeFontMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontxLarge)
    static let xNormalFontMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontxNormal)
    static let appFont = UIFont(name: AppFontName.bold, size: FontConstants.fontLargeHeading)
}

struct Constants{
    static let AppName = "NewScout"
    static let InternetErrorMsg = "The Internet connection appears to be offline"
}

struct AppFontName {
    static let regular = "HelveticaNeue-Light"
    static let bold = "HelveticaNeue-Bold"
    static let medium = "HelveticaNeue-Medium"
    static let thin = "HelveticaNeue-Thin"
}

struct themeColor{
    static let commonColor = UIColor.gray
}

struct APPURL {
    
    private struct Domains {
        static let Local = "http://192.168.2.204" //"http://192.168.2.151:8000"//
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
        static let recommendation = Domains.version + "articles/" // + "\(articleId)" + "/recommendations/"
        static let bookmark = Domains.version + "articles/bookmark/"
        static let likeDislike =  Domains.version + "articles/vote/"
        static let forgotPassword = Domains.version + "forgot-password/"
        static let changePassword = Domains.version + "change-password/"
        static let bookmarkedArticles = Domains.version + "bookmark-articles/"
    }
    
    static let ArticlesURL = Domains.Local + Routes.Articles
    static let ArticlesByCategoryURL = Domains.Local + Routes.ArticlesByCategory
    static let LoginURL = Domains.Local + Routes.Login
    static let SignUpURL =  Domains.Local + Routes.SignUp
    static let LogoutURL =  Domains.Local + Routes.Logout
    static let CategoriesURL =  Domains.Local + Routes.Categories
    static let SearchURL =  Domains.Local + Routes.Search
    static let recommendationURL = Domains.Local + Routes.recommendation
    static let bookmarkURL = Domains.Local + Routes.bookmark
    static let likeDislikeURL = Domains.Local + Routes.likeDislike
    static let forgotPasswordURL = Domains.Local + Routes.forgotPassword
    static let changePasswordURL = Domains.Local + Routes.changePassword
    static let bookmarkedArticlesURL = Domains.Local + Routes.bookmarkedArticles
}


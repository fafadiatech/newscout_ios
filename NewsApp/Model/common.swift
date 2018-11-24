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
    static let fontxLarge:CGFloat = isPhone ? 16:24 //16
    static let fontxNormal:CGFloat = isPhone ? 15 :22 //14
    static let fontxSmall:CGFloat = isPhone ? 12 :20 //12
    static let fontLargeHeading:CGFloat = isPhone ? 20:26 //25
    static let fontNormalHeading:CGFloat = isPhone ? 18 :28 //22
    static let fontSmallHeading:CGFloat = isPhone ? 16 :20 //18
    static let fontLargeTitle:CGFloat = isPhone ? 21:26 //21
    static let fontNormalTitle:CGFloat = isPhone ? 17 :25//18
    static let fontSmallTitle:CGFloat = isPhone ? 14 :20 //14
    static let fontLargeContent:CGFloat = isPhone ? 18 :28 //18
    static let fontNormalContent:CGFloat = isPhone ? 16 :22 //14
    static let fontSmallContent:CGFloat = isPhone ? 14 :22 //10
    static let fontNormalBtn: CGFloat = isPhone ? 18 :26
    static let fontViewTitle:CGFloat = isPhone ? 23 : 35
    static let fontSettingsTVHeader:CGFloat = isPhone ? 20 : 23
    static let fontAppTitle:CGFloat = isPhone ? 24 : 32
  
    //for button titles
      static let FontBtnTitle = UIFont(name: AppFontName.medium, size: FontConstants.fontNormalBtn)
    //for news description
    static let smallFontTitle = UIFont(name: AppFontName.regular, size: FontConstants.fontSmallTitle)
    static let LargeFontTitle = UIFont(name: AppFontName.regular, size: FontConstants.fontLargeTitle)
    static let NormalFontTitle = UIFont(name: AppFontName.regular, size: FontConstants.fontNormalTitle)
    static let smallFontTitleMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontSmallTitle)
    static let LargeFontTitleMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontLargeTitle)
    static let NormalFontTitleMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontNormalTitle)
    //for news title
    static let smallFontHeadingBold = UIFont(name: AppFontName.bold, size: FontConstants.fontSmallHeading)
    static let LargeFontHeadingBold = UIFont(name: AppFontName.bold, size: FontConstants.fontLargeHeading)
    static let NormalFontHeadingBold = UIFont(name: AppFontName.bold, size: FontConstants.fontNormalHeading)
    static let smallFontHeading = UIFont(name: AppFontName.regular, size: FontConstants.fontSmallHeading)
    static let LargeFontHeading = UIFont(name: AppFontName.regular, size: FontConstants.fontLargeHeading)
    static let NormalFontHeading = UIFont(name: AppFontName.regular, size: FontConstants.fontNormalHeading)
  
    //for source, time
    static let smallFontContentBold = UIFont(name: AppFontName.bold, size: FontConstants.fontSmallContent)
    static let LargeFontContentBold = UIFont(name: AppFontName.bold, size: FontConstants.fontLargeContent)
    static let NormalFontContentBold = UIFont(name: AppFontName.bold, size: FontConstants.fontNormalContent)
    static let smallFontContentMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontSmallContent)
    static let LargeFontContentMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontLargeContent)
    static let NormalFontContentMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontNormalContent)
    static let  smallFontContent = UIFont(name: AppFontName.regular, size: FontConstants.fontSmallContent)
    static let LargeFontContent = UIFont(name: AppFontName.regular, size: FontConstants.fontLargeContent)
    static let NormalFontContent = UIFont(name: AppFontName.regular, size: FontConstants.fontNormalContent)
    //for title labels on each screen
    static let viewTitleFont = UIFont(name: AppFontName.bold, size: FontConstants.fontViewTitle)
    //for settings tableview header
    static let settingsTVHeader = UIFont(name: AppFontName.medium, size: FontConstants.fontSettingsTVHeader)
    static let appFont = UIFont(name: AppFontName.bold, size: FontConstants.fontAppTitle)
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



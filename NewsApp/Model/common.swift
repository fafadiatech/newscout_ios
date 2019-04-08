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
    static let nightModeText = UIColor.white
    static let grayBackground1 = UIColor(hexFromString: "707070")
    static let grayBackground2 = UIColor(hexFromString: "A8A8A8")
    static let grayBackground3 = UIColor(hexFromString: "C0C0C0")
    static let txtlightGrayColor = UIColor(hexFromString: "9B9B9B")
    static let txtDarkGrayColor = UIColor(hexFromString: "424242")
    static let TVgrayBackground = UIColor(hexFromString: "FAF9F8")
    static let subTVgrayBackground = UIColor(hexFromString: "A6ACAF") //A6ACAF
    static let MenugrayBackground = UIColor(hexFromString: "F3EFED")
}

struct FontConstants{
    static let isPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone)
    static let fontSize:CGFloat = isPhone ? 12 :20
    static let fontxLarge:CGFloat = isPhone ? 16:24 //16
    static let fontxNormal:CGFloat = isPhone ? 15 :22 //14
    static let fontxSmall:CGFloat = isPhone ? 12 :20 //12
    static let fontLargeHeading:CGFloat = isPhone ? 21:22 //25
    static let fontNormalHeading:CGFloat = isPhone ? 19 :20 //22
    static let fontSmallHeading:CGFloat = isPhone ? 17 :18 //18
    static let fontLargeTitle:CGFloat = isPhone ? 21:26 //21
    static let fontNormalTitle:CGFloat = isPhone ? 17 :25//18
    static let fontSmallTitle:CGFloat = isPhone ? 14 :20 //14
    static let fontLargeContent:CGFloat = isPhone ? 18 :22 //18
    static let fontNormalContent:CGFloat = isPhone ? 16 :20 //14
    static let fontSmallContent:CGFloat = isPhone ? 14 :18 //10
    static let fontNormalBtn: CGFloat = isPhone ? 18 :26
    static let fontViewTitle:CGFloat = isPhone ? 23 : 35
    static let fontSettingsTVHeader:CGFloat = isPhone ? 20 : 23
    static let fontAppTitle:CGFloat = isPhone ? 22 : 32
    
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
    static let smallRecommFont = UIFont(name: AppFontName.regular, size: FontConstants.fontxSmall)
     static let largeRecommFont = UIFont(name: AppFontName.regular, size: FontConstants.fontxLarge)
     static let normalRecommFont = UIFont(name: AppFontName.regular, size: FontConstants.fontxNormal)
    static let smallRecommTitleFont = UIFont(name: AppFontName.bold, size: FontConstants.fontxSmall)
    static let largeRecommTitleFont = UIFont(name: AppFontName.bold, size: FontConstants.fontxLarge)
    static let normalRecommTitleFont = UIFont(name: AppFontName.bold, size: FontConstants.fontxNormal)
}

struct Constants{
    static let AppName = "NewScout"
    static let InternetErrorMsg = "The Internet connection appears to be offline"
}

struct AssetConstants{
    static let f1 = "f1"
    static let f2 = "f2"
    static let f3 = "f3"
    static let backArrow = "back1"
    static let cross = "cross"
    static let bookmark = "bookmark"
    static let Bookmark_white = "Bookmark_white"
    static let Bookmark_white_fill = "Bookmark_white_fill"
    static let filledBookmark = "filledBookmark"
    static let pause = "pause"
    static let play = "play"
    static let share = "share"
    static let thumb_up = "thumb_up"
    static let thumb_up_filled = "thumb_up_filled"
    static let thumb_down = "thumb_down"
    static let thumb_down_filled = "thumb_down_filled"
    static let NoImage = "NoImage"
    static let search = "newsearch"
    static let settings = "settings"
    static let appLogo = "Logo"
    static let glogo = "glogo"
    static let flogo = "flogo"
    static let menu = "menu"
    static let sector = "sector_update"
    static let regional = "internet"
    static let economy = "economy"
    static let finance = "finance"
    static let misc = "news"
    static let moon = "moon24"
    static let whiteMoon = "moon_white24"
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
        static let Local = "http://www.newscout.in" // " // "http://192.168.2.204" //"http://192.168.2.151:8000"//
        static let searchServer = "http://www.newscout.in"
        static let Server = ""
        static let version = "/api/v1/"
    }
    
    private  struct Routes {
        static let Articles = Domains.version + "articles/?page="
        static let ArticlesByCategory = Domains.version + "articles/?category="
        static let ArticleDetail = Domains.version + "articles/"
        static let Login = Domains.version + "login/"
        static let SignUp = Domains.version + "signup/"
        static let Logout = Domains.version + "logout/"
        static let Categories = Domains.version + "categories"
        static let Search = Domains.version + "article/search/?q="
        static let Source = Domains.version + "article/search/?source="
        static let recommendation = Domains.version + "articles/" // + "\(articleId)" + "/recommendations/"
        static let bookmark = Domains.version + "articles/bookmark/"
        static let likeDislike =  Domains.version + "articles/vote/"
        static let forgotPassword = Domains.version + "forgot-password/"
        static let changePassword = Domains.version + "change-password/"
        static let bookmarkedArticles = Domains.version + "bookmark-articles/"
        static let saveRemoveCategory = Domains.version + "categories/save-remove/"
        static let getLikeList = Domains.version + "articles/like-news-list/"
        static let getBookmarkList = Domains.version + "bookmark-articles/bookmark-news-list/"
        static let getTags = Domains.version + "tags/"
        static let ArticlesBytags = Domains.version + "article/search?"
        static let ArticleById = Domains.version + "article/search?category="
        static let ArtilceByTags2 = Domains.version + "articles/?"
        static let menu = Domains.version + "menus"
        static let deviceDetails = Domains.version + "device/"
        static let NotificationDetails = Domains.version + "notification/"
        static let socialLogin = Domains.version + "social-login/"
    }
    
    static let ArticlesURL = Domains.Local + Routes.Articles
    static let ArticlesByCategoryURL = Domains.Local + Routes.ArticlesByCategory
    static let ArticleDetailURL =  Domains.Local + Routes.ArticleDetail
    static let LoginURL = Domains.Local + Routes.Login
    static let SignUpURL =  Domains.Local + Routes.SignUp
    static let LogoutURL =  Domains.Local + Routes.Logout
    static let CategoriesURL =  Domains.Local + Routes.Categories
    static let SearchURL =  Domains.Local + Routes.Search
    static let SourceURL = Domains.Local + Routes.Source
    static let recommendationURL = Domains.Local + Routes.recommendation
    static let bookmarkURL = Domains.Local + Routes.bookmark
    static let likeDislikeURL = Domains.Local + Routes.likeDislike
    static let forgotPasswordURL = Domains.Local + Routes.forgotPassword
    static let changePasswordURL = Domains.Local + Routes.changePassword
    static let bookmarkedArticlesURL = Domains.Local + Routes.bookmarkedArticles
    static let saveRemoveCategoryURL = Domains.Local + Routes.saveRemoveCategory
    static let getLikeListURL = Domains.Local + Routes.getLikeList
    static let getBookmarkListURL = Domains.Local + Routes.getBookmarkList
    static let getTagsURL = Domains.Local + Routes.getTags
    static let ArticlesByTagsURL = Domains.Local + Routes.ArticlesBytags
    static let ArticlesByTagsURL2 = Domains.Local + Routes.ArtilceByTags2
    static let getMenus = Domains.Local + Routes.menu
    static let sendDeviceDetailsURL = Domains.Local + Routes.deviceDetails
    static let sendNotificationDetails = Domains.Local + Routes.NotificationDetails
    static let ArticleByIdURL = Domains.Local + Routes.ArticleById
    static let socialLoginURL = Domains.Local + Routes.socialLogin
    static let imageServer = "http://images.newscout.in/unsafe/"
    
}



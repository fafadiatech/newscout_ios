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
    static let MenugrayBackground = UIColor(hexFromString: "808080")
    static let cardNormalBackground = UIColor(hexFromString: "E7E8E6")
    static let cellBackground = UIColor(hexFromString: "EFEFEF") //DEDEDE
}

struct FontConstants{
    static let isPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone)
    static let fontSize:CGFloat = isPhone ? 12 :20
    static let fontxLarge:CGFloat = isPhone ? 16:22 //16
    static let fontxNormal:CGFloat = isPhone ? 15 :20 //14
    static let fontxSmall:CGFloat = isPhone ? 12 :18 //12
    static let fontLargeHeading:CGFloat = isPhone ? 19:20 //25
    static let fontNormalHeading:CGFloat = isPhone ? 17 :18 //22
    static let fontSmallHeading:CGFloat = isPhone ? 15 :17 //18
    static let fontLargeTitle:CGFloat = isPhone ? 21:26 //21
    static let fontNormalTitle:CGFloat = isPhone ? 17 :25//18
    static let fontSmallTitle:CGFloat = isPhone ? 14 :20 //14
    static let fontLargeContent:CGFloat = isPhone ? 19 :19 //18
    static let fontNormalContent:CGFloat = isPhone ? 17 :16 //14
    static let fontSmallContent:CGFloat = isPhone ? 16 :15 //10
    static let fontNormalBtn: CGFloat = isPhone ? 18 :26
    static let fontViewTitle:CGFloat = isPhone ? 23 : 35
    static let fontSettingsTVHeader:CGFloat = isPhone ? 20 : 23
    static let fontAppTitle:CGFloat = isPhone ? 22 : 32
    static let fontsmallDetailTitle:CGFloat = isPhone ? 17 : 19
    static let fontNormalDetailTitle:CGFloat = isPhone ? 19 : 21
    static let fontLargeDetailTitle:CGFloat = isPhone ? 21 : 23
    static let fontsmallDetailContent:CGFloat = isPhone ? 16 : 16
    static let fontNormalDetailContent:CGFloat = isPhone ? 18 : 17
    static let fontLargeDetailCOntent:CGFloat = isPhone ? 20 : 19
    //for button titles
    static let FontBtnTitle = UIFont(name: AppFontName.medium, size: FontConstants.fontNormalBtn)
    //for news description

    static let smallFontTitleMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontSmallTitle)
    static let LargeFontTitleMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontLargeTitle)
    static let NormalFontTitleMedium = UIFont(name: AppFontName.medium, size: FontConstants.fontNormalTitle)
    static let smallFontContentDetail = UIFont(name: AppFontName.regular, size: FontConstants.fontsmallDetailContent)
    static let LargeFontContentDetail = UIFont(name: AppFontName.regular, size: FontConstants.fontLargeDetailCOntent)
    static let NormalFontContentDetail = UIFont(name: AppFontName.regular, size: FontConstants.fontNormalDetailContent)
    //for news title
    static let smallFontHeadingBold = UIFont(name: AppFontName.bold, size: FontConstants.fontSmallHeading)
    static let LargeFontHeadingBold = UIFont(name: AppFontName.bold, size: FontConstants.fontLargeHeading)
    static let NormalFontHeadingBold = UIFont(name: AppFontName.bold, size: FontConstants.fontNormalHeading)
    
    static let smallFontDetailTitle = UIFont(name: AppFontName.bold, size: FontConstants.fontsmallDetailTitle)
    static let LargeFontDetailTitle = UIFont(name: AppFontName.bold, size: FontConstants.fontLargeDetailTitle)
    static let NormalFontDetailTitle = UIFont(name: AppFontName.bold, size: FontConstants.fontNormalDetailTitle)
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
    //for recommendation title
    static let  smallFontRecomContent = UIFont(name: AppFontName.bold, size: FontConstants.fontSmallContent)
    static let LargeFontRecomContent = UIFont(name: AppFontName.bold, size: FontConstants.fontLargeContent)
    static let NormalFontRecomContent = UIFont(name: AppFontName.bold, size: FontConstants.fontNormalContent)
    //for title labels on each screen
    static let viewTitleFont = UIFont(name: AppFontName.bold, size: FontConstants.fontViewTitle)
    //for settings tableview header
    static let settingsTVHeader = UIFont(name: AppFontName.medium, size: FontConstants.fontSettingsTVHeader)
    static let appFont = UIFont(name: AppFontName.bold, size: FontConstants.fontAppTitle)
}

struct Constants{
    static let AppName = "NewScout"
    static let InternetErrorMsg = "The Internet connection appears to be offline"
    static let platform = "ios"
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
    static let appLogo = "logo"
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
    static let screen1 = "Top-Menu"
    static let screen2 = "Bottom_Menu"
    static let screen3 = "Article_Details"
    static let screen4 = "More_Stories_Section"
    static let screen5 = "Share_screen"
    static let screen6 = "Search_screen"
    static let searchWhite = "search_white"
    static let searchBlack = "search_black"
    static let menuBlack = "menublack"
    static let menuWhite = "menuwhite"
    static let submenuBackground = "submenuBack"
    static let asia = "asia"
    static let banking = "banking"
    static let china = "china"
    static let food = "food"
    static let energy = "energy"
    static let funding = "funding"
    static let ipo = "ipo"
    static let india = "india"
    static let japan = "japan"
    static let manufacturing = "manufacturing"
    static let personal_finance = "personal_finance"
    static let recession = "recession"
    static let retail = "retail"
    static let tech = "tech"
    static let transport = "transport"
    static let us = "us"
    static let crypto = "crypto"
    static let fintech = "fintech"
    static let media = "media"
    static let trending = "newspaper"
    static let latest = "latest_news"
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
        static let Local = "http://localhost:8000" // " // "http://192.168.2.204" //"http://192.168.2.151:8000"//
        static let searchServer = "http://www.newscout.in"
        static let Server = "http://www.newscout.in"
        static let version = "/api/v1/"
        static let tracking = "http://t.fafadiatech.com"
    }
    
    static let apiVer = "/api/v1/"
    static let ArticlesURL = Domains.Server + apiVer + "articles/?page="
    static let ArticlesByCategoryURL = Domains.Server + apiVer + "articles/?category="
    static let ArticleDetailURL =  Domains.Server + apiVer + "articles/"
    static let LoginURL = Domains.Server + apiVer + "login/"
    static let SignUpURL =  Domains.Server + apiVer + "signup/"
    static let LogoutURL =  Domains.Server + apiVer + "logout/"
    static let SearchURL =  Domains.Server + apiVer + "article/search/?q="
    static let SourceURL = Domains.Server + apiVer + "article/search/?source="
    static let recommendationURL = Domains.Server + apiVer + "articles/"
    static let bookmarkURL = Domains.Server + apiVer + "articles/bookmark/"
    static let likeDislikeURL = Domains.Server + apiVer + "articles/vote/"
    static let forgotPasswordURL = Domains.Server + apiVer + "forgot-password/"
    static let changePasswordURL = Domains.Server + apiVer + "change-password/"
    static let bookmarkedArticlesURL = Domains.Server + apiVer + "bookmark-articles/"
    static let saveRemoveCategoryURL = Domains.Server + apiVer + "categories/save-remove/"
    static let getLikeListURL = Domains.Server + apiVer + "articles/like-news-list/"
    static let getBookmarkListURL = Domains.Server + apiVer + "bookmark-articles/bookmark-news-list/"
    static let ArticlesByTagsURL = Domains.Server + apiVer + "article/search?"
    static let ArticlesByTagsURL2 = Domains.Server + apiVer + "article/search?category="
    static let getMenus = Domains.Server + apiVer + "menus/?domain=newscout"
    static let sendDeviceDetailsURL = Domains.Server + apiVer + "menus/"
    static let sendNotificationDetails = Domains.Server + apiVer + "device/"
    static let ArticleByIdURL = Domains.Server + apiVer + "notification/"
    static let socialLoginURL = Domains.Server + apiVer + "social-login/"
    static let trendingURL = Domains.Server + apiVer + "trending/?domain=newscout"
    static let dailyDigest = Domains.Server + apiVer + "daily-digest"
    static let trackingURL = Domains.tracking + "track?"
    static let imageServer = "http://images.newscout.in/unsafe/"
}


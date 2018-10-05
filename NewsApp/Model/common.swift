//
//  File.swift
//  NewsApp
//
//  Created by Jayashri on 25/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//
import UIKit
var textSizeSelected = 1
var isSearch = false
struct Constants{
    static let isPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone)
    static let fontSize:CGFloat = isPhone ? 12 :20
    static let fontLargeTitle:CGFloat = isPhone ? 21:20
    static let fontNormalTitle:CGFloat = isPhone ? 17 :20
    static let fontSmallTitle:CGFloat = isPhone ? 14 :20
    static let fontLargeContent:CGFloat = isPhone ? 18 :20
    static let fontNormalContent:CGFloat = isPhone ? 14 :20
    static let fontSmallContent:CGFloat = isPhone ? 10 :20
    
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

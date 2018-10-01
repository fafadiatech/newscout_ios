//
//  File.swift
//  NewsApp
//
//  Created by Jayashri on 25/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//
import UIKit
extension UIFont {
    
    class func myFontName() -> String { return "System" }
    class func myBoldFontName() -> String { return "System" }
    
    class func myNormalFont() -> UIFont {
        return UIFont(name: UIFont.myFontName(), size: 12)!
    }
    
    class func mySmallBoldFont() -> UIFont {
        return UIFont(name: UIFont.myBoldFontName(), size: 70)!
    }
}

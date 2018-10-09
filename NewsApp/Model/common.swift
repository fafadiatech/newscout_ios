//
//  File.swift
//  NewsApp
//
//  Created by Jayashri on 25/09/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//
import UIKit
var textSizeSelected = 1
var currentIndex = 0
var isSearch = false
var smallFont = UIFont(name: AppFontName.regular, size: Constants.fontSmallTitle)
var LargeFont = UIFont(name: AppFontName.regular, size: Constants.fontLargeTitle)
var NormalFont = UIFont(name: AppFontName.regular, size: Constants.fontNormalTitle)
var smallFontMedium = UIFont(name: AppFontName.medium, size: Constants.fontSmallTitle)
var LargeFontMedium = UIFont(name: AppFontName.medium, size: Constants.fontLargeTitle)
var NormalFontMedium = UIFont(name: AppFontName.medium, size: Constants.fontNormalTitle)

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

struct AppFontName {
    static let regular = "HelveticaNeue"
    static let medium = "HelveticaNeue-Medium"

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
//show an image from url
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleToFill) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

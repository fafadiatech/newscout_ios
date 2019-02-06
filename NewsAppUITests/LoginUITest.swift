//
//  LoginUITest.swift
//  NewsAppUITests
//
//  Created by Jayashree on 21/12/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import Foundation
import XCTest

class LoginUITest: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testValidLogin() {
        let validEmail = "yamini@gmail.com"
        let validPassword = "ftech#123"
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element
        element.children(matching: .other).element(boundBy: 1).children(matching: .button).element.tap()
        element.children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 1).tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Login"]/*[[".cells.staticTexts[\"Login\"]",".staticTexts[\"Login\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let txtEmail = app.textFields["Enter Email"]
        XCTAssertTrue(txtEmail.exists)
        txtEmail.tap()
        txtEmail.typeText(validEmail)
        let txtPassword = app.secureTextFields["Enter Password"]
        XCTAssertTrue(txtPassword.exists)
        txtPassword.tap()
        txtPassword.typeText(validPassword)
        app.buttons["LOGIN"].tap()
        let TxtAppheading = app.staticTexts["NewScout"]
        XCTAssertTrue(TxtAppheading.exists)
    }
    func testInvalidLogin()
    {
        
        let app = XCUIApplication()
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element
        element.children(matching: .other).element(boundBy: 1).children(matching: .button).element.tap()
        element.children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 1).tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Login"]/*[[".cells.staticTexts[\"Login\"]",".staticTexts[\"Login\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.textFields["Enter Email"].tap()
        app.secureTextFields["Enter Password"].tap()
        
        let loginButton = app.buttons["LOGIN"]
        loginButton.tap()
        let TxtAppheading = app.staticTexts["NewScout"]
        XCTAssertFalse(TxtAppheading.exists)
        let txtLoginHeading = app.staticTexts["Login"]
        XCTAssertTrue(txtLoginHeading.exists)
        //    let toastMsg = app.alerts["Unable to login with provided credentials"]
        //    XCTAssertTrue(toastMsg.exists)
    }
    
    func testgmailLogin(){
        
    }
    
}

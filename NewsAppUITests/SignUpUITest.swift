//
//  SignUpUITest.swift
//  NewsAppUITests
//
//  Created by Jayashree on 21/12/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import Foundation
import XCTest

class SignUpUITest: XCTestCase {
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
    
    func testSignUp(){
        let app = XCUIApplication()
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element
        element.children(matching: .other).element(boundBy: 1).children(matching: .button).element.tap()
        element.children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 1).tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Login"]/*[[".cells.staticTexts[\"Login\"]",".staticTexts[\"Login\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let btnSignUpLink = app.buttons["No account yet? Create one"]
        XCTAssertTrue(btnSignUpLink.exists)
        btnSignUpLink.tap()
        let txtFirstNAme = app.textFields["Enter First Name"]
        XCTAssertTrue(txtFirstNAme.exists)
        txtFirstNAme.tap()
        let txtLastName = app.textFields["Enter Last Name"]
        XCTAssertTrue(txtLastName.exists)
        txtLastName.tap()
        let txtEmail = app.textFields["Enter Email"]
        XCTAssertTrue(txtEmail.exists)
        txtEmail.tap()
        let txtPassword = app.secureTextFields["Enter Password"]
        XCTAssertTrue(txtPassword.exists)
        txtPassword.tap()
        let txtRetypePswd = app.secureTextFields["Retype Password"]
        XCTAssertTrue(txtRetypePswd.exists)
        txtRetypePswd.tap()
        app.buttons["Sign Up"].tap()
//        let txtLoginheading = app.staticTexts["Login"]
//        XCTAssertTrue(txtLoginheading.exists)
       
    }
   
}

//
//  Screenshots.swift
//  Screenshots
//
//  Created by Mark Cornelisse on 06/06/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import XCTest

class Screenshots: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testScreenshot() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            debugPrint("Making a cool interface.")
            
            let app = app2
            app.tables["Press \"New event\" to add the event on which you'd like to share the expenses with your friends."].buttons["New event"].tap()
            
            let pressAddPersonToAddAPersonWhoYouDLikeToShareThisBillWithTable = app.tables["Press \"Add person\" to add a person who you'd like to share this bill with."]
            let activityNameTextField = pressAddPersonToAddAPersonWhoYouDLikeToShareThisBillWithTable.textFields["Activity name"]
            activityNameTextField.tap()
            activityNameTextField.tap()
            
            let element = app.otherElements.containing(.navigationBar, identifier:"MCSharedBillMainView").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0)
            element.tap()
            pressAddPersonToAddAPersonWhoYouDLikeToShareThisBillWithTable.buttons["Add person"].tap()
            
            let emptyListTable = app.tables["Empty list"]
            let firstNameTextField = emptyListTable.textFields["First Name"]
            firstNameTextField.tap()
            
            let lastNameTextField = emptyListTable.textFields["Last name"]
            lastNameTextField.tap()
            
            let emailAddressTextField = emptyListTable.textFields["email address"]
            emailAddressTextField.tap()
            
            let mcpersonviewNavigationBar = app.navigationBars["MCPersonView"]
            let doneButton = mcpersonviewNavigationBar.buttons["Done"]
            doneButton.tap()
            
            let tablesQuery = app.tables
            let addPersonButton = tablesQuery.buttons["Add person"]
            addPersonButton.tap()
            firstNameTextField.tap()
            lastNameTextField.tap()
            emailAddressTextField.tap()
            doneButton.tap()
            
            let app2 = app
            app2.navigationBars["MCSharedBillMainView"]/*@START_MENU_TOKEN@*/.buttons["Payments"]/*[[".segmentedControls.buttons[\"Payments\"]",".buttons[\"Payments\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.tables["Press \"Add payment\" to add a payment to this event"].buttons["Add payment"].tap()
            tablesQuery.textFields["Who paid?"].tap()
            app2/*@START_MENU_TOKEN@*/.pickerWheels["David Tucker"]/*[[".pickers.pickerWheels[\"David Tucker\"]",".pickerWheels[\"David Tucker\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.toolbars["Toolbar"].buttons["Done"].tap()
            tablesQuery.buttons["Select Category"].tap()
            app2.tables/*@START_MENU_TOKEN@*/.staticTexts["Tickets"]/*[[".cells.staticTexts[\"Tickets\"]",".staticTexts[\"Tickets\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            tablesQuery.textFields["What got paid?"].tap()
            tablesQuery.textFields["How much is spent?"].tap()
            tablesQuery.children(matching: .other).element.tap()
            app.navigationBars["MCPaymentView"].buttons["Done"].tap()
            app.navigationBars["MCSharedBillMainView"].buttons["Events"].tap()            
        case .pad:
            ()
        default:
            fatalError("Unknown interface idiom")
        }
    }

}

//
//  Screenshots.swift
//  Screenshots
//
//  Created by Mark Cornelisse on 06/06/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import XCTest

class Screenshots: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

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
            snapshot("01-AllEventsViewController")
            app.tables.cells.element(boundBy: 0).tap()
            let mcsharedbillmainviewNavigationBar = app.navigationBars["MCSharedBillMainView"]
            mcsharedbillmainviewNavigationBar.segmentedControls.buttons.element(boundBy: 0).tap()

            app!.navigationBars["MCSharedBillMainView"].segmentedControls.buttons.element(boundBy: 0).tap()
            snapshot("02-PeoplePresentViewController")
            app!.navigationBars["MCSharedBillMainView"].segmentedControls.buttons.element(boundBy: 1).tap()
            snapshot("03-PaymentsViewController")
            let tablesQuery = app.scrollViews.otherElements.tables
            tablesQuery/*@START_MENU_TOKEN@*/.buttons["Add Payment"]/*[[".buttons[\"Add payment\"]",".buttons[\"Add Payment\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            snapshot("04-PaymentViewController")
            app.navigationBars["MCPaymentView"].buttons["Cancel"].tap()
            tablesQuery.buttons["Solve"].tap()
            snapshot("05-SolutionViewController")

        case .pad:
            snapshot("01-AllEventsViewController")
            app.tables.cells.element(boundBy: 0).tap()
            let mcsharedbillmainviewNavigationBar = app.navigationBars["MCSharedBillMainView"]
            mcsharedbillmainviewNavigationBar.segmentedControls.buttons.element(boundBy: 0).tap()

            app!.navigationBars["MCSharedBillMainView"].segmentedControls.buttons.element(boundBy: 0).tap()
            snapshot("02-PeoplePresentViewController")
            app!.navigationBars["MCSharedBillMainView"].segmentedControls.buttons.element(boundBy: 1).tap()
            snapshot("03-PaymentsViewController")
            let tablesQuery = app.scrollViews.otherElements.tables
            tablesQuery/*@START_MENU_TOKEN@*/.buttons["Add Payment"]/*[[".buttons[\"Add payment\"]",".buttons[\"Add Payment\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            snapshot("04-PaymentViewController")
            app.navigationBars.element(boundBy: 1).buttons["Cancel"].tap()
            app.buttons["Solve"].tap()
            snapshot("05-SolutionViewController")
        default:
            fatalError("Unknown interface idiom")
        }
    }

}

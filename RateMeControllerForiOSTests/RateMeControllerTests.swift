//
//  RateMeControllerTests.swift
//  RateMeForOSX
//
//  Created by Mark Cornelisse on 12/01/16.
//  Copyright © 2016 Over de muur producties. All rights reserved.
//

import XCTest
@testable import RateMeControllerForiOS

class RateMeControllerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        RateMeController.reset()        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let rmc = RateMeController()
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
    }
    
    func testShouldDisplayRateMeQuestion() {
        let twentyEightDaysAgo = Date(timeIntervalSinceNow: -rateMeControllerTimeIntervalInDays * 86400.0)
        let rmc = RateMeController(firstDate: twentyEightDaysAgo, counterValue: 0, shouldAsk: RateMeControllerAskStatusContainer())
        XCTAssertTrue(rmc.shouldDisplayRateMeQuestion)
        let rmc2 = RateMeController(firstDate: Date(timeIntervalSinceNow: -(rateMeControllerMinimumTimeIntervalInDays + 4) * 86400), counterValue: rateMeControllerCounterInterval - 1, shouldAsk: RateMeControllerAskStatusContainer())
        XCTAssertFalse(rmc2.shouldDisplayRateMeQuestion)
        XCTAssertTrue(rmc2.shouldDisplayRateMeQuestion)
        XCTAssertTrue(rmc2.shouldDisplayRateMeQuestion)
        let rmc3 = RateMeController(firstDate: Date(timeIntervalSinceNow: -(rateMeControllerMinimumTimeIntervalInDays - 1) * 86400), counterValue: 22, shouldAsk: RateMeControllerAskStatusContainer())
        XCTAssertFalse(rmc3.shouldDisplayRateMeQuestion)
        let rmc4 = RateMeController(firstDate: Date(timeIntervalSinceNow: -(rateMeControllerMinimumTimeIntervalInDays - 1) * 86400), counterValue: 20, shouldAsk: RateMeControllerAskStatusContainer())
        XCTAssertFalse(rmc4.shouldDisplayRateMeQuestion)
    }
    
    func testRateMeDisplayed() {
        let thisVersionString = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let twentyEightDaysAgo = Date(timeIntervalSinceNow: -rateMeControllerTimeIntervalInDays * 86400.0)
        var rmc = RateMeController(firstDate: twentyEightDaysAgo, counterValue: 0, shouldAsk: RateMeControllerAskStatusContainer())
        XCTAssertTrue(rmc.shouldDisplayRateMeQuestion)
        rmc.rateMeDisplayed(RateMeControllerAskStatus.noNever)
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc.rateMeDisplayed(RateMeControllerAskStatus.no)
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc.rateMeDisplayed(RateMeControllerAskStatus.yes)
        XCTAssertTrue(rmc.shouldDisplayRateMeQuestion)
        rmc.rateMeDisplayed(RateMeControllerAskStatus.alreadyRated)
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc = RateMeController(firstDate: Date(timeIntervalSinceNow: -rateMeControllerMinimumTimeIntervalInDays * 86400), counterValue: rateMeControllerCounterInterval + 1, shouldAsk: RateMeControllerAskStatusContainer())
        XCTAssertTrue(rmc.shouldDisplayRateMeQuestion)
        rmc.rateMeDisplayed(RateMeControllerAskStatus.alreadyRated)
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc.rateMeDisplayed(RateMeControllerAskStatus.yes)
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc = RateMeController(firstDate: Date(timeIntervalSinceNow: -rateMeControllerTimeIntervalInDays * 86400), counterValue: 40, shouldAsk: RateMeControllerAskStatusContainer(shouldAsk: RateMeControllerAskStatus.no, lastVersion: thisVersionString))
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc = RateMeController(firstDate: Date(timeIntervalSinceNow: -rateMeControllerTimeIntervalInDays * 86400), counterValue: 40, shouldAsk: RateMeControllerAskStatusContainer(shouldAsk: RateMeControllerAskStatus.noNever, lastVersion: thisVersionString))
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc = RateMeController(firstDate: Date(timeIntervalSinceNow: -rateMeControllerTimeIntervalInDays * 86400), counterValue: 40, shouldAsk: RateMeControllerAskStatusContainer(shouldAsk: RateMeControllerAskStatus.alreadyRated, lastVersion: thisVersionString))
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc = RateMeController(firstDate: Date(timeIntervalSinceNow: -rateMeControllerTimeIntervalInDays * 86400), counterValue: 40, shouldAsk: RateMeControllerAskStatusContainer(shouldAsk: RateMeControllerAskStatus.alreadyRated, lastVersion: "0"))
        XCTAssertTrue(rmc.shouldDisplayRateMeQuestion)
    }
    
    func testSave() {
        let now = Date()
        let rmc = RateMeController()
        _ = rmc.save()
        let savedDate = UserDefaults.standard.object(forKey: "kFirstLaunchDate") as? Date
        let savedDataShouldAsk = UserDefaults.standard.object(forKey: "kRateMeControllerAskStatus") as? Data
        let savedShouldAsk = NSKeyedUnarchiver.unarchiveObject(with: savedDataShouldAsk!) as? RateMeControllerAskStatusContainer
        let savedCounter = UserDefaults.standard.integer(forKey: "kRateMeControllerCounterValue")
        let timeintervalDifference = savedDate!.timeIntervalSince(now)
        XCTAssertEqual(0.02, timeintervalDifference, accuracy: 0.02)
        XCTAssertNotNil(savedShouldAsk)
        XCTAssertEqual(0, savedCounter)
        RateMeController.reset()
        let clearedDate = UserDefaults.standard.object(forKey: "kFirstLaunchDate") as? Date
        XCTAssertNil(clearedDate)
        let clearedShouldAsk = UserDefaults.standard.object(forKey: "kRateMeControllerAskStatus")
        XCTAssertNil(clearedShouldAsk)
        let clearedCounter = UserDefaults.standard.integer(forKey: "kRateMeControllerCounterValue")
        XCTAssertEqual(0, clearedCounter)
        
        let firstDate = Date(timeIntervalSinceNow: -15.0 * 86400.0)
        let initialCounter = 45
        let rmc2 = RateMeController(firstDate: firstDate, counterValue: initialCounter, shouldAsk: RateMeControllerAskStatusContainer())
        _ = rmc2.save()
        
        let rmc3 = RateMeController()
        XCTAssertTrue(rmc3.shouldDisplayRateMeQuestion)
        UserDefaults.standard.removeObject(forKey: "kFirstLaunchDate")
        UserDefaults.standard.removeObject(forKey: "kRateMeControllerAskStatus")
        UserDefaults.standard.removeObject(forKey: "kRateMeControllerCounterValue")
    }
}

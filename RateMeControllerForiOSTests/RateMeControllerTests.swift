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
        let twentyEightDaysAgo = NSDate(timeIntervalSinceNow: -rateMeControllerTimeIntervalInDays * 86400.0)
        let rmc = RateMeController(firstDate: twentyEightDaysAgo, counterValue: 0, shouldAsk: RateMeControllerAskStatusContainer())
        XCTAssertTrue(rmc.shouldDisplayRateMeQuestion)
        let rmc2 = RateMeController(firstDate: NSDate(timeIntervalSinceNow: -(rateMeControllerMinimumTimeIntervalInDays + 4) * 86400), counterValue: rateMeControllerCounterInterval - 1, shouldAsk: RateMeControllerAskStatusContainer())
        XCTAssertFalse(rmc2.shouldDisplayRateMeQuestion)
        XCTAssertTrue(rmc2.shouldDisplayRateMeQuestion)
        XCTAssertTrue(rmc2.shouldDisplayRateMeQuestion)
        let rmc3 = RateMeController(firstDate: NSDate(timeIntervalSinceNow: -(rateMeControllerMinimumTimeIntervalInDays - 1) * 86400), counterValue: 22, shouldAsk: RateMeControllerAskStatusContainer())
        XCTAssertFalse(rmc3.shouldDisplayRateMeQuestion)
        let rmc4 = RateMeController(firstDate: NSDate(timeIntervalSinceNow: -(rateMeControllerMinimumTimeIntervalInDays - 1) * 86400), counterValue: 20, shouldAsk: RateMeControllerAskStatusContainer())
        XCTAssertFalse(rmc4.shouldDisplayRateMeQuestion)
    }
    
    func testRateMeDisplayed() {
        let thisVersionString = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
        let twentyEightDaysAgo = NSDate(timeIntervalSinceNow: -rateMeControllerTimeIntervalInDays * 86400.0)
        var rmc = RateMeController(firstDate: twentyEightDaysAgo, counterValue: 0, shouldAsk: RateMeControllerAskStatusContainer())
        XCTAssertTrue(rmc.shouldDisplayRateMeQuestion)
        rmc.rateMeDisplayed(RateMeControllerAskStatus.NoNever)
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc.rateMeDisplayed(RateMeControllerAskStatus.No)
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc.rateMeDisplayed(RateMeControllerAskStatus.Yes)
        XCTAssertTrue(rmc.shouldDisplayRateMeQuestion)
        rmc.rateMeDisplayed(RateMeControllerAskStatus.AlreadyRated)
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc = RateMeController(firstDate: NSDate(timeIntervalSinceNow: -rateMeControllerMinimumTimeIntervalInDays * 86400), counterValue: rateMeControllerCounterInterval + 1, shouldAsk: RateMeControllerAskStatusContainer())
        XCTAssertTrue(rmc.shouldDisplayRateMeQuestion)
        rmc.rateMeDisplayed(RateMeControllerAskStatus.AlreadyRated)
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc.rateMeDisplayed(RateMeControllerAskStatus.Yes)
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc = RateMeController(firstDate: NSDate(timeIntervalSinceNow: -rateMeControllerTimeIntervalInDays * 86400), counterValue: 40, shouldAsk: RateMeControllerAskStatusContainer(shouldAsk: RateMeControllerAskStatus.No, lastVersion: thisVersionString))
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc = RateMeController(firstDate: NSDate(timeIntervalSinceNow: -rateMeControllerTimeIntervalInDays * 86400), counterValue: 40, shouldAsk: RateMeControllerAskStatusContainer(shouldAsk: RateMeControllerAskStatus.NoNever, lastVersion: thisVersionString))
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc = RateMeController(firstDate: NSDate(timeIntervalSinceNow: -rateMeControllerTimeIntervalInDays * 86400), counterValue: 40, shouldAsk: RateMeControllerAskStatusContainer(shouldAsk: RateMeControllerAskStatus.AlreadyRated, lastVersion: thisVersionString))
        XCTAssertFalse(rmc.shouldDisplayRateMeQuestion)
        rmc = RateMeController(firstDate: NSDate(timeIntervalSinceNow: -rateMeControllerTimeIntervalInDays * 86400), counterValue: 40, shouldAsk: RateMeControllerAskStatusContainer(shouldAsk: RateMeControllerAskStatus.AlreadyRated, lastVersion: "0"))
        XCTAssertTrue(rmc.shouldDisplayRateMeQuestion)
    }
    
    func testSave() {
        let now = NSDate()
        let rmc = RateMeController()
        rmc.save()
        let savedDate = NSUserDefaults.standardUserDefaults().objectForKey("kFirstLaunchDate") as? NSDate
        let savedDataShouldAsk = NSUserDefaults.standardUserDefaults().objectForKey("kRateMeControllerAskStatus") as? NSData
        let savedShouldAsk = NSKeyedUnarchiver.unarchiveObjectWithData(savedDataShouldAsk!) as? RateMeControllerAskStatusContainer
        let savedCounter = NSUserDefaults.standardUserDefaults().integerForKey("kRateMeControllerCounterValue")
        let timeintervalDifference = savedDate!.timeIntervalSinceDate(now)
        XCTAssertEqualWithAccuracy(0.02, timeintervalDifference, accuracy: 0.02)
        XCTAssertNotNil(savedShouldAsk)
        XCTAssertEqual(0, savedCounter)
        RateMeController.reset()
        let clearedDate = NSUserDefaults.standardUserDefaults().objectForKey("kFirstLaunchDate") as? NSDate
        XCTAssertNil(clearedDate)
        let clearedShouldAsk = NSUserDefaults.standardUserDefaults().objectForKey("kRateMeControllerAskStatus")
        XCTAssertNil(clearedShouldAsk)
        let clearedCounter = NSUserDefaults.standardUserDefaults().integerForKey("kRateMeControllerCounterValue")
        XCTAssertEqual(0, clearedCounter)
        
        let firstDate = NSDate(timeIntervalSinceNow: -15.0 * 86400.0)
        let initialCounter = 45
        let rmc2 = RateMeController(firstDate: firstDate, counterValue: initialCounter, shouldAsk: RateMeControllerAskStatusContainer())
        rmc2.save()
        
        let rmc3 = RateMeController()
        XCTAssertTrue(rmc3.shouldDisplayRateMeQuestion)
        NSUserDefaults.standardUserDefaults().removeObjectForKey("kFirstLaunchDate")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("kRateMeControllerAskStatus")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("kRateMeControllerCounterValue")
    }
}
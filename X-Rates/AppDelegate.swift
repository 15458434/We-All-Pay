//
//  AppDelegate.swift
//  EMC
//
//  Created by Mark Cornelisse on 12/02/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSSharingServiceDelegate {
//    var singleCurrencyWindow: NSWindow?
//    var multipleCurrencyInterface: MultipleCurrencyInterfaceController?
    
    // MARK: Actions
    @IBAction func giveFeedBackPresses(sender: AnyObject?) {
        let service: NSSharingService = NSSharingService(named: NSSharingServiceNameComposeEmail)!
        service.delegate = self
        service.recipients = ["support@markcornelisse.nl"]
        let bundleVersion: String = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as String
        service.subject = "Feedback on EMC version \(bundleVersion)"
        let body = "Dear mark, \n\n"
        service.performWithItems([body])
    }
    
    @IBAction func tweetThankYouPressed(sender: AnyObject?) {
        let service = NSSharingService(named: NSSharingServiceNamePostOnTwitter)
        let tweet = "Hey @MarkCornelisse, Thank you for creating EMC. #osx #app"
        service?.performWithItems([tweet])
    }
    
//    @IBAction func newWindowPressed(sender: AnyObject?) {
//        singleCurrencyWindow?.makeKeyAndOrderFront(self)
//    }
    
    @IBAction func closeKeyWindow(sender: AnyObject?) {
        var keyWindow: NSWindow! = NSApplication.sharedApplication().keyWindow
        keyWindow!.performClose(self)
    }
    
    // MARK: ApplicationDelegate
    
//    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
//        singleCurrencyWindow?.makeKeyAndOrderFront(self)
//        return false
//    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    // MARK: Shared Services Delegate
    func sharingService(sharingService: NSSharingService, didShareItems items: [AnyObject]) {
        println("Sharing succesful")
    }
    
    func sharingService(sharingService: NSSharingService, didFailToShareItems items: [AnyObject], error: NSError) {
        println("Sharing failed: \(error.description)")
    }
}


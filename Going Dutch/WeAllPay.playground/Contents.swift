//: Playground - noun: a place where people can play

import Foundation

let url = NSURL(string: "https://openexchangerates.org/api/latest.json?app_id=cba02a60bd89412095c84ecb65b6326a");

var fetchedResults: String?
let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
    if let realError = error {
        println("Error fetching exchangeRate from OpenExchangeRates: \(realError)")
        return
    }
    
    let httpResp = response as! NSHTTPURLResponse
    if (httpResp.statusCode == 200) {
        var jsonError: NSError?
        if let openExchangeRateDictonary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as? Dictionary<NSObject, AnyObject> {
            let baseCurrencyCode = openExchangeRateDictonary["base"] as! String
            let rates = openExchangeRateDictonary["rates"] as! [String: Double]
            rates["EUR"]
            rates["RUB"]
        } else {
            // JSON Error
            println("Error reading exchangeRatesFromJSON: \(jsonError)")
        }
    } else {
        // Status code != 200
    }

}

task.resume()
NSThread.sleepForTimeInterval(30)

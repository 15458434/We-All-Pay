//: Playground - noun: a place where people can play

import Foundation

let url = NSURL(string: "https://openexchangerates.org/api/latest.json?app_idcba02a60bd89412095c84ecb65b6326a");

var fetchedResults: String?
let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
    fetchedResults = NSString(data: data, encoding: NSUTF8StringEncoding)
}

task.resume()

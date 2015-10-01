//: Playground - noun: a place where people can play

import Foundation

let mark: Dictionary<String, String> = ["name": "Mark", "type": "Man"]
let lieke: Dictionary<String, String> = ["name": "Lieke", "type": "Vrouw"]
let merit: Dictionary<String, String> = ["name": "Merit", "type": "Vrouw"]
let marieke: Dictionary<String, String> = ["name": "Marieke", "type": "Vrouw"]
let joris: Dictionary<String, String> = ["name": "Joris", "type": "Man"]

let people = [mark, lieke, merit, marieke, joris]
let vrouwen = people.filter {$0["type"] == "Vrouw"}
print(vrouwen, 
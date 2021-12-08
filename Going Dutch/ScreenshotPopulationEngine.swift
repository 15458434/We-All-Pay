//
//  ScreenshotPopulationEngine.swift
//  We all pay
//
//  Created by Mark Cornelisse on 03/10/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import CoreData

#if SCREENSHOTS
/// This class populates the database so screenshots for the App Store can be made.
@objc public class ScreenshotPopulationEngine: NSObject {
    private let managedObjectContext: NSManagedObjectContext
    
    @objc(initWithManagedObjectContext:) public init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
    }
    
    @objc public func populate() {
        var david: (firstName: String, lastName: String, emailAddress: String) = {
            let firstName = NSLocalizedString("app_store_screenshots_person_firstname_1", value: "David", comment: "first name example for app store screenshots")
            let lastName = NSLocalizedString("app_store_screenshots_person_lastname_1", value: "Tucker", comment: "last name example for appstore screenshots")
            let emailAddress = NSLocalizedString("app_store_screenshots_person_email_1", value: "davidtucker@somewhere.com", comment: "example for appstore screenshots")
            return (firstName: firstName, lastName: lastName, emailAddress: emailAddress)
        }()
        
        var jake: (firstName: String, lastName: String, emailAddress: String) = {
            let firstName = NSLocalizedString("app_store_screenshots_person_firstname_2", value: "Jake", comment: "first name example for app store screenshots")
            let lastName = NSLocalizedString("app_store_screenshots_person_lastname_2", value: "Nichelson", comment: "last name example for appstore screenshots")
            let emailAddress = NSLocalizedString("app_store_screenshots_person_email_2", value: "jake@earth.com", comment: "example for appstore screenshots")
            return (firstName: firstName, lastName: lastName, emailAddress: emailAddress)
        }()

        var ann: (firstName: String, lastName: String, emailAddress: String) = {
            let firstName = NSLocalizedString("app_store_screenshots_person_firstname_3", value: "Ann", comment: "first name example for app store screenshots")
            let lastName = NSLocalizedString("app_store_screenshots_person_lastName_3", value: "Burwell", comment: "last name example for appstore screenshots")
            let emailAddress = NSLocalizedString("app_store_screenshots_person_email_3", value: "ann_burwell@work.com", comment: "example for appstore screenshots")
            return (firstName: firstName, lastName: lastName, emailAddress: emailAddress)
        }()

        var lauren: (firstName: String, lastName: String, emailAddress: String) = {
            let firstName = NSLocalizedString("app_store_screenshots_person_firstname_4", value: "Lauren", comment: "first name example for app store screenshots")
            let lastName = NSLocalizedString("app_store_screenshots_person_lastname_4" , value: "Mortimer", comment: "last name example for appstore screenshots")
            let emailAddress = NSLocalizedString("app_store_screenshots_person_email_4", value: "l.d.mortimer@internet.com", comment: "example for appstore screenshots")
            return (firstName: firstName, lastName: lastName, emailAddress: emailAddress)
        }()

        var sheila: (firstName: String, lastName: String, emailAddress: String) = {
            let firstName = NSLocalizedString("app_store_screenshots_person_firstname_5", value: "Sheila", comment: "first name example for app store screenshots")
            let lastName = NSLocalizedString("app_store_screenshots_person_lastname_5", value: "Miller", comment: "last name example for appstore screenshots")
            let emailAddress = NSLocalizedString("app_store_screenshots_person_email_5", value: "mailsheila@home.com", comment: "example for appstore screenshots")
            return (firstName: firstName, lastName: lastName, emailAddress: emailAddress)
        }()
        
        func createConcert() {
            let concert = MCSharedBill.add(to: managedObjectContext)!
            concert.tripName = NSLocalizedString("app_store_screenshots_eventname_1", value: "Concert", comment: "event name example for app store screenshots")
            let david = concert.add(demoPerson: david)
            concert.add(demoPerson: sheila)
            concert.add(demoPerson: lauren)
            concert.add(demoPerson: jake)
            
            let fullCosts = concert.addPayment()!
            fullCosts.payingPerson = david
            fullCosts.descriptionOfPayment = "Full Costs"
            fullCosts.money = NSNumber(value: 273.30)
            fullCosts.categoryId = CategoryPictureStoreController.PaymentCategory.miscellaneous.number
            fullCosts.recalculateAveragePeopleOweAndStore()
        }
        func createTheatre() {
            let theatre = MCSharedBill.add(to: managedObjectContext)!
            theatre.tripName = NSLocalizedString("app_store_screenshots_eventname_2", value: "Theatre", comment: "event name example for app store screenshots")
            theatre.add(demoPerson: david)
            theatre.add(demoPerson: jake)
            theatre.add(demoPerson: ann)
            theatre.add(demoPerson: sheila)
            let lauren = theatre.add(demoPerson: lauren)
            
            let fullCosts = theatre.addPayment()!
            fullCosts.payingPerson = lauren
            fullCosts.descriptionOfPayment = "Full Costs"
            fullCosts.money = NSNumber(value: 212.80)
            fullCosts.categoryId = CategoryPictureStoreController.PaymentCategory.miscellaneous.number
            fullCosts.recalculateAveragePeopleOweAndStore()
            
        }
        func createMonthlyFoodCosts() {
            let foodCosts = MCSharedBill.add(to: managedObjectContext)!
            foodCosts.tripName = NSLocalizedString("app_store_screenshots_eventname_3", value: "This month food costs", comment: "event name example for app store screenshots")
            let sheila = foodCosts.add(demoPerson: sheila)
            foodCosts.add(demoPerson: david)
            
            let fullCosts = foodCosts.addPayment()!
            fullCosts.payingPerson = sheila
            fullCosts.descriptionOfPayment = "Full Costs"
            fullCosts.money = NSNumber(value: 32.44)
            fullCosts.categoryId = CategoryPictureStoreController.PaymentCategory.miscellaneous.number
            fullCosts.recalculateAveragePeopleOweAndStore()
        }
        func createCampingTrip() {
            let campingTrip = MCSharedBill.add(to: managedObjectContext)!
            campingTrip.tripName = NSLocalizedString("app_store_screenshots_eventname_4", value: "Camping trip", comment: "event name example for app store screenshots")
            campingTrip.add(demoPerson: david)
            campingTrip.add(demoPerson: jake)
            let ann = campingTrip.add(demoPerson: ann)
            campingTrip.add(demoPerson: lauren)
            campingTrip.add(demoPerson: sheila)
            
            let fullCosts = campingTrip.addPayment()!
            fullCosts.payingPerson = ann
            fullCosts.descriptionOfPayment = "Full Costs"
            fullCosts.money = NSNumber(value: 736.48)
            fullCosts.categoryId = CategoryPictureStoreController.PaymentCategory.miscellaneous.number
            fullCosts.recalculateAveragePeopleOweAndStore()
        }
        func createDinner() {
            let dinner = MCSharedBill.add(to: managedObjectContext)!
            dinner.tripName = NSLocalizedString("app_store_screenshots_eventname_5", value: "Dinner", comment: "event name example for app store screenshots")
            dinner.add(demoPerson: sheila)
            let david = dinner.add(demoPerson: david)
            
            let sushi = dinner.addPayment()!
            sushi.payingPerson = david
            sushi.descriptionOfPayment = NSLocalizedString("app_store_screenshots_eventname_5_payment_1", value: "Sushi", comment: "payed item example for app store screenshots")
            sushi.money = NSNumber(value: 62.00)
            sushi.categoryId = CategoryPictureStoreController.PaymentCategory.dinner.number
            sushi.recalculateAveragePeopleOweAndStore()
        }
        func createMovie() {
            let movie = MCSharedBill.add(to: managedObjectContext)!
            movie.tripName = NSLocalizedString("app_store_screenshots_eventname_6", value: "Movie", comment: "event name example for app store screenshots")
            movie.add(demoPerson: sheila)
            let ann = movie.add(demoPerson: ann)
            let jake = movie.add(demoPerson: jake)
            movie.add(demoPerson: david)
            let lauren = movie.add(demoPerson: lauren)
            
            let tickets = movie.addPayment()!
            tickets.payingPerson = jake
            tickets.descriptionOfPayment = NSLocalizedString("app_store_screenshots_eventname_6_payment_1", value: "Tickets", comment: "payed item example for app store screenshots")
            tickets.money = NSNumber(value: 60.00)
            tickets.categoryId = CategoryPictureStoreController.PaymentCategory.tickets.number
            
            let popcorn = movie.addPayment()!
            popcorn.payingPerson = ann
            popcorn.descriptionOfPayment = NSLocalizedString("app_store_screenshots_eventname_6_payment_2", value: "Popcorn", comment: "payed item example for app store screenshots")
            popcorn.money = NSNumber(value: 15.00)
            popcorn.categoryId = CategoryPictureStoreController.PaymentCategory.dinner.number
            
            let softDrinks = movie.addPayment()!
            softDrinks.payingPerson = lauren
            softDrinks.descriptionOfPayment = NSLocalizedString("app_store_screenshots_eventname_6_payment_3", value: "Soft drinks", comment: "payed item example for app store screenshots")
            softDrinks.money = NSNumber(value: 24.78)
            softDrinks.categoryId = CategoryPictureStoreController.PaymentCategory.drinks.number
            
            movie.payments.forEach { (item) in
                let payment = item as! MCPayment
                payment.recalculateAveragePeopleOweAndStore()
            }
        }
        
        createConcert()
        createTheatre()
        createMonthlyFoodCosts()
        createCampingTrip()
        createDinner()
        createMovie()
    }
    
    // MARK: NSObject
    
}

extension MCSharedBill {
    @discardableResult func add(demoPerson: (firstName: String, lastName: String, emailAddress: String)) -> MCPerson {
        let newPerson = self.addPerson()!
        newPerson.firstName = demoPerson.firstName
        newPerson.lastName = demoPerson.lastName
        newPerson.addOneEmailAddress(fromAString: demoPerson.emailAddress)
        newPerson.setPictureDataFrom(UIImage(named: "No picture Image 3 - picture")!)
        newPerson.setThumbnailDataFrom(UIImage(named: "No picture Image 3 - thumbnail")!)
        return newPerson
    }
}

#endif

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
            let firstName = NSLocalizedString("David", comment: "example for app store screenshots")
            let lastName = NSLocalizedString("Tucker", comment: "example for appstore screenshots")
            let emailAddress = NSLocalizedString("davidtucker@somewhere.com", comment: "example for appstore screenshots")
            return (firstName: firstName, lastName: lastName, emailAddress: emailAddress)
        }()
        
        var jake: (firstName: String, lastName: String, emailAddress: String) = {
            let firstName = NSLocalizedString("Jake", comment: "example for app store screenshots")
            let lastName = NSLocalizedString("Nichelson", comment: "example for appstore screenshots")
            let emailAddress = NSLocalizedString("jake@earth.com", comment: "example for appstore screenshots")
            return (firstName: firstName, lastName: lastName, emailAddress: emailAddress)
        }()

        var ann: (firstName: String, lastName: String, emailAddress: String) = {
            let firstName = NSLocalizedString("Ann", comment: "example for app store screenshots")
            let lastName = NSLocalizedString("Burwell", comment: "example for appstore screenshots")
            let emailAddress = NSLocalizedString("ann_burwell@work.com", comment: "example for appstore screenshots")
            return (firstName: firstName, lastName: lastName, emailAddress: emailAddress)
        }()

        var lauren: (firstName: String, lastName: String, emailAddress: String) = {
            let firstName = NSLocalizedString("Lauren", comment: "example for app store screenshots")
            let lastName = NSLocalizedString("Mortimer", comment: "example for appstore screenshots")
            let emailAddress = NSLocalizedString("l.d.mortimer@internet.com", comment: "example for appstore screenshots")
            return (firstName: firstName, lastName: lastName, emailAddress: emailAddress)
        }()

        var sheila: (firstName: String, lastName: String, emailAddress: String) = {
            let firstName = NSLocalizedString("Sheila", comment: "example for app store screenshots")
            let lastName = NSLocalizedString("Miller", comment: "example for appstore screenshots")
            let emailAddress = NSLocalizedString("mailsheila@home.com", comment: "example for appstore screenshots")
            return (firstName: firstName, lastName: lastName, emailAddress: emailAddress)
        }()
        
        func createConcert() {
            let concert = MCSharedBill.add(to: managedObjectContext)!
            concert.tripName = NSLocalizedString("Concert", comment: "example for app store screenshots")
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
            theatre.tripName = NSLocalizedString("Theatre", comment: "example for app store screenshots")
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
            foodCosts.tripName = NSLocalizedString("This month food costs", comment: "example for app store screenshots")
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
            campingTrip.tripName = NSLocalizedString("Camping trip", comment: "example for app store screenshots")
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
            dinner.tripName = NSLocalizedString("Dinner", comment: "example for app store screenshots")
            dinner.add(demoPerson: sheila)
            let david = dinner.add(demoPerson: david)
            
            let sushi = dinner.addPayment()!
            sushi.payingPerson = david
            sushi.descriptionOfPayment = NSLocalizedString("Sushi", comment: "example for app store screenshots")
            sushi.money = NSNumber(value: 62.00)
            sushi.categoryId = CategoryPictureStoreController.PaymentCategory.dinner.number
            sushi.recalculateAveragePeopleOweAndStore()
        }
        func createMovie() {
            let movie = MCSharedBill.add(to: managedObjectContext)!
            movie.tripName = NSLocalizedString("Movie", comment: "example for app store screenshots")
            movie.add(demoPerson: sheila)
            let ann = movie.add(demoPerson: ann)
            let jake = movie.add(demoPerson: jake)
            movie.add(demoPerson: david)
            let lauren = movie.add(demoPerson: lauren)
            
            let tickets = movie.addPayment()!
            tickets.payingPerson = jake
            tickets.descriptionOfPayment = NSLocalizedString("Tickets", comment: "example for app store screenshots")
            tickets.money = NSNumber(value: 60.00)
            tickets.categoryId = CategoryPictureStoreController.PaymentCategory.tickets.number
            
            let popcorn = movie.addPayment()!
            popcorn.payingPerson = ann
            popcorn.descriptionOfPayment = NSLocalizedString("Popcorn", comment: "example for app store screenshots")
            popcorn.money = NSNumber(value: 15.00)
            popcorn.categoryId = CategoryPictureStoreController.PaymentCategory.dinner.number
            
            let softDrinks = movie.addPayment()!
            softDrinks.payingPerson = lauren
            softDrinks.descriptionOfPayment = NSLocalizedString("Soft drinks", comment: "example for app store screenshots")
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

//
//  EventSpawningPool.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 20/08/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

@testable import We_all_pay;

import Foundation
import CoreData

final class EventSpawningPool: NSObject {
    let eventsModel: EventsModel
    
    init(eventsModel: EventsModel) {
        self.eventsModel = eventsModel
        super.init()
    }
    
    func createEventWithTitle(_ title: String) -> MCSharedBill {
        let event = eventsModel.addEvent()
        event.tripName = title
        return event
    }
    
    // MARK: NSObject
}

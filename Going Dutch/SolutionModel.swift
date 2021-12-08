//
//  SolutionModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 03/12/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCSolutionModel) final class SolutionModel: NSObject {
    @objc(MCSolutionViewSectionTitle) enum SectionTitle: UInt {
        case whoOwesWho = 0
        case totalOwes = 1
        case totalPaid = 2
    }
    
    @objc private(set) var event: MCSharedBill!
    @objc dynamic private(set) var peoplePresentLocalizedSorted: [MCPerson]!
    
    @objc(sectionTitleForSection:) func sectionTitle(for section: SectionTitle) -> String {
        switch section {
        case .whoOwesWho:
            return NSLocalizedString("solution_view_section_title_who_owes_who", value: "Who owes whom", comment: "Section title in the solution screen that shows the title of the section that shows who owes who what how much money")
        case .totalOwes:
            return NSLocalizedString("solution_view_section_title_total_owes", value: "Total owes", comment: "Section title in the solution screen that shows the title of the section that shows who owes how much to the group")
        case .totalPaid:
            return NSLocalizedString("solution_view_section_title_total_paid", value: "Total paid", comment: "Section title in the solution screen that shows the title of the section that shows who paid how much on the entire event")
        }
    }
    
    @objc(prepareForUseWith:) func prepareForUse(with event: MCSharedBill) {
        self.event = event
        if let peoplePresentSet = self.event.peoplePresent {
            let unsortedPeoplePresent: [MCPerson] = [MCPerson](peoplePresentSet)
            peoplePresentLocalizedSorted = (UILocalizedIndexedCollation.current().sortedArray(from: unsortedPeoplePresent, collationStringSelector: #selector(MCPerson.getFullName)) as! [MCPerson])
        } else {
            peoplePresentLocalizedSorted = [MCPerson]()
        }
    }
}

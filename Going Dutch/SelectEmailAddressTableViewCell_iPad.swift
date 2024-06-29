//
//  SelectEmailAddressTableViewCell_iPad.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import UIKit
import Combine

final class SelectEmailAddressTableViewCell_iPad: UITableViewCell {
    private var emailAddress: MCEmailAddress?
    
    private var bag = Set<AnyCancellable>()
    
    @IBOutlet private var emailAddressLabel: UILabel!
    @IBOutlet private weak var checkMarkImageView: UIImageView!
    
    func update(with emailAddress: MCEmailAddress) {
        if self.emailAddress != nil {
            bag.removeAll(keepingCapacity: true)
        }
        self.emailAddress = emailAddress
        self.emailAddress?.publisher(for: \.emailAddress, options: [.initial, .new])
            .assign(to: \.text, on: emailAddressLabel)
            .store(in: &bag)
        self.emailAddress!.publisher(for: \.selected, options: [.initial, .new])
            .compactMap(\.?.boolValue)
            .map({ !$0 })
            .assign(to: \.isHidden, on: checkMarkImageView)
            .store(in: &bag)
    }
    
    override func prepareForReuse() {
        bag.removeAll(keepingCapacity: true)
        emailAddress = nil
    }
}

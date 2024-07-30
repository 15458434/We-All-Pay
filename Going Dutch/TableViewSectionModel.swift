//
//  TableViewSectionModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 10/12/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc class TableViewSectionItemsModel: NSObject, Comparable {
    @objc(MCTableViewSectionItemsModelKind) enum Kind: Int, Comparable {
        case none = -1
        case solution = 0
        case ad = 1
        case totalUsed = 2
        case totalSpent = 3
        
        // MARK: Comparable
        
        static func < (lhs: TableViewSectionItemsModel.Kind, rhs: TableViewSectionItemsModel.Kind) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        
        // MARK: Equatable
        
        static func == (lhs: TableViewSectionItemsModel.Kind, rhs: TableViewSectionItemsModel.Kind) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
    @objc dynamic var sortIndex: Kind = .none
    @objc dynamic var title: String?
    @objc dynamic fileprivate(set) var items: [AnyObject]?
    
    @objc convenience init(title: String?, items: [AnyObject]?, sortIndex: Kind) {
        self.init()
        self.title = title
        self.items = items
        self.sortIndex = sortIndex
    }
    
    // MARK: Comparable
    
    static func < (lhs: TableViewSectionItemsModel, rhs: TableViewSectionItemsModel) -> Bool {
        return lhs.sortIndex < rhs.sortIndex
    }
    
    // MARK: Equatable
    
    static func == (lhs: TableViewSectionItemsModel, rhs: TableViewSectionItemsModel) -> Bool {
        return lhs.sortIndex == rhs.sortIndex
    }
}

final class SolutionSectionItemsModel: TableViewSectionItemsModel {
    
    // MARK: TableViewSectionItemsModel
    
    @objc convenience init(title: String?, items: [SolutionReturnPaymentItem]?) {
        self.init()
        self.sortIndex = .solution
        self.title = title
        self.items = items
    }
}

@objc(MCAdSectionItemsModel) final class AdSectionItemsModel: TableViewSectionItemsModel {
    @objc(MCAdSectionItemsModelStatus) enum Status: Int {
        case isNotShowing
        case isShowing
    }
    
    @objc dynamic var adStatus: Status = .isNotShowing
    
    // MARK: TableViewSectionItemsModel
    
    // MARK: NSObject
    
    override init() {
        super.init()
        self.sortIndex = .ad
        self.items = [NSNull()]
    }
}

final class TotalUsedSectionItemsModel: TableViewSectionItemsModel {
    
    // MARK: TableViewSectionItemsModel
    
    @objc convenience init(title: String?, items: [MCPerson]?) {
        self.init()
        self.sortIndex = .totalUsed
        self.title = title
        self.items = items
    }
}

final class TotalSpentSectionItemsModel: TableViewSectionItemsModel {
    
    // MARK: TableViewSectionItemsModel
    
    @objc convenience init(title: String?, items: [MCPerson]?) {
        self.init()
        self.sortIndex = .totalSpent
        self.title = title
        self.items = items
    }
}

@objc class TableViewSectionModel: NSObject {
    @objc dynamic var sections: [TableViewSectionItemsModel] = [TableViewSectionItemsModel]()
    
    @objc convenience init(sections: [TableViewSectionItemsModel]) {
        self.init()
        self.sections = sections
    }
    
    @objc func addSection(_ newSection: TableViewSectionItemsModel) {
        if let index = sections.firstIndex(where: { section in
            return section > newSection
        }) {
            let mutableArray = mutableArrayValue(forKey: "sections")
            mutableArray.insert(newSection, at: index)
        } else {
            let mutableArray = mutableArrayValue(forKey: "sections")
            mutableArray.add(newSection)
        }
    }
    
    @objc(containsSection:) func contains(_ section: TableViewSectionItemsModel) -> Bool {
        return sections.contains { $0 == section }
    }
    
    @objc(indexOfSection:) func index(of section: TableViewSectionItemsModel) -> Int {
        return sections.firstIndex(of: section) ?? NSNotFound
    }
    
    @objc func removeSection(_ poorSucker: TableViewSectionItemsModel) {
        if let index = sections.firstIndex(of: poorSucker) {
            let mutableArray = mutableArrayValue(forKey: "sections")
            mutableArray.removeObject(at: index)
        }
    }
}

@objc class ShadowTableViewSectionModel: TableViewSectionModel {
    private var shadowSections: [TableViewSectionItemsModel] = [TableViewSectionItemsModel]()
    
    @objc var isShowing: Bool = false {
        willSet {
            if !isShowing {
                if newValue {
                    shadowSections.forEach { shadowSection in
                        super.addSection(shadowSection)
                    }
                }
            } else {
                if !newValue {
                    shadowSections.forEach { shadowSection in
                        super.removeSection(shadowSection)
                    }
                }
            }
        }
    }
    
    // MARK: TableViewSectionModel
    
    override func addSection(_ newSection: TableViewSectionItemsModel) {
        if let index = sections.firstIndex(where: { section in
            return section > newSection
        }) {
            shadowSections.insert(newSection, at: index)
        } else {
            shadowSections.append(newSection)
        }
        if isShowing {
            super.addSection(newSection)
        }
    }
    
    override func contains(_ section: TableViewSectionItemsModel) -> Bool {
        if isShowing {
            return super.contains(section)
        } else {
            return shadowSections.contains { $0 == section }
        }
    }
    
    override func index(of section: TableViewSectionItemsModel) -> Int {
        if isShowing {
            return super.index(of: section)
        } else {
            return shadowSections.firstIndex(of: section) ?? NSNotFound
        }
    }
    
    override func removeSection(_ poorSucker: TableViewSectionItemsModel) {
        if let index = sections.firstIndex(of: poorSucker) {
            shadowSections.remove(at: index)
        }
        if isShowing {
            super.removeSection(poorSucker)
        }
    }
    
    // MARK: NSObject
}

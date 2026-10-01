//
//  Organization.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import Foundation
import SwiftData

@Model
final class Organization {
    @Attribute(.unique) var id: UUID
    var name: String
    var categoryRawValue: String
    
    var category: ExpenseCategory {
        get { ExpenseCategory(rawValue: categoryRawValue) ?? .groceries }
        set { categoryRawValue = newValue.rawValue }
    }
    
    init(id: UUID = UUID(), name: String, category: ExpenseCategory) {
        self.id = id
        self.name = name
        self.categoryRawValue = category.rawValue
    }
}

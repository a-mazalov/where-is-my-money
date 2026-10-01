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
    var condition: String
    var categoryRawValue: String
    
    // Обратная связь с сообщениями
    @Relationship(deleteRule: .nullify, inverse: \SMSMessage.organization)
    var messages: [SMSMessage]?
    
    var category: ExpenseCategory {
        get { ExpenseCategory(rawValue: categoryRawValue) ?? .unknown }
        set { categoryRawValue = newValue.rawValue }
    }
    
    init(id: UUID = UUID(), name: String, condition: String, category: ExpenseCategory) {
        self.id = id
        self.name = name
        self.condition = condition
        self.categoryRawValue = category.rawValue
    }
}

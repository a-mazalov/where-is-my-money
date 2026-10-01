//
//  SMSMessage.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import Foundation
import SwiftData

/// Модель для хранения SMS сообщения
@Model
final class SMSMessage {
    @Attribute(.unique) var id: UUID
    var text: String
    var sender: String
    var receivedAt: Date
    
    // Распарсенные данные
    var amount: Double?
    var organizationCondition: String?
    
    // Связь с организацией
    var organization: Organization?
    
    init(id: UUID = UUID(), text: String, sender: String, receivedAt: Date) {
        self.id = id
        self.text = text
        self.sender = sender
        self.receivedAt = receivedAt
    }
}

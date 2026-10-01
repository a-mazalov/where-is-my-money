//
//  SMSProcessingService.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import Foundation
import SwiftData

final class SMSProcessingService {
    
    /// Обрабатывает SMS: парсит данные, находит или создаёт организацию
    static func processSMS(
        text: String,
        sender: String,
        receivedAt: Date,
        context: ModelContext
    ) -> SMSMessage {
        // Создаём сообщение
        let message = SMSMessage(text: text, sender: sender, receivedAt: receivedAt)
        
        // Парсим данные
        message.amount = SMSParserService.extractAmount(from: text)
        message.organizationCondition = SMSParserService.extractOrganization(from: text)
        
        // Ищем или создаём организацию
        if let condition = message.organizationCondition {
            message.organization = findOrCreateOrganization(
                condition: condition,
                context: context
            )
        }
        
        context.insert(message)
        
        return message
    }
    
    /// Находит организацию по условию или создаёт новую с категорией "Неизвестно"
    private static func findOrCreateOrganization(
        condition: String,
        context: ModelContext
    ) -> Organization {
        // Ищем существующую организацию
        let descriptor = FetchDescriptor<Organization>()
        let allOrganizations = (try? context.fetch(descriptor)) ?? []
        
        // Ищем по вхождению условия
        if let matched = allOrganizations.first(where: { condition.contains($0.condition) }) {
            return matched
        }
        
        // Создаём новую организацию с категорией "Неизвестно"
        let newOrganization = Organization(
            name: condition,
            condition: condition,
            category: .unknown
        )
        context.insert(newOrganization)
        
        return newOrganization
    }
}

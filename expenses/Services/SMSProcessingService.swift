//
//  SMSProcessingService.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import Foundation
import SwiftData

final class SMSProcessingService {

    /// Парсер на конфигах `BankProfiles.json`.
    private static let bankProfileParser: BankProfileParserService? = try? BankProfileParserService(bundle: .main)

    /// Проверяет, удастся ли распознать сумму в SMS по правилам банка.
    static func canExtractAmount(from text: String, sender: String) -> Bool {
        bankProfileParser?.parse(text: text, sender: sender)?.amount != nil
    }

    /// Обрабатывает SMS: парсит данные, находит или создаёт организацию
    static func processSMS(
        text: String,
        sender: String,
        receivedAt: Date,
        context: ModelContext
    ) -> SMSMessage {
        // Создаём сообщение
        let message = SMSMessage(text: text, sender: sender, receivedAt: receivedAt)

        // Парсим по правилам банка (BankProfiles.json).
        let parsed = bankProfileParser?.parse(text: text, sender: sender)

        message.amount = parsed?.amount
        message.organizationCondition = parsed?.organization

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
    
    /// Находит организацию по условию или создаёт новую.
    /// Если пользовательская организация не найдена, категория подбирается
    /// из системного справочника организаций (SystemOrganization).
    private static func findOrCreateOrganization(
        condition: String,
        context: ModelContext
    ) -> Organization {
        // Ищем существующую организацию
        let descriptor = FetchDescriptor<Organization>()
        let allOrganizations = (try? context.fetch(descriptor)) ?? []
        
        // Ищем по точному совпадению условия
        if let matched = allOrganizations.first(where: { $0.condition == condition }) {
            return matched
        }
        
        // Не найдена среди пользовательских — пробуем взять категорию из системного справочника
        let category = systemCategory(for: condition, context: context) ?? .unknown
        
        // Создаём новую пользовательскую организацию с подобранной категорией
        let newOrganization = Organization(
            name: condition,
            condition: condition,
            category: category
        )
        context.insert(newOrganization)
        
        return newOrganization
    }
    
    /// Ищет категорию для организации в системном справочнике по точному совпадению названия
    private static func systemCategory(
        for condition: String,
        context: ModelContext
    ) -> ExpenseCategory? {
        let descriptor = FetchDescriptor<SystemOrganization>(
            predicate: #Predicate { $0.organizationName == condition }
        )
        guard let systemOrganization = (try? context.fetch(descriptor))?.first else {
            return nil
        }
        
        return ExpenseCategory(rawValue: systemOrganization.primaryCategory)
    }
}

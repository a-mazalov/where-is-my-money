//
//  BankProfile.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import Foundation

/// Правило извлечения одного значения: регулярное выражение + номер группы + трансформация.
struct FieldRule: Decodable {
    let pattern: String
    let options: [String]?
    let group: Int?
    let transform: String?
    let required: Bool?
}

/// Один формат SMS внутри банка (покупка, перевод, зачисление и т.д.).
struct MessageTemplate: Decodable {
    let templateId: String
    let detect: FieldRule
    let fields: [String: FieldRule]
}

/// Правила разбора SMS для одного банка, загружаемые из `BankProfiles.json`.
struct BankProfile: Decodable {
    let schemaVersion: Int
    let bankId: String
    let displayName: String
    let configVersion: String
    let senderMatchers: [String]
    let templates: [MessageTemplate]
}

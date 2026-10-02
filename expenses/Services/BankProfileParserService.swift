//
//  BankProfileParserService.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import Foundation

enum BankProfileParserError: LocalizedError {
    case resourceNotFound
    case unreadableResource

    var errorDescription: String? {
        switch self {
        case .resourceNotFound:
            return "Файл BankProfiles.json не найден в бандле"
        case .unreadableResource:
            return "Не удалось прочитать BankProfiles.json"
        }
    }
}

/// Результат разбора SMS по конфигу `BankProfile`: банк, сработавший шаблон и извлечённые поля.
struct SMSParseResult: Equatable {
    let bankId: String
    let templateId: String
    let values: [String: String]

    var amount: Double? { values["amount"].flatMap(Double.init) }
    var organization: String? { values["organization"] }
}

/// Разбирает текст SMS по конфигурируемым правилам банков (`BankProfile`),
/// вместо захардкоженных регулярок под конкретный банк.
final class BankProfileParserService {

    private let profiles: [BankProfile]

    init(profiles: [BankProfile]) {
        self.profiles = profiles
    }

    convenience init(bundle: Bundle = .main) throws {
        guard let url = bundle.url(forResource: "BankProfiles", withExtension: "json") else {
            throw BankProfileParserError.resourceNotFound
        }
        guard let data = try? Data(contentsOf: url) else {
            throw BankProfileParserError.unreadableResource
        }
        let profiles = try JSONDecoder().decode([BankProfile].self, from: data)
        self.init(profiles: profiles)
    }

    /// Находит банк по отправителю, подбирает подходящий шаблон и извлекает поля.
    /// Возвращает `nil`, если банк/шаблон не распознан или не хватило обязательного поля.
    func parse(text: String, sender: String) -> SMSParseResult? {
        guard let profile = matchingProfile(for: sender) else { return nil }
        guard let template = matchingTemplate(in: profile, text: text) else { return nil }
        return extractValues(template: template, bankId: profile.bankId, text: text)
    }

    private func matchingProfile(for sender: String) -> BankProfile? {
        profiles.first { profile in
            profile.senderMatchers.contains { $0.caseInsensitiveCompare(sender) == .orderedSame }
        }
    }

    private func matchingTemplate(in profile: BankProfile, text: String) -> MessageTemplate? {
        profile.templates.first { firstMatch(of: $0.detect, in: text) != nil }
    }

    private func extractValues(template: MessageTemplate, bankId: String, text: String) -> SMSParseResult? {
        var values: [String: String] = [:]

        for (name, rule) in template.fields {
            guard let raw = firstMatch(of: rule, in: text) else {
                if rule.required == true {
                    return nil
                }
                continue
            }
            values[name] = Self.applyTransform(raw, name: rule.transform)
        }

        return SMSParseResult(bankId: bankId, templateId: template.templateId, values: values)
    }

    private func firstMatch(of rule: FieldRule, in text: String) -> String? {
        var options: NSRegularExpression.Options = []
        if rule.options?.contains("caseInsensitive") == true {
            options.insert(.caseInsensitive)
        }

        guard let regex = try? NSRegularExpression(pattern: rule.pattern, options: options) else {
            return nil
        }

        let fullRange = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: fullRange) else {
            return nil
        }

        let groupIndex = rule.group ?? 0
        guard groupIndex < match.numberOfRanges,
              let groupRange = Range(match.range(at: groupIndex), in: text) else {
            return nil
        }

        return String(text[groupRange])
    }

    private static func applyTransform(_ raw: String, name: String?) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        switch name {
        case "decimal":
            return trimmed.replacingOccurrences(of: ",", with: ".")
        default:
            return trimmed
        }
    }
}

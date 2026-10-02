//
//  SystemOrganizationSeedService.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import Foundation
import SwiftData

enum SystemOrganizationSeedError: LocalizedError {
    case resourceNotFound
    case unreadableResource

    var errorDescription: String? {
        switch self {
        case .resourceNotFound:
            return "Файл SystemOrganizations.json не найден в бандле"
        case .unreadableResource:
            return "Не удалось прочитать SystemOrganizations.json"
        }
    }
}

/// Читает предобработанные организации из `SystemOrganizations.json`
/// и записывает их в SwiftData при первом запуске приложения.
@MainActor
final class SystemOrganizationSeedService {

    private struct SystemOrganizationDTO: Decodable {
        let organizationName: String
        let primaryCategory: String
        let secondaryCategory: String
        let tertiaryCategory: String
    }

    /// Загружает организации из JSON, только если таблица пуста (свежая установка).
    @discardableResult
    static func seedIfNeeded(context: ModelContext) throws -> Int {
        let existingCount = try context.fetchCount(FetchDescriptor<SystemOrganization>())
        guard existingCount == 0 else {
            return 0
        }

        let organizations = try loadOrganizations()
        for organization in organizations {
            context.insert(organization)
        }
        try context.save()

        return organizations.count
    }

    private static func loadOrganizations() throws -> [SystemOrganization] {
        guard let url = Bundle.main.url(forResource: "SystemOrganizations", withExtension: "json") else {
            throw SystemOrganizationSeedError.resourceNotFound
        }

        guard let data = try? Data(contentsOf: url) else {
            throw SystemOrganizationSeedError.unreadableResource
        }

        let dtos = try JSONDecoder().decode([SystemOrganizationDTO].self, from: data)

        return dtos.map {
            SystemOrganization(
                organizationName: $0.organizationName,
                primaryCategory: $0.primaryCategory,
                secondaryCategory: $0.secondaryCategory,
                tertiaryCategory: $0.tertiaryCategory
            )
        }
    }
}

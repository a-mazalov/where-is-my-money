//
//  SystemOrganization.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import Foundation
import SwiftData

/// Предобработанные организации, поставляемые вместе с приложением
/// (загружаются из `SystemOrganizations.json` при первом запуске).
@Model
final class SystemOrganization {
    @Attribute(.unique) var organizationName: String
    var primaryCategory: String
    var secondaryCategory: String
    var tertiaryCategory: String

    init(organizationName: String, primaryCategory: String, secondaryCategory: String, tertiaryCategory: String) {
        self.organizationName = organizationName
        self.primaryCategory = primaryCategory
        self.secondaryCategory = secondaryCategory
        self.tertiaryCategory = tertiaryCategory
    }
}

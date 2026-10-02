//
//  SystemOrganizationsView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI
import SwiftData

/// Список предобработанных системных организаций (только для просмотра).
struct SystemOrganizationsView: View {
    @Query(sort: \SystemOrganization.organizationName) private var systemOrganizations: [SystemOrganization]

    @State private var searchText = ""

    private var filteredOrganizations: [SystemOrganization] {
        guard !searchText.isEmpty else { return systemOrganizations }
        return systemOrganizations.filter {
            $0.organizationName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List(filteredOrganizations) { organization in
            VStack(alignment: .leading, spacing: 6) {
                Text(organization.organizationName)
                    .font(.body)

                HStack(spacing: 8) {
                    categoryTag(organization.primaryCategory)
                    categoryTag(organization.secondaryCategory)
                    categoryTag(organization.tertiaryCategory)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Поиск по названию")
        .overlay {
            if systemOrganizations.isEmpty {
                ContentUnavailableView(
                    "Нет системных организаций",
                    systemImage: "building.2.crop.circle",
                    description: Text("Список загружается автоматически при первом запуске")
                )
            }
        }
    }

    @ViewBuilder
    private func categoryTag(_ rawValue: String) -> some View {
        let category = ExpenseCategory(rawValue: rawValue) ?? .unknown
        Label(category.rawValue, systemImage: category.icon)
            .font(.caption2)
            .foregroundStyle(category.color)
    }
}

#Preview {
    NavigationStack {
        SystemOrganizationsView()
    }
    .modelContainer(for: SystemOrganization.self, inMemory: true)
}

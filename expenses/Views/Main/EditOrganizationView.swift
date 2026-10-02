//
//  EditOrganizationView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI
import SwiftData

struct EditOrganizationView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var organization: Organization
    @Query private var systemOrganizations: [SystemOrganization]

    private var matchedSystemOrganization: SystemOrganization? {
        systemOrganizations.first {
            $0.organizationName.localizedCaseInsensitiveCompare(organization.condition) == .orderedSame
        }
    }

    private var suggestedCategories: [ExpenseCategory] {
        guard let match = matchedSystemOrganization else { return [] }
        let values = [match.primaryCategory, match.secondaryCategory, match.tertiaryCategory]
        var seen = Set<ExpenseCategory>()
        return values.compactMap { ExpenseCategory(rawValue: $0) }.filter { seen.insert($0).inserted }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Название") {
                    TextField("Евроопт", text: $organization.name)
                }

                Section("Условие") {
                    TextField("OAO DjonCorp", text: $organization.condition)
                }

                Section("Категория") {
                    Picker("Категория", selection: $organization.category) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Предложения") {
                    if suggestedCategories.isEmpty {
                        Text("Нет предложений")
                            .foregroundStyle(.secondary)
                    } else {
                        suggestionTags
                    }
                }
            }
            .navigationTitle("Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var suggestionTags: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestedCategories) { category in
                    suggestionTag(category)
                }
            }
        }
    }

    private func suggestionTag(_ category: ExpenseCategory) -> some View {
        let isSelected = organization.category == category
        return Button {
            organization.category = category
        } label: {
            Label(category.rawValue, systemImage: category.icon)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .foregroundStyle(isSelected ? Color.white : category.color)
                .background(isSelected ? category.color : category.color.opacity(0.15))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let organization = Organization(name: "Евроопт", condition: "BLR Magazine Evroopt", category: .groceries)
    return EditOrganizationView(organization: organization)
        .modelContainer(for: Organization.self, inMemory: true)
}

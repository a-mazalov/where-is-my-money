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
}

#Preview {
    let organization = Organization(name: "Евроопт", condition: "BLR Magazine Evroopt", category: .groceries)
    return EditOrganizationView(organization: organization)
        .modelContainer(for: Organization.self, inMemory: true)
}

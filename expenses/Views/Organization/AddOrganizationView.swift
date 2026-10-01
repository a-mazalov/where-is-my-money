//
//  AddOrganizationView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI
import SwiftData

struct AddOrganizationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var condition = ""
    @State private var selectedCategory: ExpenseCategory = .groceries
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Название") {
                    TextField("ПЯТЕРОЧКА", text: $name)
                }
                
                Section("Условие") {
                    TextField("OAO DjonCorp", text: $condition)
                }
                
                Section("Категория") {
                    Picker("Категория", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Новая организация")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить") {
                        addOrganization()
                    }
                    .disabled(name.isEmpty || condition.isEmpty)
                }
            }
        }
    }
    
    private func addOrganization() {
        let organization = Organization(name: name, condition: condition, category: selectedCategory)
        modelContext.insert(organization)
        dismiss()
    }
}

#Preview {
    AddOrganizationView()
        .modelContainer(for: Organization.self, inMemory: true)
}

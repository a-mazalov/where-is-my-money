//
//  OrganizationsView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI
import SwiftData

struct OrganizationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Organization.name) private var organizations: [Organization]
    
    @State private var showingAddOrganization = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(organizations) { organization in
                    HStack {
                        Label(organization.name, systemImage: organization.category.icon)
                            .foregroundStyle(organization.category.color)
                        
                        Spacer()
                        
                        Text(organization.category.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(organizations[index])
                    }
                }
            }
            .navigationTitle("Организации")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddOrganization = true
                    } label: {
                        Label("Добавить", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddOrganization) {
                AddOrganizationView()
            }
            .overlay {
                if organizations.isEmpty {
                    ContentUnavailableView(
                        "Нет организаций",
                        systemImage: "building.2",
                        description: Text("Добавьте организации для категоризации")
                    )
                }
            }
        }
    }
}

#Preview {
    OrganizationsView()
        .modelContainer(for: Organization.self, inMemory: true)
}

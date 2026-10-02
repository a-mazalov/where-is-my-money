//
//  OrganizationsView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI
import SwiftData

struct OrganizationsView: View {
    private enum Section: String, CaseIterable, Identifiable {
        case user = "Мои"
        case system = "Системные"

        var id: String { rawValue }
    }

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Organization.name) private var organizations: [Organization]

    @State private var selectedSection: Section = .user
    @State private var showingAddOrganization = false
    @State private var editingOrganization: Organization?

    var body: some View {
        NavigationStack {
            Group {
                switch selectedSection {
                case .user:
                    userOrganizationsList
                case .system:
                    SystemOrganizationsView()
                }
            }
            .safeAreaBar(edge: .top) {
                Picker("Раздел", selection: $selectedSection) {
                    ForEach(Section.allCases) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .navigationTitle("Организации")
            .toolbar {
                if selectedSection == .user {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingAddOrganization = true
                        } label: {
                            Label("Добавить", systemImage: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddOrganization) {
                AddOrganizationView()
            }
            .sheet(item: $editingOrganization) { organization in
                EditOrganizationView(organization: organization)
            }
        }
    }

    private var userOrganizationsList: some View {
        List {
            ForEach(organizations) { organization in
                Button {
                    editingOrganization = organization
                } label: {
                    HStack {
                        Label(organization.name, systemImage: organization.category.icon)
                            .foregroundStyle(organization.category.color)

                        Spacer()

                        Text(organization.category.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(organizations[index])
                }
            }
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

#Preview {
    OrganizationsView()
        .modelContainer(for: [Organization.self, SystemOrganization.self], inMemory: true)
}

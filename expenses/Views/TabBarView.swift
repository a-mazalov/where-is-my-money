//
//  TabBarView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI
import SwiftData

struct TabBarView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            SMSMonthlyView()
                .tabItem {
                    Label("Сводка", systemImage: "calendar")
                }
            
            MainView()
                .tabItem {
                    Label("События", systemImage: "message.fill")
                }
            
            OrganizationsView()
                .tabItem {
                    Label("Организации", systemImage: "building.2")
                }

            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape")
                }
        }
        .task {
            _ = try? SystemOrganizationSeedService.seedIfNeeded(context: modelContext)
        }
    }
}

#Preview {
    TabBarView()
        .modelContainer(for: [SMSMessage.self, Organization.self, SystemOrganization.self], inMemory: true)
}

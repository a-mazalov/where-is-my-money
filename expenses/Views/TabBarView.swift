//
//  TabBarView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI
import SwiftData

struct TabBarView: View {
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
    }
}

#Preview {
    TabBarView()
        .modelContainer(for: [SMSMessage.self, Organization.self], inMemory: true)
}

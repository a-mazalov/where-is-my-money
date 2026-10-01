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
            MainView()
                .tabItem {
                    Label("События", systemImage: "message.fill")
                }
            
            OrganizationsView()
                .tabItem {
                    Label("Организации", systemImage: "building.2")
                }
        }
    }
}

#Preview {
    TabBarView()
        .modelContainer(for: [SMSMessage.self, Organization.self], inMemory: true)
}

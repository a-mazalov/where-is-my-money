//
//  expensesApp.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI
import SwiftData

@main
struct expensesApp: App {
    var body: some Scene {
        WindowGroup {
            TabBarView()
//                .environment(\.locale, Locale(identifier: "ru_RU"))
        }
        .modelContainer(for: [SMSMessage.self, Organization.self, SystemOrganization.self])
    }
}

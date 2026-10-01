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
            MainView()
        }
        .modelContainer(for: SMSMessage.self)
    }
}

//
//  ProcessSMSIntent.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import AppIntents
import Foundation
import SwiftData

/// App Intent для обработки входящих SMS сообщений
struct ProcessSMSIntent: AppIntent {
    static var title: LocalizedStringResource = "Обработать SMS"
    static var description = IntentDescription("Принимает текст SMS и сохраняет его в приложение")
    
    // Параметр - текст SMS сообщения
    @Parameter(title: "Текст SMS")
    var smsText: String
    
    @Parameter(title: "Отправитель", default: "Неизвестно")
    var sender: String
    
    // Основная функция выполнения Intent
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Создаем ModelContainer и context для Swift Data
        let container = try ModelContainer(for: SMSMessage.self, Organization.self)
        let context = ModelContext(container)
        
        // Обрабатываем SMS: парсим и привязываем организацию
        _ = await SMSProcessingService.processSMS(
            text: smsText,
            sender: sender,
            receivedAt: Date(),
            context: context
        )
        
        // Сохраняем
        try? context.save()
        
        return .result(
            dialog: "✅ SMS обработано"
        )
    }
}

/// Регистрация App Shortcuts для быстрого доступа
struct ExpensesAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ProcessSMSIntent(),
            phrases: [
                "Добавить SMS в \(.applicationName)",
                "Обработать сообщение в \(.applicationName)"
            ],
            shortTitle: "Обработать SMS",
            systemImageName: "message.fill"
        )
    }
}

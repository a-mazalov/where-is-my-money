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
        // Создаем ModelContainer для Swift Data
        let container = try ModelContainer(for: SMSMessage.self)
        let context = ModelContext(container)
        
        // Создаем новое сообщение
        let message = SMSMessage(
            text: smsText,
            sender: sender,
            receivedAt: Date()
        )
        
        // Сохраняем в Swift Data
        context.insert(message)
        try context.save()
        
        // Возвращаем результат с диалогом для пользователя
        return .result(
            dialog: "✅ SMS сохранено: \(smsText.prefix(50))..."
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

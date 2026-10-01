//
//  SMSStorage.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import Foundation
import SwiftData

/// Хранилище для работы с SMS сообщениями через Swift Data
@Observable
final class SMSStorage {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }
    
    /// Добавить новое сообщение
    func addMessage(_ message: SMSMessage) {
        modelContext.insert(message)
        save()
    }
    
    /// Удалить сообщение
    func deleteMessage(_ message: SMSMessage) {
        modelContext.delete(message)
        save()
    }
    
    /// Получить все сообщения, отсортированные по дате (новые сверху)
    func fetchMessages() -> [SMSMessage] {
        let descriptor = FetchDescriptor<SMSMessage>(
            sortBy: [SortDescriptor(\.receivedAt, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Ошибка загрузки сообщений: \(error)")
            return []
        }
    }
    
    /// Очистить все сообщения
    func clearAll() {
        let messages = fetchMessages()
        messages.forEach { modelContext.delete($0) }
        save()
    }
    
    // MARK: - Private
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
}

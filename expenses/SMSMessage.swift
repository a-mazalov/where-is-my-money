//
//  SMSMessage.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import Foundation

/// Модель для хранения SMS сообщения
struct SMSMessage: Identifiable, Codable {
    let id: UUID
    let text: String
    let sender: String
    let receivedAt: Date
    
    init(id: UUID = UUID(), text: String, sender: String, receivedAt: Date) {
        self.id = id
        self.text = text
        self.sender = sender
        self.receivedAt = receivedAt
    }
}

/// Простое хранилище для SMS сообщений в памяти
/// В будущем заменим на Swift Data
@Observable
class SMSStorage {
    static let shared = SMSStorage()
    
    private(set) var messages: [SMSMessage] = []
    
    private init() {
        // Загружаем сохраненные сообщения
        loadMessages()
    }
    
    /// Добавить новое сообщение
    func addMessage(_ message: SMSMessage) {
        messages.insert(message, at: 0) // Новые сверху
        saveMessages()
    }
    
    /// Удалить сообщение
    func deleteMessage(_ message: SMSMessage) {
        messages.removeAll { $0.id == message.id }
        saveMessages()
    }
    
    /// Очистить все сообщения
    func clearAll() {
        messages.removeAll()
        saveMessages()
    }
    
    // MARK: - Persistence
    
    private func saveMessages() {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: "saved_messages")
        }
    }
    
    private func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: "saved_messages"),
           let decoded = try? JSONDecoder().decode([SMSMessage].self, from: data) {
            messages = decoded
        }
    }
}

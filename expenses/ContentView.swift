//
//  ContentView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var storage = SMSStorage.shared
    @State private var showingAddManually = false
    @State private var showingInstructions = false
    
    var body: some View {
        NavigationStack {
            Group {
                if storage.messages.isEmpty {
                    emptyStateView
                } else {
                    messagesList
                }
            }
            .navigationTitle("SMS Сообщения")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddManually = true
                    } label: {
                        Label("Добавить", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        showingInstructions = true
                    } label: {
                        Label("Настройка", systemImage: "gearshape")
                    }
                }
                
                if !storage.messages.isEmpty {
                    ToolbarItem(placement: .secondaryAction) {
                        Button(role: .destructive) {
                            withAnimation {
                                storage.clearAll()
                            }
                        } label: {
                            Label("Очистить все", systemImage: "trash")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddManually) {
                AddManualSMSView()
            }
            .sheet(isPresented: $showingInstructions) {
                SetupInstructionsView()
            }
        }
    }
    
    // MARK: - Views
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Нет сообщений")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Добавьте SMS вручную или настройте автоматизацию в приложении \"Команды\"")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Button {
                    showingAddManually = true
                } label: {
                    Label("Добавить вручную", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    showingInstructions = true
                } label: {
                    Label("Как настроить автоматизацию", systemImage: "gearshape")
                        .font(.headline)
                }
                .buttonStyle(.bordered)
            }
            .padding(.top)
        }
        .padding()
    }
    
    private var messagesList: some View {
        List {
            ForEach(storage.messages) { message in
                SMSMessageRow(message: message)
            }
            .onDelete { indexSet in
                withAnimation {
                    for index in indexSet {
                        storage.deleteMessage(storage.messages[index])
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Message Row

struct SMSMessageRow: View {
    let message: SMSMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Заголовок с отправителем и временем
            HStack {
                Label(message.sender, systemImage: "person.circle.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(message.receivedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Текст сообщения
            Text(message.text)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            
            // Точное время
            Text(message.receivedAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Manual SMS View

struct AddManualSMSView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var smsText = ""
    @State private var sender = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Отправитель") {
                    TextField("Например: Сбербанк", text: $sender)
                }
                
                Section("Текст сообщения") {
                    TextEditor(text: $smsText)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button("Добавить") {
                        addMessage()
                    }
                    .disabled(smsText.isEmpty)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Добавить SMS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addMessage() {
        let message = SMSMessage(
            text: smsText,
            sender: sender.isEmpty ? "Неизвестно" : sender,
            receivedAt: Date()
        )
        
        SMSStorage.shared.addMessage(message)
        dismiss()
    }
}

#Preview {
    ContentView()
}

#Preview("With Messages") {
    // Добавляем тестовые данные для превью
    let storage = SMSStorage.shared
    storage.addMessage(SMSMessage(
        text: "Покупка 1500.00 RUB Магазин ПЯТЕРОЧКА. Баланс: 10000.00 RUB",
        sender: "Сбербанк",
        receivedAt: Date().addingTimeInterval(-3600)
    ))
    storage.addMessage(SMSMessage(
        text: "Оплата 2500 р. Яндекс.Такси",
        sender: "Тинькофф",
        receivedAt: Date()
    ))
    
    return ContentView()
}

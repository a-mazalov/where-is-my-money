//
//  ContentView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SMSMessage.receivedAt, order: .reverse) private var messages: [SMSMessage]
    
    @State private var showingAddManually = false
    @State private var showingInstructions = false
    
    var body: some View {
        NavigationStack {
            Group {
                if messages.isEmpty {
                    EmptyStateView(
                        onAddManually: { showingAddManually = true },
                        onShowInstructions: { showingInstructions = true }
                    )
                } else {
                    messagesList
                }
            }
            .navigationTitle("События")
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
                
                if !messages.isEmpty {
                    ToolbarItem(placement: .secondaryAction) {
                        Button(role: .destructive) {
                            withAnimation {
                                clearAll()
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
    
    // MARK: - Actions
    
    private func clearAll() {
        messages.forEach { modelContext.delete($0) }
    }
    
    // MARK: - Views
    
    private var messagesList: some View {
        List {
            ForEach(messages) { message in
                SMSMessageRow(message: message)
            }
            .onDelete { indexSet in
                withAnimation {
                    for index in indexSet {
                        modelContext.delete(messages[index])
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    MainView()
        .modelContainer(for: SMSMessage.self, inMemory: true)
}

#Preview("With Messages") {
    let container = try! ModelContainer(
        for: SMSMessage.self, 
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    // Добавляем тестовые данные
    let message1 = SMSMessage(
        text: "Покупка 1500.00 RUB Магазин ПЯТЕРОЧКА. Баланс: 10000.00 RUB",
        sender: "Сбербанк",
        receivedAt: Date().addingTimeInterval(-3600)
    )
    let message2 = SMSMessage(
        text: "Оплата 2500 р. Яндекс.Такси",
        sender: "Тинькофф",
        receivedAt: Date()
    )
    
    container.mainContext.insert(message1)
    container.mainContext.insert(message2)
    
    return MainView()
        .modelContainer(container)
}

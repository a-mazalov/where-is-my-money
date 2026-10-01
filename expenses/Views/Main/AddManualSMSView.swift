//
//  AddManualSMSView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI
import SwiftData

struct AddManualSMSView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
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
        
        modelContext.insert(message)
        dismiss()
    }
}

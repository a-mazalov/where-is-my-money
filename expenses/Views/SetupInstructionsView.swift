//
//  SetupInstructionsView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI

struct SetupInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    
                    stepsSection
                    
                    bankExamplesSection
                    
                    testingSection
                }
                .padding()
            }
            .navigationTitle("Настройка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gearshape.2.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading) {
                    Text("Автоматическая обработка SMS")
                        .font(.headline)
                    Text("Настройте автоматизацию в приложении \"Команды\"")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text("iOS не разрешает приложениям напрямую читать SMS, но вы можете настроить автоматизацию через встроенное приложение \"Команды\".")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Пошаговая инструкция")
                .font(.title2)
                .fontWeight(.bold)
            
            InstructionStep(
                number: 1,
                title: "Откройте \"Команды\"",
                description: "Найдите приложение \"Команды\" (Shortcuts) и перейдите на вкладку \"Автоматизация\"",
                icon: "app.badge"
            )
            
            InstructionStep(
                number: 2,
                title: "Создайте автоматизацию",
                description: "Нажмите \"+\" и выберите \"Создать личную автоматизацию\"",
                icon: "plus.circle.fill"
            )
            
            InstructionStep(
                number: 3,
                title: "Выберите триггер \"Сообщение\"",
                description: "Укажите отправителя (например: \"Сбербанк\") и при желании ключевые слова",
                icon: "message.fill"
            )
            
            InstructionStep(
                number: 4,
                title: "Добавьте действие",
                description: "Найдите \"expenses\" → \"Обработать SMS\" и настройте параметры:\n• Текст SMS: \"Содержимое сообщения\"\n• Отправитель: \"Отправитель\"",
                icon: "square.and.arrow.down.fill"
            )
            
            InstructionStep(
                number: 5,
                title: "Отключите подтверждение",
                description: "⚠️ ВАЖНО: Отключите \"Спрашивать перед запуском\" для автоматической работы",
                icon: "checkmark.circle.fill"
            )
        }
    }
    
    private var bankExamplesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Примеры настроек для банков")
                .font(.title2)
                .fontWeight(.bold)
            
            BankExample(
                name: "Сбербанк",
                icon: "🟢",
                sender: "Сбербанк или 900",
                keywords: "Покупка, Оплата"
            )
            
            BankExample(
                name: "Тинькофф",
                icon: "🟡",
                sender: "Tinkoff или Тинькофф",
                keywords: "Оплата, Покупка"
            )
            
            BankExample(
                name: "ВТБ",
                icon: "🔵",
                sender: "VTB или ВТБ",
                keywords: "Операция"
            )
            
            BankExample(
                name: "Альфа-Банк",
                icon: "🔴",
                sender: "AlfaBank или Альфа",
                keywords: "Оплата"
            )
        }
    }
    
    private var testingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Тестирование")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                TestingTip(
                    icon: "paperplane.fill",
                    text: "Попросите отправить вам тестовое SMS"
                )
                
                TestingTip(
                    icon: "hand.tap.fill",
                    text: "Добавьте сообщение вручную через кнопку \"+\""
                )
                
                TestingTip(
                    icon: "wand.and.stars",
                    text: "Запустите команду вручную из виджета Shortcuts"
                )
            }
        }
        .padding()
        .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Components

struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 36, height: 36)
                
                Text("\(number)")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(.blue)
                    Text(title)
                        .font(.headline)
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct BankExample: View {
    let name: String
    let icon: String
    let sender: String
    let keywords: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                    .font(.title2)
                Text(name)
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Label("Отправитель: \(sender)", systemImage: "person.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label("Ключевые слова: \(keywords)", systemImage: "text.magnifyingglass")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct TestingTip: View {
    let icon: String
    let text: String
    
    var body: some View {
        Label(text, systemImage: icon)
            .font(.subheadline)
    }
}

#Preview {
    SetupInstructionsView()
}

//
//  SMSMonthlyView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI
import SwiftData

struct SMSMonthlyView: View {
    @Query(sort: \SMSMessage.receivedAt, order: .reverse) private var allMessages: [SMSMessage]
    
    var body: some View {
        NavigationStack {
            Group {
                if allMessages.isEmpty {
                    ContentUnavailableView(
                        "Нет сообщений",
                        systemImage: "message.slash",
                        description: Text("SMS сообщения появятся здесь после обработки")
                    )
                } else {
                    monthlyList
                }
            }
            .navigationTitle("По месяцам")
        }
    }
    
    // MARK: - Computed Properties
    
    /// Группирует сообщения по месяцам
    private var groupedMessages: [(month: Date, messages: [SMSMessage], total: Double)] {
        let calendar = Calendar.current
        
        // Группируем по месяцам
        let grouped = Dictionary(grouping: allMessages) { message in
            calendar.startOfMonth(for: message.receivedAt)
        }
        
        // Преобразуем в массив с подсчётом суммы
        return grouped.map { (month, messages) in
            let total = messages.compactMap { $0.amount }.reduce(0, +)
            return (month: month, messages: messages, total: total)
        }
        .sorted { $0.month > $1.month } // Сортируем по убыванию (новые сверху)
    }
    
    // MARK: - Views
    
    private var monthlyList: some View {
        List {
            ForEach(groupedMessages, id: \.month) { group in
                monthSummaryRow(month: group.month, total: group.total, count: group.messages.count)
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func monthSummaryRow(month: Date, total: Double, count: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(month, format: .dateTime.month(.wide).year())
                    .font(.headline)
                Text("Сообщений: \(count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(total, format: .currency(code: "BYN"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                if total > 0 {
                    Text("Итого")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Calendar Extension

private extension Calendar {
    /// Возвращает начало месяца для указанной даты
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

// MARK: - Preview

#Preview("Empty") {
    SMSMonthlyView()
        .modelContainer(for: SMSMessage.self, inMemory: true)
}

#Preview("With Data") {
    let container = try! ModelContainer(
        for: SMSMessage.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
    let calendar = Calendar.current
    
    // Создаём сообщения за разные месяцы
    
    // Октябрь 2026
    let oct1 = SMSMessage(
        text: "Покупка 150.00 BYN Магазин ЕВРООПТ",
        sender: "Альфа-Банк",
        receivedAt: Date()
    )
    oct1.amount = 150.00
    
    let oct2 = SMSMessage(
        text: "Оплата 75.50 BYN Кафе",
        sender: "Альфа-Банк",
        receivedAt: calendar.date(byAdding: .day, value: -3, to: Date())!
    )
    oct2.amount = 75.50
    
    // Сентябрь 2026
    let sep1 = SMSMessage(
        text: "Покупка 200.00 BYN",
        sender: "Альфа-Банк",
        receivedAt: calendar.date(byAdding: .month, value: -1, to: Date())!
    )
    sep1.amount = 200.00
    
    let sep2 = SMSMessage(
        text: "Оплата 120.00 BYN",
        sender: "Альфа-Банк",
        receivedAt: calendar.date(byAdding: .day, value: -35, to: Date())!
    )
    sep2.amount = 120.00
    
    let sep3 = SMSMessage(
        text: "Перевод 50.00 BYN",
        sender: "Альфа-Банк",
        receivedAt: calendar.date(byAdding: .day, value: -40, to: Date())!
    )
    sep3.amount = 50.00
    
    // Август 2026
    let aug1 = SMSMessage(
        text: "Покупка 300.00 BYN",
        sender: "Альфа-Банк",
        receivedAt: calendar.date(byAdding: .month, value: -2, to: Date())!
    )
    aug1.amount = 300.00
    
    context.insert(oct1)
    context.insert(oct2)
    context.insert(sep1)
    context.insert(sep2)
    context.insert(sep3)
    context.insert(aug1)
    
    return SMSMonthlyView()
        .modelContainer(container)
}

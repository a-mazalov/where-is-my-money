//
//  SMSMonthlyView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI
import SwiftData
import Charts

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
                NavigationLink {
                    MonthMessagesView(month: group.month, messages: group.messages)
                } label: {
                    monthSummaryRow(month: group.month, total: group.total, count: group.messages.count)
                }
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

// MARK: - Month Messages Detail

private struct MonthMessagesView: View {
    let month: Date
    let messages: [SMSMessage]

    @State private var editingOrganization: Organization?
    @State private var selectedCategory: ExpenseCategory?
    @State private var selectedAngleValue: Double?

    private struct CategoryTotal: Identifiable {
        let category: ExpenseCategory
        let total: Double
        var id: String { category.id }
    }

    /// Группирует суммы сообщений по категориям их организаций
    private var categoryTotals: [CategoryTotal] {
        let grouped = Dictionary(grouping: messages) { message in
            message.organization?.category ?? .unknown
        }
        return grouped.compactMap { category, messages in
            let total = messages.compactMap { $0.amount }.reduce(0, +)
            guard total > 0 else { return nil }
            return CategoryTotal(category: category, total: total)
        }
        .sorted { $0.total > $1.total }
    }

    /// Сообщения, отфильтрованные по выбранной на диаграмме категории
    private var filteredMessages: [SMSMessage] {
        guard let selectedCategory else { return messages }
        return messages.filter { ($0.organization?.category ?? .unknown) == selectedCategory }
    }

    var body: some View {
        List {
            if !categoryTotals.isEmpty {
                Section {
                    categoryChart
                    if let selectedCategory {
                        selectedCategoryFilterRow(selectedCategory)
                    }
                }
            }

            ForEach(filteredMessages) { message in
                Button {
                    editingOrganization = message.organization
                } label: {
                    SMSMessageRow(message: message)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(month.formatted(.dateTime.month(.wide).year()))
        .sheet(item: $editingOrganization) { organization in
            EditOrganizationView(organization: organization)
        }
        .onChange(of: selectedAngleValue) { _, newValue in
            guard let newValue, let category = category(forAngleValue: newValue) else { return }
            withAnimation {
                selectedCategory = (selectedCategory == category) ? nil : category
            }
        }
    }

    /// Сопоставляет значение угла, выбранное на диаграмме, с категорией.
    /// `chartAngleSelection` возвращает накопленное положение внутри суммарного диапазона,
    /// поэтому категория определяется накоплением сумм в том же порядке, в котором построены секторы.
    private func category(forAngleValue value: Double) -> ExpenseCategory? {
        var accumulated = 0.0
        for item in categoryTotals {
            accumulated += item.total
            if value <= accumulated {
                return item.category
            }
        }
        return nil
    }

    private var categoryChart: some View {
        Chart(categoryTotals) { item in
            SectorMark(
                angle: .value("Сумма", item.total),
                innerRadius: .ratio(0.6),
                angularInset: 1.5
            )
            .foregroundStyle(by: .value("Категория", item.category.rawValue))
            .opacity(selectedCategory == nil || selectedCategory == item.category ? 1.0 : 0.3)
            .cornerRadius(4)
        }
        .chartForegroundStyleScale(
            domain: categoryTotals.map(\.category.rawValue),
            mapping: { name in
                ExpenseCategory(rawValue: name)?.color ?? .gray
            }
        )
        .chartAngleSelection(value: $selectedAngleValue)
        .chartLegend(position: .bottom, alignment: .center, spacing: 8)
        .frame(height: 240)
        .padding(.vertical, 8)
    }

    private func selectedCategoryFilterRow(_ category: ExpenseCategory) -> some View {
        HStack {
            Label(category.rawValue, systemImage: category.icon)
                .font(.subheadline)
                .foregroundStyle(category.color)

            Spacer()

            Button("Сбросить") {
                withAnimation {
                    selectedCategory = nil
                    selectedAngleValue = nil
                }
            }
            .font(.subheadline)
        }
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

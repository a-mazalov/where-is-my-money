//
//  SMSMessageRow.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI

struct SMSMessageRow: View {
    let message: SMSMessage

    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок с отправителем и временем
            HStack {
                Label(message.sender, systemImage: "creditcard")
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
            
            // Сумма
            if let amount = message.amount {
                Text(String(format: "%.2f BYN", amount))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            
            HStack {
                // Категория и организация
                if let organization = message.organization {
                    Label(organization.name, systemImage: organization.category.icon)
                        .foregroundStyle(organization.category.color)
                } else {
                    Label("Неизвестно", systemImage: ExpenseCategory.unknown.icon)
                        .foregroundStyle(ExpenseCategory.unknown.color)
                }
                
                Spacer()
                
                // Точное время
                Text(message.receivedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

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
            
            Text(SMSParserService.extractAmount(from: message.text).map { "\($0, specifier: "%.2f") BYN" } ?? "Сумма не найдена")
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            
            
            Text(SMSParserService.extractOrganization(from: message.text) ?? "Организация не найдена")
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            
            HStack {
                Label(ExpenseCategory.cafe.rawValue, systemImage: ExpenseCategory.cafe.icon)
                    .foregroundStyle(ExpenseCategory.cafe.color)
                
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

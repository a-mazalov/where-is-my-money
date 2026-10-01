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

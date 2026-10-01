//
//  EmptyStateView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI

struct EmptyStateView: View {
    let onAddManually: () -> Void
    let onShowInstructions: () -> Void
    
    var body: some View {
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
                    onAddManually()
                } label: {
                    Label("Добавить вручную", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    onShowInstructions()
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
}

#Preview {
    EmptyStateView(
        onAddManually: { print("Add manually tapped") },
        onShowInstructions: { print("Instructions tapped") }
    )
}

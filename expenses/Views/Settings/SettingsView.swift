//
//  SettingsView.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isImporting = false
    @State private var resultMessage: String?
    @State private var errorMessage: String?
    @State private var isShowingDeleteAllConfirmation = false
    @State private var isProcessingImport = false
    @State private var importProgress: Double = 0
    @State private var processedCount = 0
    @State private var totalCount = 0

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    dropZone
                } header: {
                    Text("Импорт SMS из CSV")
                } footer: {
                    Text("Перетащите CSV-файл сюда или выберите его вручную. Формат строки: дата,отправитель,канал,направление,текст. Импортируются только входящие сообщения.")
                }

                if isProcessingImport {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            ProgressView(value: importProgress)
                            Text("Обработано \(processedCount) из \(totalCount)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section {
                    Button("Удалить все SMS и организации", role: .destructive) {
                        isShowingDeleteAllConfirmation = true
                    }
                    .disabled(isProcessingImport)
                } footer: {
                    Text("Безвозвратно удаляет все сохранённые SMS-сообщения и организации.")
                }

                if let resultMessage {
                    Section {
                        Label(resultMessage, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }

                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Настройки")
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.commaSeparatedText, .plainText],
                onCompletion: handleFileImporterResult
            )
            .confirmationDialog(
                "Удалить все SMS и организации?",
                isPresented: $isShowingDeleteAllConfirmation,
                titleVisibility: .visible
            ) {
                Button("Удалить всё", role: .destructive) {
                    deleteAll()
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Это действие нельзя отменить.")
            }
        }
    }

    private var dropZone: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.arrow.down.on.square")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("Перетащите CSV-файл сюда")
                .font(.headline)

            Button("Выбрать файл") {
                isImporting = true
            }
            .buttonStyle(.bordered)
            .disabled(isProcessingImport)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
        )
        .dropDestination(for: URL.self) { urls, _ in
            guard !isProcessingImport, let url = urls.first else { return }
            importCSV(from: url)
        }
    }

    private func handleFileImporterResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            importCSV(from: url)
        case .failure(let error):
            resultMessage = nil
            errorMessage = error.localizedDescription
        }
    }

    private func deleteAll() {
        do {
            try modelContext.delete(model: SMSMessage.self)
            try modelContext.delete(model: Organization.self)
            try modelContext.delete(model: SystemOrganization.self)
            try modelContext.save()
            errorMessage = nil
            resultMessage = "Все SMS и организации удалены"
        } catch {
            resultMessage = nil
            errorMessage = error.localizedDescription
        }
    }

    private func importCSV(from url: URL) {
        resultMessage = nil
        errorMessage = nil
        processedCount = 0
        totalCount = 0
        importProgress = 0
        isProcessingImport = true

        Task {
            do {
                let result = try await CSVImportService.importMessages(
                    from: url,
                    context: modelContext
                ) { processed, total in
                    processedCount = processed
                    totalCount = total
                    importProgress = total > 0 ? Double(processed) / Double(total) : 0
                }
                resultMessage = "Импортировано: \(result.importedCount), пропущено: \(result.skippedCount)"
            } catch {
                errorMessage = error.localizedDescription
            }
            isProcessingImport = false
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [SMSMessage.self, Organization.self], inMemory: true)
}

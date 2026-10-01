//
//  CSVImportService.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import Foundation
import SwiftData

enum CSVImportError: LocalizedError {
    case unreadableFile
    case emptyFile

    var errorDescription: String? {
        switch self {
        case .unreadableFile:
            return "Не удалось прочитать файл"
        case .emptyFile:
            return "Файл пуст"
        }
    }
}

struct CSVImportResult {
    let importedCount: Int
    let skippedCount: Int
}

/// Импортирует SMS-сообщения из CSV-файла экспорта SMS (без заголовка).
/// Формат строки: дата,отправитель,канал,направление,текст
/// Например:
/// 2023-11-24 10:19:23,Priorbank,SMS,in,Priorbank. Karta 5***4300 24-11-2023 13:19:16. Oplata 5.28 BYN. BLR STOLOVAYA N 49 / SOLIG. Dostupno: 1300.12 BYN. Spravka: 80172899292
/// Импортируются только входящие сообщения (направление "in").
@MainActor
final class CSVImportService {

    /// Количество полей в строке: дата, отправитель, канал, направление, текст.
    private static let fieldCount = 5

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    @discardableResult
    static func importMessages(
        from url: URL,
        context: ModelContext,
        onProgress: ((_ processed: Int, _ total: Int) -> Void)? = nil
    ) async throws -> CSVImportResult {
        let needsAccess = url.startAccessingSecurityScopedResource()
        defer {
            if needsAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        guard let data = try? Data(contentsOf: url) else {
            throw CSVImportError.unreadableFile
        }

        guard let content = String(data: data, encoding: .utf8) else {
            throw CSVImportError.unreadableFile
        }

        return try await importMessages(from: content, context: context, onProgress: onProgress)
    }

    static func importMessages(
        from content: String,
        context: ModelContext,
        onProgress: ((_ processed: Int, _ total: Int) -> Void)? = nil
    ) async throws -> CSVImportResult {
        let lines = content
            .components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        guard !lines.isEmpty else {
            throw CSVImportError.emptyFile
        }

        var imported = 0
        var skipped = 0
        let total = lines.count

        for (index, line) in lines.enumerated() {
            guard let fields = splitRow(line) else {
                skipped += 1
                continue
            }

            let dateString = fields[0].trimmingCharacters(in: .whitespaces)
            let sender = fields[1].trimmingCharacters(in: .whitespaces)
            let direction = fields[3].trimmingCharacters(in: .whitespaces)
            let text = fields[4].trimmingCharacters(in: .whitespacesAndNewlines)

            guard direction.caseInsensitiveCompare("in") == .orderedSame,
                  !text.isEmpty,
                  SMSParserService.extractAmount(from: text) != nil else {
                skipped += 1
                onProgress?(index + 1, total)
                continue
            }

            let receivedAt = dateFormatter.date(from: dateString) ?? Date()

            _ = SMSProcessingService.processSMS(
                text: text,
                sender: sender.isEmpty ? "Неизвестно" : sender,
                receivedAt: receivedAt,
                context: context
            )

            imported += 1
            onProgress?(index + 1, total)

            // Отдаём управление главному потоку, чтобы UI успевал обновлять индикатор прогресса.
            if (index + 1).isMultiple(of: 20) {
                await Task.yield()
            }
        }

        try context.save()

        return CSVImportResult(importedCount: imported, skippedCount: skipped)
    }

    /// Разбивает строку на `fieldCount` полей, разделяя её только по первым
    /// `fieldCount - 1` запятым. Последнее поле (текст SMS) забирает весь
    /// остаток строки целиком, поэтому запятые внутри самого текста
    /// (например, в названии организации) не ломают разбор.
    private static func splitRow(_ line: String) -> [String]? {
        var fields: [String] = []
        var remainder = Substring(line)

        for _ in 0..<(fieldCount - 1) {
            guard let commaIndex = remainder.firstIndex(of: ",") else {
                return nil
            }
            fields.append(String(remainder[remainder.startIndex..<commaIndex]))
            remainder = remainder[remainder.index(after: commaIndex)...]
        }
        fields.append(String(remainder))

        return fields
    }
}

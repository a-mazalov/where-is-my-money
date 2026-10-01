//
//  SMSParserService.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import Foundation

final class SMSParserService {
    
    /// Извлекает строку начиная с "BLR" до первой точки
    /// Например: "Покупка 1500.00 BLR Магазин ПЯТЕРОЧКА. Баланс: 10000.00" -> "BLR Магазин ПЯТЕРОЧКА"
    static func extractOrganization(from text: String) -> String? {
        // Ищем "BLR" в тексте
        guard let blrRange = text.range(of: "BLR", options: .caseInsensitive) else {
            return nil
        }
        
        // Берем подстроку начиная с "BLR"
        let substringFromBLR = text[blrRange.lowerBound...]
        
        // Ищем первую точку после "BLR"
        guard let dotRange = substringFromBLR.range(of: ".") else {
            // Если точки нет, возвращаем всё до конца
            return String(substringFromBLR).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Извлекаем текст от "BLR" до точки
        let result = substringFromBLR[..<dotRange.lowerBound]
        return String(result).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

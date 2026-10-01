//
//  ExpenseCategory.swift
//  expenses
//
//  Created by WebIT on 01.10.2026.
//

import Foundation
import SwiftUI

enum ExpenseCategory: String, CaseIterable, Identifiable {
    case groceries = "Продукты"
    case auto = "Авто"
    case cafe = "Кафе"
    case transfers = "Переводы"
    case unknown = "Неизвестно"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
            case .groceries: return "cart.fill"
            case .auto: return "car.fill"
            case .cafe: return "cup.and.saucer.fill"
            case .transfers: return "arrow.left.arrow.right"
            case .unknown: return "circle.dashed"
        }
    }
    
    var color: Color {
        switch self {
            case .groceries: return .green
            case .auto: return .blue
            case .cafe: return .orange
            case .transfers: return .purple
            case .unknown: return .gray
        }
    }
}

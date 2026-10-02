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
    case cafe = "Кафе"
    case auto = "Авто"
    case health = "Здоровье"
    case petSupplies = "Зоотовары"
    case atms = "Банкоматы"
    case clothing = "Одежда"
    case electronics = "Электроника"
    case transfers = "Переводы друзьям"
    case unknown = "Неизвестно"

    var id: String { rawValue }

    var icon: String {
        switch self {
            case .groceries: return "cart.fill"
            case .cafe: return "cup.and.saucer.fill"
            case .auto: return "car.fill"
            case .health: return "cross.case.fill"
            case .petSupplies: return "pawprint.fill"
            case .atms: return "banknote.fill"
            case .clothing: return "tshirt.fill"
            case .electronics: return "tv.fill"
            case .transfers: return "arrow.left.arrow.right"
            case .unknown: return "circle.dashed"
        }
    }

    var color: Color {
        switch self {
            case .groceries: return .green
            case .cafe: return .orange
            case .auto: return .blue
            case .health: return .red
            case .petSupplies: return .brown
            case .atms: return .mint
            case .clothing: return .pink
            case .electronics: return .indigo
            case .transfers: return .purple
            case .unknown: return .gray
        }
    }
}

//
//  BankProfileParserServiceTests.swift
//  expensesTests
//
//  Created by WebIT on 01.10.2026.
//

import Foundation
import Testing
@testable import expenses

struct BankProfileParserServiceTests {

    // MARK: - Fixtures

    private static let priorbankProfile = BankProfile(
        schemaVersion: 1,
        bankId: "priorbank_by",
        displayName: "Приорбанк",
        configVersion: "2026-10-02T12:00:00Z",
        senderMatchers: ["Priorbank", "900"],
        templates: [
            MessageTemplate(
                templateId: "purchase",
                detect: FieldRule(pattern: "Oplata", options: ["caseInsensitive"], group: nil, transform: nil, required: nil),
                fields: [
                    "amount": FieldRule(pattern: #"Oplata\s+([\d.]+)\s*BYN"#, options: nil, group: 1, transform: "decimal", required: true),
                    "currency": FieldRule(pattern: #"([A-Z]{3})\b"#, options: nil, group: 1, transform: nil, required: false),
                    "organization": FieldRule(pattern: #"(\b[A-Z]{3}\b\s+.+?)\."#, options: nil, group: 1, transform: "trim", required: true),
                    "balance": FieldRule(pattern: #"Balans:\s*([\d.]+)"#, options: nil, group: 1, transform: "decimal", required: false)
                ]
            ),
            MessageTemplate(
                templateId: "transfer_out",
                detect: FieldRule(pattern: #"Perevod\s+[\d.]+\s*BYN"#, options: ["caseInsensitive"], group: nil, transform: nil, required: nil),
                fields: [
                    "amount": FieldRule(pattern: #"Perevod\s+([\d.]+)\s*BYN"#, options: nil, group: 1, transform: "decimal", required: true),
                    "recipient": FieldRule(pattern: #"poluchatelyu\s+(.+?)\."#, options: nil, group: 1, transform: "trim", required: false)
                ]
            ),
            MessageTemplate(
                templateId: "transfer_in",
                detect: FieldRule(pattern: "Zachislenie perevoda", options: ["caseInsensitive"], group: nil, transform: nil, required: nil),
                fields: [
                    "amount": FieldRule(pattern: #"Zachislenie perevoda\s+([\d.]+)\s*BYN"#, options: nil, group: 1, transform: "decimal", required: true)
                ]
            )
        ]
    )

    private static func makeService() -> BankProfileParserService {
        BankProfileParserService(profiles: [priorbankProfile])
    }

    // MARK: - Tests

    @Test func parsesPurchaseMessage() {
        let service = Self.makeService()
        let text = "Oplata 63.00 BYN. BLR Magazin Pyaterochka. Balans: 10000.00"

        let result = service.parse(text: text, sender: "Priorbank")

        #expect(result?.bankId == "priorbank_by")
        #expect(result?.templateId == "purchase")
        #expect(result?.amount == 63.00)
        #expect(result?.organization == "BLR Magazin Pyaterochka")
        #expect(result?.values["currency"] == "BYN")
        #expect(result?.values["balance"] == "10000.00")
    }

    @Test func parsesTransferOutMessage() {
        let service = Self.makeService()
        let text = "Perevod 100.00 BYN poluchatelyu Ivan Ivanov."

        let result = service.parse(text: text, sender: "Priorbank")

        #expect(result?.templateId == "transfer_out")
        #expect(result?.amount == 100.00)
        #expect(result?.values["recipient"] == "Ivan Ivanov")
    }

    @Test func parsesTransferInMessageWithoutOptionalFields() {
        let service = Self.makeService()
        let text = "Zachislenie perevoda 50.00 BYN."

        let result = service.parse(text: text, sender: "900")

        #expect(result?.templateId == "transfer_in")
        #expect(result?.amount == 50.00)
    }

    @Test func senderMatchingIsCaseInsensitive() {
        let service = Self.makeService()
        let text = "Oplata 10.00 BYN. BLR Kafe Varka. Balans: 500.00"

        let result = service.parse(text: text, sender: "priorbank")

        #expect(result != nil)
    }

    @Test func unknownSenderReturnsNil() {
        let service = Self.makeService()
        let text = "Oplata 63.00 BYN. BLR Magazin Pyaterochka. Balans: 10000.00"

        let result = service.parse(text: text, sender: "SomeOtherBank")

        #expect(result == nil)
    }

    @Test func knownSenderWithUnrecognizedFormatReturnsNil() {
        let service = Self.makeService()
        let text = "Vash kod podtverzhdeniya: 1234"

        let result = service.parse(text: text, sender: "Priorbank")

        #expect(result == nil)
    }

    @Test func missingRequiredFieldReturnsNil() {
        let service = Self.makeService()
        // "Oplata" триггерит шаблон purchase, но нет маркера "BLR" -> organization (required) не найдётся
        let text = "Oplata 63.00 BYN. Magazin Pyaterochka bez marker."

        let result = service.parse(text: text, sender: "Priorbank")

        #expect(result == nil)
    }

    @Test func loadsBundledBankProfilesResource() throws {
        let service = try BankProfileParserService(bundle: .main)
        let text = "Oplata 63.00 BYN. BLR Magazin Pyaterochka. Balans: 10000.00"

        let result = service.parse(text: text, sender: "Priorbank")

        #expect(result?.bankId == "priorbank_by")
        #expect(result?.amount == 63.00)
    }
}

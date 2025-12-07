//
//  IntExtension.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/22.
//

import Foundation

extension Int {
    
    // MARK: - Number Formatting
    func abbreviated() -> String {
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""
        
        let (value, unit) = abbreviationComponents(for: absValue)
        let formattedValue = formatValue(value)
        
        return sign + formattedValue + unit
    }
    
    func formattedCount() -> String {
        abbreviated()
    }
    
    // MARK: - Private Helpers
    private func abbreviationComponents(for value: Int) -> (Double, String) {
        switch value {
        case 1_000_000_000_000...:
            return (Double(value) / 1_000_000_000_000, "T")
        case 1_000_000_000..<1_000_000_000_000:
            return (Double(value) / 1_000_000_000, "B")
        case 1_000_000..<1_000_000_000:
            return (Double(value) / 1_000_000, "M")
        case 1_000..<1_000_000:
            return (Double(value) / 1_000, "K")
        default:
            return (Double(value), "")
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}


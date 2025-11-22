//
//  IntExtension.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/22.
//

import Foundation

extension Int {
    func formattedCount() -> String {
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""
        
        let (value, unit): (Double, String) = {
            switch absValue {
            case 1_000_000_000_000...:
                return (Double(absValue) / 1_000_000_000_000.0, "T")
            case 1_000_000_000..<1_000_000_000_000:
                return (Double(absValue) / 1_000_000_000.0, "B")
            case 1_000_000..<1_000_000_000:
                return (Double(absValue) / 1_000_000.0, "M")
            case 1_000..<1_000_000:
                return (Double(absValue) / 1_000.0, "K")
            default:
                return (Double(absValue), "")
            }
        }()
        
        let formattedValue = value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
        
        return sign + formattedValue + unit
    }
}


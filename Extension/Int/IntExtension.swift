//
//  IntExtension.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/22.
//

import Foundation

// MARK: - Number Formatting
extension Int {
    
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
}

// MARK: - Time Formatting
extension Int {
    
    func formattedDuration() -> String? {
        guard self > 0 else { return nil }
        
        enum TimeUnit {
            static let secondsPerMinute = 60
            static let secondsPerHour = 3600
            static let secondsPerDay = 86400
            static let secondsPerYear = 31_536_000
        }
        
        let years = self / TimeUnit.secondsPerYear
        let remainingAfterYears = self % TimeUnit.secondsPerYear
        let days = remainingAfterYears / TimeUnit.secondsPerDay
        let remainingAfterDays = remainingAfterYears % TimeUnit.secondsPerDay
        let hours = remainingAfterDays / TimeUnit.secondsPerHour
        let remainingAfterHours = remainingAfterDays % TimeUnit.secondsPerHour
        let minutes = remainingAfterHours / TimeUnit.secondsPerMinute
        let seconds = remainingAfterHours % TimeUnit.secondsPerMinute
        
        guard years >= 0,
              days >= 0,
              days < 365,
              hours >= 0,
              minutes >= 0,
              minutes < 60,
              seconds >= 0,
              seconds < 60 else {
            return nil
        }
        
        var components: [String] = []
        
        if years > 0 {
            let yearLabel = years == 1 ? "year" : "years"
            components.append("\(years) \(yearLabel)")
        }
        
        if days > 0 {
            let dayLabel = days == 1 ? "day" : "days"
            components.append("\(days) \(dayLabel)")
        }
        
        let timeString: String
        if hours > 0 || years > 0 || days > 0 {
            timeString = String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            timeString = String(format: "%d:%02d", minutes, seconds)
        }
        
        if !timeString.isEmpty && (hours > 0 || minutes > 0 || seconds > 0) {
            components.append(timeString)
        }
        
        return components.isEmpty ? nil : components.joined(separator: " ")
    }
}

// MARK: - Private Helpers
private extension Int {
    
    func abbreviationComponents(for value: Int) -> (Double, String) {
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
    
    func formatValue(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}


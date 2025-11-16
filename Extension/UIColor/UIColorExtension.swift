//
//  UIColorExtension.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/16.
//

import Foundation
import UIKit

extension UIColor {
    static func hex(_ hex: String) -> UIColor {
        let trimmed = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let hexString = trimmed.hasPrefix("#") ? String(trimmed.dropFirst()) : trimmed
        let scanner = Scanner(string: hexString)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else {
            return .clear
        }

        switch hexString.count {
        case 6:
            let r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(hexNumber & 0x0000FF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: 1.0)
        case 8:
            let a = CGFloat((hexNumber & 0xFF000000) >> 24) / 255.0
            let r = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255.0
            let g = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255.0
            let b = CGFloat(hexNumber & 0x000000FF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: a)
        default:
            return .clear
        }
    }

    static var vimeoBlack: UIColor {
        UIColor.hex("#141A20")
    }

    static var vimeoBlue: UIColor {
        UIColor.hex("#17D5FF")
    }

    static var vimeoWhite: UIColor {
        UIColor.hex("#FAFCFD")
    }
}

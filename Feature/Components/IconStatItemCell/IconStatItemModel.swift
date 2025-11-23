//
//  IconStatItemModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/23.
//

import Foundation

struct IconStatItemModel {
    let title: String
    let value: Int?
    let icon: String
    let path: String?
    
    init(title: String, value: Int? = nil, icon: String, path: String? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.path = path
    }
}

//
//  IconStatItemModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/23.
//

import Foundation

struct IconStatItemModel: IconStatItemCollectionView.Displayable {
    let title: String
    let value: Int?
    let icon: String
    let path: String?
    
    var iconName: String { return icon }
    
    init(title: String, value: Int? = nil, icon: String, path: String? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.path = path
    }
}

extension IconStatItemCollectionView.Displayable {
    var value: Int? { return nil }
}

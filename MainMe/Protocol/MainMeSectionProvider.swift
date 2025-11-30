//
//  MainMeSectionProvider.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/30.
//

import UIKit

protocol MainMeSectionProvider: UICollectionViewCell {
    static var identifier: String { get }
    static func shouldDisplay(viewModel: MainMeViewModel) -> Bool
    static func cellHeight(viewModel: MainMeViewModel, width: CGFloat) -> CGFloat
    func configure(with viewModel: MainMeViewModel)
}

protocol MainMeTappableSection: MainMeSectionProvider {
    typealias TapHandler = (String) -> Void
    func configure(with viewModel: MainMeViewModel, onTap: @escaping TapHandler)
}


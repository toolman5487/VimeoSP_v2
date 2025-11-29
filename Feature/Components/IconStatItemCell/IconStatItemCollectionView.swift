//
//  IconStatItemCollectionView.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/23.
//

import Foundation
import UIKit
import SnapKit
import Combine

class IconStatItemCollectionView: UIView {
    
    protocol Displayable {
        var title: String { get }
        var iconName: String { get }
        var path: String? { get }
        var value: Int? { get }
    }
    
    enum LayoutStyle {
        case horizontal
        case grid(columns: Int)
    }
    
    struct Configuration {
        let items: [Displayable]
        let layoutStyle: LayoutStyle
        let itemSize: CGSize?
        let spacing: CGFloat
        let insets: UIEdgeInsets
        
        init(
            items: [Displayable],
            layoutStyle: LayoutStyle,
            itemSize: CGSize? = nil,
            spacing: CGFloat = 12,
            insets: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        ) {
            self.items = items
            self.layoutStyle = layoutStyle
            self.itemSize = itemSize
            self.spacing = spacing
            self.insets = insets
        }
    }
    
    private var configuration: Configuration?
    private var layoutStyle: LayoutStyle = .horizontal
    private let tapSubject = PassthroughSubject<String?, Never>()
    
    var tapPublisher: AnyPublisher<String?, Never> {
        tapSubject.eraseToAnyPublisher()
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(IconStatItemCell.self, forCellWithReuseIdentifier: "IconStatItemCell")
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.cornerRadius = 16
        layer.masksToBounds = true
        clipsToBounds = true
        
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func prepareForReuse() {
        configuration = nil
        collectionView.reloadData()
    }
    
    func configure(with configuration: Configuration) {
        self.configuration = configuration
        self.layoutStyle = configuration.layoutStyle
        
        updateLayout()
        collectionView.reloadData()
    }
    
    static func calculateHeight(for configuration: Configuration, width: CGFloat) -> CGFloat {
        switch configuration.layoutStyle {
        case .horizontal:
            let itemHeight: CGFloat = configuration.itemSize?.height ?? 80
            return itemHeight + configuration.insets.top + configuration.insets.bottom
            
        case .grid(let columns):
            let itemCount = configuration.items.count
            let rows = Int(ceil(Double(itemCount) / Double(columns)))
            let itemHeight: CGFloat = configuration.itemSize?.height ?? 80
            let contentHeight = CGFloat(rows) * itemHeight
            let rowSpacing = configuration.spacing * CGFloat(rows - 1)
            let verticalInsets = configuration.insets.top + configuration.insets.bottom
            return contentHeight + rowSpacing + verticalInsets
        }
    }
    
    private func updateLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        switch layoutStyle {
        case .horizontal:
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = configuration?.spacing ?? 12
            layout.minimumLineSpacing = configuration?.spacing ?? 12
            collectionView.isScrollEnabled = true
            
        case .grid(_):
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = configuration?.spacing ?? 12
            layout.minimumLineSpacing = configuration?.spacing ?? 12
            collectionView.isScrollEnabled = false
        }
        
        layout.sectionInset = configuration?.insets ?? UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

extension IconStatItemCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return configuration?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconStatItemCell", for: indexPath) as! IconStatItemCell
        
        if let item = configuration?.items[indexPath.item] {
            cell.configure(with: item)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let itemSize = configuration?.itemSize {
            return itemSize
        }
        
        switch layoutStyle {
        case .horizontal:
            return CGSize(width: 100, height: 80)
            
        case .grid(let columns):
            let spacing = configuration?.spacing ?? 12
            let insets = configuration?.insets ?? UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            let padding = insets.left + insets.right
            let totalSpacing = spacing * CGFloat(columns - 1)
            let width = (collectionView.frame.width - padding - totalSpacing) / CGFloat(columns)
            return CGSize(width: width, height: 80)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = configuration?.items[indexPath.item] {
            tapSubject.send(item.path)
        }
    }
}


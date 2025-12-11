//
//  BaseMainViewController.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/18.
//

import Foundation
import UIKit
import SnapKit

class BaseMainViewController: UIViewController, AlertPresentable, LoadingPresentable, EmptyStatePresentable, ToastPresentable, Refreshable, KeyboardDismissable {
    
    public let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.vimeoBlack
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.backButtonDisplayMode = .minimal
        setupNavigationBarAppearance()
        setupCollectionView()
        setupRefresh(for: collectionView)
    }
    
    open func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func handleRefresh() {
        endRefreshing()
    }

    open func setupNavigationBarAppearance() {
        guard let navBar = navigationController?.navigationBar else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .vimeoBlue
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.vimeoWhite,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.tintColor = .vimeoWhite
    }
}

extension BaseMainViewController: UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
}

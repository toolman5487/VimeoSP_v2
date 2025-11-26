//
//  MainMeViewController.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/16.
//

import Foundation
import UIKit
import SnapKit
import Combine

class MainMeViewController: BaseMainViewController {
    
    private let viewModel = MainMeViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        bindViewModel()
        viewModel.fetchMe()
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.dataSource = self
    }
    
    private func setupDataSource() {
        collectionView.register(MainMeAvatarCell.self, forCellWithReuseIdentifier: "MainMeAvatarCell")
        collectionView.register(MainMemetadataCell.self, forCellWithReuseIdentifier: "MainMemetadataCell")
        collectionView.register(MainMeEntranceCell.self, forCellWithReuseIdentifier: "MainMeEntranceCell")
    }
    
    private func bindViewModel() {
        viewModel.$meModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] meModel in
                if let meModel = meModel {
                    self?.title = meModel.name
                }
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.item {
        case 0:
            return CGSize(width: collectionView.frame.width, height: MainMeAvatarCell.cellHeight)
        case 1:
            return CGSize(width: collectionView.frame.width, height: MainMemetadataCell.cellHeight)
        case 2:
            return CGSize(width: collectionView.frame.width, height: MainMeEntranceCell.cellHeight)
        default:
            return CGSize(width: collectionView.frame.width, height: 100)
        }
    }
}

extension MainMeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.meModel != nil ? 3 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainMeAvatarCell", for: indexPath) as! MainMeAvatarCell
            cell.configure(with: viewModel)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainMemetadataCell", for: indexPath) as! MainMemetadataCell
            cell.configure(with: viewModel)
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainMeEntranceCell", for: indexPath) as! MainMeEntranceCell
            cell.configure(with: viewModel)
            cell.onItemTapped = { [weak self] path in
                self?.handleEntranceTap(path: path)
            }
            return cell
        default:
            fatalError("Unexpected indexPath")
        }
    }
    
    private func handleEntranceTap(path: String) {
        print("Tapped: \(path)")
    }
}


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
    
    private let allSections: [MainMeSectionProvider.Type] = [
        MainMeAvatarCell.self,
        MainMemetadataCell.self,
        MainMeAdditionalStatsCell.self,
        MainMeEntranceCell.self,
        MainMeContentFilterCell.self
    ]
    
    private var visibleSections: [MainMeSectionProvider.Type] {
        allSections.filter { $0.shouldDisplay(viewModel: viewModel) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        bindViewModel()
        viewModel.fetchMe()
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.dataSource = self
    }
    
    private func registerCells() {
        allSections.forEach { cellType in
            collectionView.register(cellType, forCellWithReuseIdentifier: cellType.identifier)
        }
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
        let cellType = visibleSections[indexPath.item]
        let width = collectionView.frame.width
        let height = cellType.cellHeight(viewModel: viewModel, width: width)
        return CGSize(width: width, height: height)
    }
}

extension MainMeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = visibleSections[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.identifier, for: indexPath)
        
        if let tappableCell = cell as? MainMeTappableSection {
            tappableCell.configure(with: viewModel) { [weak self] path in
                self?.handleTap(path: path)
            }
        } else if let configurableCell = cell as? MainMeSectionProvider {
            configurableCell.configure(with: viewModel)
        }
        
        return cell
    }
    
    private func handleTap(path: String) {
        print("Tapped: \(path)")
    }
}

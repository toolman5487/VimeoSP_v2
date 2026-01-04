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

final class MainMeViewController: BaseMainViewController {
    
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
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.minimumLineSpacing = 0
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
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self, let error = error else { return }
                self.endRefreshing()
                showError(error, title: "Load Error")
            }
            .store(in: &cancellables)
    }
    
    override func handleRefresh() {
        viewModel.refreshMe()
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

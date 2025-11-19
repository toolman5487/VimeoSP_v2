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
    
    private let viewModel = MainMeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Me"
        setupDataSource()
        bindViewModel()
        viewModel.fetchMe()
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.dataSource = self
    }
    
    private func setupDataSource() {
        collectionView.register(MainMeAvartaCell.self, forCellWithReuseIdentifier: "MainMeAvartaCell")
    }
    
    private func bindViewModel() {
        viewModel.$meModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
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
}

extension MainMeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.meModel != nil ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainMeAvartaCell", for: indexPath) as! MainMeAvartaCell
        cell.configure(with: viewModel)
        return cell
    }
}

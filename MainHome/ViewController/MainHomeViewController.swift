//
//  MainHomeViewController.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/16.
//

import Foundation
import UIKit
import SnapKit

class MainHomeViewController: BaseMainViewController {
    
    private enum LogoConfig {
        static let maxWidth: CGFloat = 100
        static let height: CGFloat = 24
        static let imageName = "Vimeo Wordmark_White"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }
    
    private func setupNavBar() {
        setupLogoTitle()
        setupSearchButton()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupLogoTitle() {
        let logoImageView = UIImageView(image: UIImage(named: LogoConfig.imageName))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.clipsToBounds = true
        
        let containerView = UIView()
        containerView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.lessThanOrEqualTo(LogoConfig.maxWidth)
            make.height.equalTo(LogoConfig.height)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
    }
    
    private func setupSearchButton() {
        let config = UIImage.SymbolConfiguration(weight: .black)
        let searchImage = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        
        let searchButton = UIBarButtonItem(
            image: searchImage,
            style: .plain,
            target: self,
            action: #selector(searchButtonTapped)
        )
        searchButton.tintColor = .vimeoWhite
        navigationItem.rightBarButtonItem = searchButton
    }
    
    @objc private func searchButtonTapped() {
        let resultsVC = HomeSearchResultsViewController()
        navigationController?.pushViewController(resultsVC, animated: true)
    }
}

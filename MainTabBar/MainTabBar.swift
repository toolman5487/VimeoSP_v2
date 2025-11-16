//
//  MainTabBar.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/16.
//

import Foundation
import UIKit
import SnapKit

class MainTabBar: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupGlassTabBar()
    }
    
    private func setupTabs() {
        let homeViewController = MainHomeViewController()
        let meViewController = MainMeViewController()

        homeViewController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "video"),
            selectedImage: UIImage(systemName: "video.fill")
        )

        meViewController.tabBarItem = UITabBarItem(
            title: "Me",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        viewControllers = [homeViewController, meViewController]
    }
    
    private func setupGlassTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}

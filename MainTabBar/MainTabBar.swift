//
//  MainTabBar.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/16.
//

import Foundation
import UIKit

private enum MainTab: CaseIterable {
    case home
    case me

    var title: String {
        switch self {
        case .home: return "Home"
        case .me: return "Me"
        }
    }

    var icon: UIImage? {
        switch self {
        case .home: return UIImage(systemName: "video")
        case .me: return UIImage(systemName: "person")
        }
    }

    var selectedIcon: UIImage? {
        switch self {
        case .home: return UIImage(systemName: "video.fill")
        case .me: return UIImage(systemName: "person.fill")
        }
    }

    func makeRootViewController() -> UIViewController {
        switch self {
        case .home:
            return MainHomeViewController()
        case .me:
            return MainMeViewController()
        }
    }
}

class MainTabBar: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupGlassTabBar()
    }
    
    private func setupTabs() {
        let controllers = MainTab.allCases.map { tab -> UIViewController in
            let root = tab.makeRootViewController()
            let nav = UINavigationController(rootViewController: root)
            nav.tabBarItem = UITabBarItem(
                title: tab.title,
                image: tab.icon,
                selectedImage: tab.selectedIcon
            )
            return nav
        }
        
        viewControllers = controllers
    }
    
    private func setupGlassTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.vimeoBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.vimeoBlue
        ]
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = UIColor.vimeoBlue
    }
}

//
//  MainTabBar.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/16.
//

import Foundation
import UIKit

private enum TabBarItemColor {
    case normal
    case selected

    var color: UIColor {
        switch self {
        case .normal: return UIColor.vimeoWhite
        case .selected: return UIColor.vimeoBlue
        }
    }
}

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
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        appearance.stackedLayoutAppearance.normal.iconColor = TabBarItemColor.normal.color
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: TabBarItemColor.normal.color
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = TabBarItemColor.selected.color
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: TabBarItemColor.selected.color
        ]
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = TabBarItemColor.selected.color
    }
}

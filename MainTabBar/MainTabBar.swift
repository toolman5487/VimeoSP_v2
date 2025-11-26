//
//  MainTabBar.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/16.
//

import Foundation
import UIKit
import Combine
import SDWebImage

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
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupGlassTabBar()
        observeUserAvatar()
    }
    
    private func setupTabs() {
        let controllers = MainTab.allCases.map { tab -> UIViewController in
            let root = tab.makeRootViewController()
            let nav = UINavigationController(rootViewController: root)
            nav.navigationBar.prefersLargeTitles = true
            nav.tabBarItem = UITabBarItem(
                title: tab.title,
                image: tab.icon,
                selectedImage: tab.selectedIcon
            )
            return nav
        }
        
        viewControllers = controllers
    }
    
    private func observeUserAvatar() {
        MainMeViewModel.shared.$meModel
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] meModel in
                self?.updateMeTabIcon(with: meModel)
            }
            .store(in: &cancellables)
    }
    
    private func updateMeTabIcon(with meModel: MainMeModel) {
        guard let meTabIndex = MainTab.allCases.firstIndex(of: .me),
              let viewControllers = viewControllers,
              meTabIndex < viewControllers.count,
              let imageURL = MainMeViewModel.shared.getAvatarImageURL(size: .size30),
              let url = URL(string: imageURL) else {
            return
        }
        
        let meTabBarItem = viewControllers[meTabIndex].tabBarItem
        let name = meModel.name
        meTabBarItem?.title = name
        
        SDWebImageManager.shared.loadImage(
            with: url,
            options: [],
            progress: nil
        ) { [weak self] image, _, error, _, _, _ in
            guard let self = self,
                  let image = image,
                  error == nil else {
                return
            }
            
            let circularImage = self.createCircularTabBarIcon(from: image)
            
            DispatchQueue.main.async {
                meTabBarItem?.image = circularImage?.withRenderingMode(.alwaysOriginal)
                meTabBarItem?.selectedImage = circularImage?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    private func createCircularTabBarIcon(from image: UIImage) -> UIImage? {
        let size: CGFloat = 30
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.addEllipse(in: rect)
        context.clip()
        
        image.draw(in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
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

//
//  ViewController.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/16.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Vimeo Wordmark_Black")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLogo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTransitionTimer()
    }

    private func setupLogo() {
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(240)
        }
    }

    private func startTransitionTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.goToMainTabBar()
        }
    }

    private func goToMainTabBar() {
        let mainTabBar = MainTabBar()
        guard let window = view.window else {
            navigationController?.setViewControllers([mainTabBar], animated: true)
            return
        }

        UIView.transition(with: window,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
            self?.navigationController?.setViewControllers([mainTabBar], animated: false)
        })
    }


}


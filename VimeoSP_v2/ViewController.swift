//
//  ViewController.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/16.
//

import UIKit
import SnapKit
import QuartzCore

final class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Vimeo Wordmark_White")
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 1.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var transitionTimer: DispatchWorkItem?
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLogo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRotationAnimation()
        startTransitionTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelTransitionTimer()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupLogo() {
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(200)
        }
    }
    
    // MARK: - Animation
    
    private func startRotationAnimation() {
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotation.values = [0, Double.pi * 2 * 3, Double.pi * 2 * 3]
        rotation.keyTimes = [0, 0.75, 1.0]
        rotation.duration = 1
        rotation.repeatCount = .greatestFiniteMagnitude
        rotation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        imageView.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    private func stopRotationAnimation() {
        imageView.layer.removeAnimation(forKey: "rotationAnimation")
    }
    
    // MARK: - Navigation
    
    private func startTransitionTimer() {
        cancelTransitionTimer()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.transitionToMainTabBar()
        }
        
        transitionTimer = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
    }
    
    private func cancelTransitionTimer() {
        transitionTimer?.cancel()
        transitionTimer = nil
    }
    
    private func transitionToMainTabBar() {
        stopRotationAnimation()
        
        let mainTabBar = MainTabBar()
        
        guard let window = view.window else {
            navigationController?.setViewControllers([mainTabBar], animated: true)
            return
        }
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.imageView.alpha = 0.0
            },
            completion: { _ in
                UIView.transition(
                    with: window,
                    duration: 0.2,
                    options: .transitionCrossDissolve,
                    animations: {
                        self.navigationController?.setViewControllers([mainTabBar], animated: false)
                    }
                )
            }
        )
    }
}


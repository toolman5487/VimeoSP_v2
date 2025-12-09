//
//  VideoPlayerViewController.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/8.
//

import Foundation
import UIKit
import SnapKit
import SDWebImage
import Combine

class VideoPlayerViewController: BaseMainViewController {
    
    private let viewModel: VideoPlayerViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(videoId: String) {
        self.viewModel = VideoPlayerViewModel()
        super.init(nibName: nil, bundle: nil)
        viewModel.fetchVideo(videoId: videoId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.$videoModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] videoModel in
                if let videoModel = videoModel {
                    self?.title = videoModel.name
                }
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self, let error = error else { return }
                ErrorAlert.show(
                    from: self,
                    errorMessage: viewModel.errorMessage
                )
            }
            .store(in: &cancellables)
    }
}

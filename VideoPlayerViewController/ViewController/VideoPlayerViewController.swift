//
//  VideoPlayerViewController.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/8.
//

import Foundation
import UIKit
import SnapKit
import Combine

final class VideoPlayerViewController: UIViewController, AlertPresentable, LoadingPresentable {
    
    private enum Section: Int, CaseIterable {
        case info
        case stats
        case description
    }
    
    private let viewModel: VideoPlayerViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let videoPlayerView = VideoPlayerView()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .vimeoBlack
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    
    private var infoHeaderCell: VideoInfoHeaderCell?
    private var statsCell: VideoStatsCell?
    private var descriptionCell: VideoDescriptionCell?
    
    init(videoId: String) {
        self.viewModel = VideoPlayerViewModel()
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
        viewModel.fetchVideo(videoId: videoId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTableView()
        setupBindings()
    }
    
    private func setupViews() {
        view.backgroundColor = .vimeoBlack
        
        view.addSubview(videoPlayerView)
        view.addSubview(tableView)
        
        videoPlayerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(videoPlayerView.snp.width).multipliedBy(9.0 / 16.0)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(videoPlayerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(VideoInfoHeaderCell.self, forCellReuseIdentifier: "VideoInfoHeaderCell")
        tableView.register(VideoStatsCell.self, forCellReuseIdentifier: "VideoStatsCell")
        tableView.register(VideoDescriptionCell.self, forCellReuseIdentifier: "VideoDescriptionCell")
    }
    
    private func setupBindings() {
        viewModel.$videoModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] videoModel in
                guard let self, let videoModel = videoModel else { return }
                self.updateUI(with: videoModel)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self, let _ = error else { return }
                self.showError(message: viewModel.errorMessage)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with video: VideoPlayerModel) {
        if let videoId = video.videoId {
            videoPlayerView.configure(videoId: videoId, thumbnailURL: video.thumbnailURL)
        }
        
        tableView.reloadData()
    }
    
    private func handleLike() {
        print("Like tapped")
    }
    
    private func handleShare() {
        guard let video = viewModel.videoModel,
              let urlString = video.link,
              let url = URL(string: urlString) else { return }
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    private func handleSave() {
        print("Save tapped")
    }
}

extension VideoPlayerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.row),
              let video = viewModel.videoModel else {
            return UITableViewCell()
        }
        
        switch section {
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoInfoHeaderCell", for: indexPath) as! VideoInfoHeaderCell
            cell.configure(with: video)
            cell.onLikeTapped = { [weak self] in self?.handleLike() }
            cell.onShareTapped = { [weak self] in self?.handleShare() }
            cell.onSaveTapped = { [weak self] in self?.handleSave() }
            infoHeaderCell = cell
            return cell
            
        case .stats:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoStatsCell", for: indexPath) as! VideoStatsCell
            cell.configure(with: video)
            statsCell = cell
            return cell
            
        case .description:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoDescriptionCell", for: indexPath) as! VideoDescriptionCell
            cell.configure(with: video)
            cell.onExpandToggle = { [weak self] isExpanded in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            descriptionCell = cell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

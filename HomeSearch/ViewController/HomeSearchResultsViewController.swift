//
//  HomeSearchResultsViewController.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/1.
//

import Foundation
import UIKit
import SnapKit
import Combine
import SDWebImage

final class HomeSearchResultsViewController: UIViewController, AlertPresentable {
    
    // MARK: - Constants
    
    private enum Constants {
        static let cellHeight: CGFloat = 120
        static let loadMoreThreshold: CGFloat = 200
        static let footerHeight: CGFloat = 60
        static let emptyStateInset: CGFloat = 40
        static let separatorInset: CGFloat = 20
    }
    
    // MARK: - Properties
    
    private let viewModel = HomeSearchViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let footerLoadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.returnKeyType = .search
        searchBar.accessibilityLabel = "Search"
        searchBar.accessibilityHint = "Enter search terms to find videos, users, and channels"
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .vimeoBlack
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray.withAlphaComponent(0.3)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: Constants.separatorInset, bottom: 0, right: 0)
        tableView.alwaysBounceVertical = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        view.isAccessibilityElement = true
        return view
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter a search term to find videos, users, channels, and more"
        label.textColor = .vimeoWhite.withAlphaComponent(0.6)
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .vimeoBlack
        setupSearchBar()
        setupViews()
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Setup Methods
    
    private func setupSearchBar() {
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        searchBar.searchTextField.textColor = .systemBackground
        searchBar.searchTextField.backgroundColor = .label
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search videos, users, channels...",
            attributes: [.foregroundColor: UIColor.darkGray.withAlphaComponent(0.5)]
        )
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateView)
        
        setupTableView()
        setupLoadingIndicator()
        setupEmptyStateView()
    }
    
    private func setupTableView() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: String(describing: SearchResultCell.self))
        setupFooterLoadingView()
    }
    
    private func setupFooterLoadingView() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Constants.footerHeight))
        footer.backgroundColor = .clear
        
        footer.addSubview(footerLoadingIndicator)
        footerLoadingIndicator.color = .vimeoBlue
        footerLoadingIndicator.hidesWhenStopped = true
        footerLoadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        tableView.tableFooterView = footer
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.color = .vimeoBlue
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupEmptyStateView() {
        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Constants.emptyStateInset)
        }
        
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        viewModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                if isLoading && viewModel.searchResults.isEmpty {
                    loadingIndicator.startAnimating()
                    UIAccessibility.post(notification: .announcement, argument: "Loading search results")
                } else {
                    loadingIndicator.stopAnimating()
                }
                updateEmptyState()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoadingMore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoadingMore in
                if isLoadingMore {
                    self?.footerLoadingIndicator.startAnimating()
                } else {
                    self?.footerLoadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self, let error = error else { return }
                showError(
                    error,
                    title: "Search Error",
                    retryAction: { [weak self] in
                        guard let self, !viewModel.currentQuery.isEmpty else { return }
                        viewModel.search(query: viewModel.currentQuery, type: .videos)
                    }
                )
            }
            .store(in: &cancellables)
    }
    
    // MARK: - State Updates
    
    private func updateEmptyState() {
        let isEmpty = viewModel.searchResults.isEmpty && !viewModel.isLoading && !viewModel.isLoadingMore && !viewModel.currentQuery.isEmpty
        emptyStateView.isHidden = !isEmpty
        
        if isEmpty {
            let message = "No results found for \"\(viewModel.currentQuery)\""
            emptyStateLabel.text = message
            emptyStateView.accessibilityLabel = message
        } else if viewModel.currentQuery.isEmpty {
            let message = "Enter a search term to find videos, users, channels, and more"
            emptyStateLabel.text = message
            emptyStateView.accessibilityLabel = message
        }
    }
    
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension HomeSearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchResultCell.self), for: indexPath) as? SearchResultCell else {
            return UITableViewCell()
        }
        let video = viewModel.searchResults[indexPath.row]
        cell.configure(with: video)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let video = viewModel.searchResults[indexPath.row]
        guard let videoURL = viewModel.getVideoURL(for: video) else { return }
        let videoPlayerViewController = VideoPlayerViewController(videoURL: videoURL)
        navigationController?.pushViewController(videoPlayerViewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - Constants.loadMoreThreshold {
            if viewModel.hasMorePages && !viewModel.isLoading && !viewModel.isLoadingMore {
                viewModel.loadMore()
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension HomeSearchResultsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchQuery = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        searchBar.resignFirstResponder()
        viewModel.search(query: query, type: .videos)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: true)
    }
}

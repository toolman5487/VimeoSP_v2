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
    
    // MARK: - Properties
    
    private let viewModel = HomeSearchViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
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
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
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
        navigationItem.largeTitleDisplayMode = .never
        
        searchBar.searchTextField.textColor = .systemBackground
        searchBar.searchTextField.backgroundColor = .label
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search videos, users, channels...",
            attributes: [.foregroundColor: UIColor.darkGray.withAlphaComponent(0.5)]
        )
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        setupTableView()
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
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
        footer.backgroundColor = .clear
        
        footer.addSubview(footerLoadingIndicator)
        footerLoadingIndicator.color = .vimeoBlue
        footerLoadingIndicator.hidesWhenStopped = true
        footerLoadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        tableView.tableFooterView = footer
    }
    
    private func setupEmptyStateView() {
        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        Publishers.CombineLatest(viewModel.$searchResults, viewModel.$isLoading)
            .receive(on: DispatchQueue.main)
            .removeDuplicates { prev, next in
                prev.0.count == next.0.count && prev.1 == next.1
            }
            .sink { [weak self] _, _ in
                self?.tableView.reloadData()
                self?.updateEmptyState()
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
        if viewModel.isLoading && viewModel.searchResults.isEmpty {
            return 10
        }
        return viewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchResultCell.self), for: indexPath) as? SearchResultCell else {
            return UITableViewCell()
        }
        
        if !viewModel.isLoading && indexPath.row < viewModel.searchResults.count {
            let video = viewModel.searchResults[indexPath.row]
            cell.configure(with: video)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let searchCell = cell as? SearchResultCell,
           viewModel.isLoading && viewModel.searchResults.isEmpty {
            searchCell.showSkeleton()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
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
        
        if offsetY > contentHeight - height - 200 {
            if viewModel.hasMorePages && !viewModel.isLoading && !viewModel.isLoadingMore {
                viewModel.loadMore()
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension HomeSearchResultsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.clearSearch()
        } else {
            viewModel.searchQuery = searchText
        }
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

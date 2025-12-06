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

class HomeSearchResultsViewController: UIViewController {
    
    private let viewModel = HomeSearchViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let footerLoadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private let searchBar = UISearchBar()
    
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
        return view
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter a search term to find videos, users, channels, and more"
        label.textColor = .vimeoWhite.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
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
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.returnKeyType = .search
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
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: "SearchResultCell")
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
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
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
                if let error = error {
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateEmptyState() {
        let isEmpty = viewModel.searchResults.isEmpty && !viewModel.isLoading && !viewModel.isLoadingMore && !viewModel.currentQuery.isEmpty
        emptyStateView.isHidden = !isEmpty
        
        if isEmpty {
            emptyStateLabel.text = "No results found for \"\(viewModel.currentQuery)\""
        } else if viewModel.currentQuery.isEmpty {
            emptyStateLabel.text = "Enter a search term to find videos, users, channels, and more"
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Search Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension HomeSearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        let video = viewModel.searchResults[indexPath.row]
        cell.configure(with: video)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let video = viewModel.searchResults[indexPath.row]
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

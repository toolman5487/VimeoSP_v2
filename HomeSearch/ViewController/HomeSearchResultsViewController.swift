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
    private var searchSubject = PassthroughSubject<String, Never>()
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
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
        searchBar.placeholder = "Search videos, users, channels..."
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.returnKeyType = .search
        navigationItem.titleView = searchBar
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .vimeoWhite
            textField.backgroundColor = UIColor.vimeoWhite.withAlphaComponent(0.1)
        }
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
        tableView.backgroundColor = .vimeoBlack
        tableView.separatorStyle = .none
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: "SearchResultCell")
        
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        footer.backgroundColor = .clear
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
        searchSubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self = self else { return }
                if query.isEmpty {
                    self.viewModel.clearSearch()
                } else {
                    self.viewModel.search(query: query, type: .videos)
                }
            }
            .store(in: &cancellables)
        
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
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
                self?.updateEmptyState()
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
        let isEmpty = viewModel.searchResults.isEmpty && !viewModel.isLoading && !viewModel.currentQuery.isEmpty
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
            if viewModel.hasMorePages && !viewModel.isLoading {
                viewModel.loadMore()
            }
        }
    }
}

extension HomeSearchResultsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchSubject.send(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        searchBar.resignFirstResponder()
        searchSubject.send(query)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: true)
    }
}

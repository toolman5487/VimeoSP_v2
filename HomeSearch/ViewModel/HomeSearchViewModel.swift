//
//  HomeSearchViewModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/3.
//

import Foundation
import Combine

final class HomeSearchViewModel {
    
    // MARK: - Published Properties
    
    @Published private(set) var searchResults: [VimeoVideo] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var error: Error?
    @Published private(set) var currentQuery = ""
    @Published private(set) var hasMorePages = false
    @Published var searchQuery = ""
    
    // MARK: - Private Properties
    
    private let service: HomeSearchServiceProtocol
    private let perPage = 10
    private var cancellables = Set<AnyCancellable>()
    private var searchCancellable: AnyCancellable?
    private var currentType: SearchPath = .videos
    private var currentPage = 1
    private var total = 0
    private var searchCache: [String: [VimeoVideo]] = [:]
    
    // MARK: - Initialization
    
    init(service: HomeSearchServiceProtocol = HomeSearchService()) {
        self.service = service
        setupSearchQueryBinding()
    }
    
    // MARK: - Public Methods
    
    func search(query: String, type: SearchPath = .videos) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        searchCancellable?.cancel()
        
        currentQuery = query
        currentType = type
        currentPage = 1
        searchResults = []
        isLoading = true
        error = nil
        
        searchCancellable = service.search(query: query, type: type, page: currentPage, perPage: perPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self else { return }
                    searchResults = response.data ?? []
                    total = response.total ?? 0
                    hasMorePages = checkHasMorePages(response: response)
                }
            )
    }
    
    func loadMore() {
        guard !isLoading, !isLoadingMore, hasMorePages, !currentQuery.isEmpty else { return }
        
        isLoadingMore = true
        let nextPage = currentPage + 1
        
        service.search(query: currentQuery, type: currentType, page: nextPage, perPage: perPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingMore = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self else { return }
                    if let newData = response.data {
                        searchResults.append(contentsOf: newData)
                    }
                    currentPage = nextPage
                    hasMorePages = checkHasMorePages(response: response)
                }
            )
            .store(in: &cancellables)
    }
    
    func clearSearch() {
        searchResults = []
        currentQuery = ""
        currentPage = 1
        total = 0
        hasMorePages = false
        isLoadingMore = false
        error = nil
    }
    
    // MARK: - Private Methods
    
    private func setupSearchQueryBinding() {
        $searchQuery
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                searchCancellable?.cancel()
                
                if query.isEmpty {
                    clearSearch()
                    return
                }
                
                currentQuery = query
                currentType = .videos
                currentPage = 1
                
                if let cachedResults = searchCache[query] {
                    searchResults = cachedResults
                    isLoading = false
                    total = cachedResults.count
                    hasMorePages = false
                    return
                }
                
                isLoading = true
                error = nil
                
                searchCancellable = service.search(query: query, type: .videos, page: 1, perPage: perPage)
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: { [weak self] completion in
                            self?.isLoading = false
                            if case .failure(let error) = completion {
                                self?.error = error
                            }
                        },
                        receiveValue: { [weak self] response in
                            guard let self else { return }
                            let results = response.data ?? []
                            searchResults = results
                            total = response.total ?? 0
                            hasMorePages = checkHasMorePages(response: response)
                            
                            if searchCache.count >= 10, let firstKey = searchCache.keys.first {
                                searchCache.removeValue(forKey: firstKey)
                            }
                            searchCache[query] = results
                        }
                    )
            }
            .store(in: &cancellables)
    }
    
    private func checkHasMorePages(response: VimeoSearchResponse) -> Bool {
        guard let page = response.page,
              let perPage = response.perPage,
              let total = response.total else {
            return false
        }
        return (page * perPage) < total
    }
}

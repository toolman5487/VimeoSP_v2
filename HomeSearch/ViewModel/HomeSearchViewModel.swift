//
//  HomeSearchViewModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/3.
//

import Foundation
import Combine

final class HomeSearchViewModel: BaseViewModel {
    
    // MARK: - Constants
    
    private enum Constants {
        static let debounceMilliseconds = 200
        static let perPage = 10
        static let maxCacheSize = 10
    }
    
    // MARK: - Published Properties
    
    @Published private(set) var searchResults: [VimeoVideo] = []
    @Published private(set) var isLoadingMore = false
    @Published private(set) var currentQuery = ""
    @Published private(set) var hasMorePages = false
    @Published var searchQuery = ""
    
    // MARK: - Private Properties
    
    private let service: HomeSearchServiceProtocol
    private var searchCancellable: AnyCancellable?
    private var currentType: SearchPath = .videos
    private var currentPage = 1
    private var total = 0
    private var searchCache: [String: [VimeoVideo]] = [:]
    
    // MARK: - Initialization
    
    init(service: HomeSearchServiceProtocol = HomeSearchService()) {
        self.service = service
        super.init()
        setupSearchQueryBinding()
    }
    
    // MARK: - Public Methods
    
    func search(query: String, type: SearchPath = .videos) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        searchCancellable?.cancel()
        resetSearchState(query: query, type: type)
        isLoading = true
        
        performSearch(query: query, type: type, page: 1, shouldCache: false)
    }
    
    func loadMore() {
        guard canLoadMore else { return }
        
        isLoadingMore = true
        let nextPage = currentPage + 1
        
        service.search(query: currentQuery, type: currentType, page: nextPage, perPage: Constants.perPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingMore = false
                    self?.handleCompletion(completion)
                },
                receiveValue: { [weak self] response in
                    self?.handleLoadMoreResponse(response, nextPage: nextPage)
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
        resetError()
    }
    
    // MARK: - Private Computed Properties
    
    private var canLoadMore: Bool {
        !isLoading && !isLoadingMore && hasMorePages && !currentQuery.isEmpty
    }
    
    // MARK: - Private Methods
    
    private func setupSearchQueryBinding() {
        $searchQuery
            .debounce(for: .milliseconds(Constants.debounceMilliseconds), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.handleSearchQueryChange(query)
            }
            .store(in: &cancellables)
    }
    
    private func handleSearchQueryChange(_ query: String) {
        searchCancellable?.cancel()
        
        if query.isEmpty {
            clearSearch()
            return
        }
        
        resetSearchState(query: query, type: .videos)
        
        if let cachedResults = searchCache[query] {
            applyCachedResults(cachedResults)
            return
        }
        
        isLoading = true
        resetError()
        
        performSearch(query: query, type: .videos, page: 1, shouldCache: true)
    }
    
    private func resetSearchState(query: String, type: SearchPath) {
        currentQuery = query
        currentType = type
        currentPage = 1
        searchResults = []
        resetError()
    }
    
    private func performSearch(query: String, type: SearchPath, page: Int, shouldCache: Bool) {
        let cacheKey = shouldCache ? query : nil
        searchCancellable = service.search(query: query, type: type, page: page, perPage: Constants.perPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.handleCompletion(completion)
                },
                receiveValue: { [weak self] response in
                    self?.handleSearchResponse(response, cacheKey: cacheKey)
                }
            )
    }
    
    private func handleSearchResponse(_ response: VimeoSearchResponse, cacheKey: String?) {
        let results = response.data ?? []
        searchResults = results
        total = response.total ?? 0
        hasMorePages = checkHasMorePages(response: response)
        
        if let cacheKey {
            cacheResults(results, forKey: cacheKey)
        }
    }
    
    private func handleLoadMoreResponse(_ response: VimeoSearchResponse, nextPage: Int) {
        if let newData = response.data {
            searchResults.append(contentsOf: newData)
        }
        currentPage = nextPage
        hasMorePages = checkHasMorePages(response: response)
    }
    
    private func applyCachedResults(_ results: [VimeoVideo]) {
        searchResults = results
        isLoading = false
        total = results.count
        hasMorePages = results.count >= Constants.perPage
    }
    
    private func cacheResults(_ results: [VimeoVideo], forKey key: String) {
        if searchCache.count >= Constants.maxCacheSize, let firstKey = searchCache.keys.first {
            searchCache.removeValue(forKey: firstKey)
        }
        searchCache[key] = results
    }
    
    private func checkHasMorePages(response: VimeoSearchResponse) -> Bool {
        guard let page = response.page,
              let perPage = response.perPage,
              let total = response.total else {
            return false
        }
        return (page * perPage) < total
    }
    
    func getVideoURL(for video: VimeoVideo) -> String? {
        guard let videoId = video.videoId else { return nil }
        return URLConfig.frontendBaseURL.appendingPathComponent(videoId).absoluteString
    }
}

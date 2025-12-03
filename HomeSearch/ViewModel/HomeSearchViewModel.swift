//
//  HomeSearchViewModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/3.
//

import Foundation
import Combine

class HomeSearchViewModel {
    
    private let service: HomeSearchServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var searchResults: [VimeoVideo] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentQuery: String = ""
    @Published var currentType: SearchPath = .videos
    @Published var currentPage: Int = 1
    @Published var total: Int = 0
    @Published var hasMorePages: Bool = false
    
    private let perPage: Int = 20
    
    init(service: HomeSearchServiceProtocol = HomeSearchService()) {
        self.service = service
    }
    
    func search(query: String, type: SearchPath = .videos) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        currentQuery = query
        currentType = type
        currentPage = 1
        searchResults = []
        isLoading = true
        error = nil
        
        service.search(query: query, type: type, page: currentPage, perPage: perPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    self.searchResults = response.data ?? []
                    self.total = response.total ?? 0
                    self.hasMorePages = self.checkHasMorePages(response: response)
                }
            )
            .store(in: &cancellables)
    }
    
    func loadMore() {
        guard !isLoading && hasMorePages && !currentQuery.isEmpty else { return }
        
        isLoading = true
        let nextPage = currentPage + 1
        
        service.search(query: currentQuery, type: currentType, page: nextPage, perPage: perPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    if let newData = response.data {
                        self.searchResults.append(contentsOf: newData)
                    }
                    self.currentPage = nextPage
                    self.hasMorePages = self.checkHasMorePages(response: response)
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
        error = nil
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

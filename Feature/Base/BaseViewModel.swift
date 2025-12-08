//
//  BaseViewModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/8.
//

import Foundation
import Combine

class BaseViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isLoading = false
    @Published var error: Error?
    
    // MARK: - Internal Properties
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Public Methods
    
    func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        isLoading = false
        if case .failure(let err) = completion {
            error = err
        }
    }
    
    func resetError() {
        error = nil
    }
    
    // MARK: - Computed Properties
    
    var errorMessage: String? {
        guard let error = error else { return nil }
        
        if let apiError = error as? APIError {
            return apiError.localizedDescription
        }
        
        return error.localizedDescription
    }
    
    var hasError: Bool {
        error != nil
    }
    
    // MARK: - Deinitialization
    
    deinit {
        cancellables.removeAll()
    }
}

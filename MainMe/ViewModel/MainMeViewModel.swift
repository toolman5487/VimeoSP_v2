//
//  MainMeViewModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/18.
//

import Foundation
import Combine

class MainMeViewModel {
    
    private let service: MainMeServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var meModel: MainMeModel?
    @Published var isLoading = false
    @Published var error: Error?
    
    init(service: MainMeServiceProtocol = MainMeService()) {
        self.service = service
    }
    
    func fetchMe() {
        isLoading = true
        error = nil
        
        service.fetchMe()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] meModel in
                    self?.meModel = meModel
                }
            )
            .store(in: &cancellables)
    }
}

//
//  MainMeViewModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/18.
//

import Foundation
import Combine

enum PictureSizeType: Int, CaseIterable {
    case size30 = 30
    case size72 = 72
    case size75 = 75
    case size100 = 100
    case size144 = 144
    case size216 = 216
    case size288 = 288
    case size300 = 300
    case size360 = 360
}

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
    
    func getAvatarImageURL(size: PictureSizeType) -> String? {
        guard let pictures = meModel?.pictures else { return nil }
        
        if let targetSize = pictures.sizes.first(where: { $0.width == size.rawValue }) {
            return targetSize.link
        }
        
        let sortedSizes = pictures.sizes.sorted { $0.width < $1.width }
        if size.rawValue < sortedSizes.first?.width ?? 0 {
            return sortedSizes.first?.link
        }
        if size.rawValue > sortedSizes.last?.width ?? 0 {
            return sortedSizes.last?.link
        }
        
        let closestSize = sortedSizes.min { abs($0.width - size.rawValue) < abs($1.width - size.rawValue) }
        return closestSize?.link ?? pictures.baseLink
    }
}

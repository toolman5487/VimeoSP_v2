//
//  HomeSearchSearvice.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/3.
//

import Foundation
import Combine

protocol HomeSearchServiceProtocol {
    func search(query: String, type: SearchPath, page: Int?, perPage: Int?) -> AnyPublisher<VimeoSearchResponse, Error>
}

class HomeSearchService: HomeSearchServiceProtocol {
    
    func search(query: String, type: SearchPath, page: Int? = nil, perPage: Int? = nil) -> AnyPublisher<VimeoSearchResponse, Error> {
        return Future { promise in
            guard !query.isEmpty else {
                promise(.failure(APIError.invalidResponse))
                return
            }
            
            var parameters: [String: Any] = [
                "query": query
            ]
            
            if let page = page {
                parameters["page"] = page
            }
            
            if let perPage = perPage {
                parameters["per_page"] = perPage
            }
            
            APIConfig.APIGET(path: type.path, parameters: parameters) { result in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let searchResponse = try decoder.decode(VimeoSearchResponse.self, from: data)
                        promise(.success(searchResponse))
                    } catch {
                        promise(.failure(APIError.decodingError(error)))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

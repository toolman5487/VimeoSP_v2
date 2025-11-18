//
//  MainMeService.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/18.
//

import Foundation
import Combine

protocol MainMeServiceProtocol {
    func fetchMe() -> AnyPublisher<MainMeModel, Error>
}

class MainMeService: MainMeServiceProtocol {
    
    func fetchMe() -> AnyPublisher<MainMeModel, Error> {
        return Future { promise in
            APIConfig.APIGET(path: MePath.me.path) { result in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let meModel = try decoder.decode(MainMeModel.self, from: data)
                        promise(.success(meModel))
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

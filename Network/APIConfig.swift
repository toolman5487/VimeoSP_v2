//
//  APIConfig.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/16.
//

import Foundation
import Alamofire

enum APIError: Error {
    case networkError(Error)
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .networkError(let error):
            return "Network connection error: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let statusCode, let message):
            return "HTTP error \(statusCode): \(message ?? "Unknown error")"
        case .decodingError(let error):
            return "Data decoding error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized, please login again"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error, please try again later"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
    
    static func from(_ error: AFError) -> APIError {
        switch error {
        case .invalidURL:
            return .invalidURL
        case .responseValidationFailed(let reason):
            switch reason {
            case .unacceptableStatusCode(let code):
                switch code {
                case 401:
                    return .unauthorized
                case 403:
                    return .forbidden
                case 404:
                    return .notFound
                case 500...599:
                    return .serverError
                default:
                    return .httpError(statusCode: code, message: nil)
                }
            default:
                return .invalidResponse
            }
        case .responseSerializationFailed:
            return .decodingError(error)
        case .sessionTaskFailed(let error):
            return .networkError(error)
        default:
            return .unknown(error)
        }
    }
}

struct APIConfig {
    private static var headers: HTTPHeaders {
        var headers = HTTPHeaders()
        headers["Authorization"] = "Bearer \(URLConfig.token)"
        headers["Accept"] = "application/vnd.vimeo.*+json;version=3.4"
        return headers
    }
    
    static func APIGET(
        path: String,
        parameters: Parameters? = nil,
        completion: @escaping (Result<Data, APIError>) -> Void
    ) {
        let url = URLConfig.baseURL.appendingPathComponent(path)
        AF.request(url, method: .get, parameters: parameters, headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(APIError.from(error)))
                }
            }
    }
    
    static func APIPOST(
        path: String,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        completion: @escaping (Result<Data, APIError>) -> Void
    ) {
        let url = URLConfig.baseURL.appendingPathComponent(path)
        AF.request(url, method: .post, parameters: parameters, encoding: encoding, headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(APIError.from(error)))
                }
            }
    }
    
    static func APIPATCH(
        path: String,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        completion: @escaping (Result<Data, APIError>) -> Void
    ) {
        let url = URLConfig.baseURL.appendingPathComponent(path)
        AF.request(url, method: .patch, parameters: parameters, encoding: encoding, headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(APIError.from(error)))
                }
            }
    }
    
    static func APIPUT(
        path: String,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        completion: @escaping (Result<Data, APIError>) -> Void
    ) {
        let url = URLConfig.baseURL.appendingPathComponent(path)
        AF.request(url, method: .put, parameters: parameters, encoding: encoding, headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(APIError.from(error)))
                }
            }
    }
    
    static func APIDELETE(
        path: String,
        parameters: Parameters? = nil,
        completion: @escaping (Result<Data, APIError>) -> Void
    ) {
        let url = URLConfig.baseURL.appendingPathComponent(path)
        AF.request(url, method: .delete, parameters: parameters, headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(APIError.from(error)))
                }
            }
    }
}

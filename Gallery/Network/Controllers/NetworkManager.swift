//
//  NetworkManager.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/8/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

enum NetworkResult<ParsetData> {
	case success(parsetData: ParsetData)
	case failure(String)
}

class NetworkManager {
	
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    deinit {
        cancelAllRequests()
    }
    
    private var tasks: [URL: URLSessionDataTask] = [:]
	
	func performRequest<T: NetworkRequest>(_ request: T,
									 completionHandler: @escaping (NetworkResult<T.Model>) -> Void) {

		guard let url = request.urlRequest.url, tasks[url] == nil else { return }

		let dataTask = session.dataTask(with: request.urlRequest) { [weak self] (data, response, error) in
			DispatchQueue.main.async { self?.tasks[url] = nil }
			
			if let data = data, let response = response,
				let parsedData = request.decode(data, response: response) {
				
				completionHandler(.success(parsetData: parsedData))
			} else {
				let message = self?.parseErrorMessage(from: data, error: error) ?? "Occurred unknown error"
				completionHandler(.failure(message))
			}
		}
		tasks[url] = dataTask
		dataTask.resume()
	}
	
    func cancel<T: NetworkRequest>(_ request: T) {
        if let url = request.urlRequest.url, let task = tasks[url] {
            task.cancel()
        }
    }
    
    private func cancelAllRequests() {
        tasks.forEach { $1.cancel() }
    }
	
	private func parseErrorMessage(from data: Data?, error: Error?) -> String? {
		var message = error?.localizedDescription
		if let dataString = data, let errorString = String(data: dataString, encoding: .utf8) {
			message = errorString
		}
		return message
	}
}

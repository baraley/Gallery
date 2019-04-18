//
//  NetworkManager.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/8/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class NetworkManager {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    deinit {
        cancelAllRequests()
    }
    
    private var tasks: [URL: URLSessionDataTask] = [:]
    
    func loadData<T: NetworkRequest>(from request: T,
									 success: @escaping (T.Model) -> Void,
                                     failure: @escaping (String) -> Void) {
		
        guard let url = request.urlRequest.url, tasks[url] == nil else { return }
		
        let dataTask = session.dataTask(with: request.urlRequest) { (data, response, error) in
            self.tasks[url] = nil
			
			if let data = data, let decodedData = request.decode(data, response: response) {
				DispatchQueue.main.async {
					success(decodedData)
				}
			} else {
				var message = error?.localizedDescription ?? "Occurred unknown error"
				if let dataString = data, let errorString = String(data: dataString, encoding: .utf8) {
					message = errorString
				}
				
				DispatchQueue.main.async {
					failure(message)
				}
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
}

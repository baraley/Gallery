//
//  AppDelegate.swift
//  Gallery
//
//  Created by Alexander Baraley on 5/26/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
				
		setupCacheCapacity()
        setupHomeViewController()
        
		return true
	}
	
	private func setupHomeViewController() {
		let networkManager = NetworkRequestPerformer(session: URLSession.shared)
		let authorizationManager = AuthorizationManager(networkManager: networkManager)
		
		if let navController = window?.rootViewController as? UINavigationController,
			let homeViewController = navController.viewControllers.first as? HomeViewController {
		
			homeViewController.authorizationManager = authorizationManager
		}
	}
	
	private func setupCacheCapacity() {
		let memoryCapacity = 50 * 1024 * 1024
		let diskCapacity = 300 * 1024 * 1024
		URLCache.shared.memoryCapacity = memoryCapacity
		URLCache.shared.diskCapacity =  diskCapacity
//        URLCache.shared.removeAllCachedResponses()
	}
}


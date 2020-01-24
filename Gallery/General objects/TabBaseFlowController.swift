//
//  TabBaseFlowController.swift
//  Gallery
//
//  Created by Alexander Baraley on 23.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class TabBaseFlowController: UINavigationController {

	// MARK: - Initialization

	let authenticationStateProvider: AuthenticationStateProvider

	init(authenticationStateProvider: AuthenticationStateProvider) {
		self.authenticationStateProvider = authenticationStateProvider

		super.init(nibName: nil, bundle: nil)

		initialSetup()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Properties

	private(set) lazy var searchController = UISearchController(searchResultsController: nil)

	// MARK: - Segmented control

	private(set) lazy var rightNavigationItemSegmentedControl: UISegmentedControl = {
		let control = UISegmentedControl(items: segmentControlItemsTittles)
		control.addTarget(self, action: #selector(segmentedControlValueDidChange), for: .valueChanged)
		control.selectedSegmentIndex = 0

		return control
	}()

	@objc private func segmentedControlValueDidChange(_ segmentedControl: UISegmentedControl) {
		updateRootViewControllerDataSource()
	}

	// MARK: - Life cycle

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		setupSearchController()
	}

	// MARK: - Overridable

	var searchPlaceholder: String {
		""
	}
	var segmentControlItemsTittles: [String] {
		[]
	}

	func initialSetup() {
		authenticationStateProvider.addObserve(self)
		navigationBar.prefersLargeTitles = true
	}

	func updateRootViewControllerDataSource(with searchQuery: String? = nil) {

	}
}

private extension TabBaseFlowController {

	func setupSearchController() {
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.searchBar.placeholder = searchPlaceholder
		searchController.searchBar.autocorrectionType = .yes

		definesPresentationContext = true
	}
}

// MARK: - AuthenticationObserver
extension TabBaseFlowController: AuthenticationObserver {

	func authenticationDidFinish(with userData: AuthenticatedUserData) {
		updateRootViewControllerDataSource()
	}

	func deauthenticationDidFinish() {
		updateRootViewControllerDataSource()
	}
}

// MARK: - UISearchBarDelegate
extension TabBaseFlowController: UISearchBarDelegate {

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let searchQuery = searchBar.text, !searchQuery.isEmpty {
			updateRootViewControllerDataSource(with: searchQuery)
		}
	}
}

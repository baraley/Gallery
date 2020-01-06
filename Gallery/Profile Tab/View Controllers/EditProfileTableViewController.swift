//
//  EditProfileTableViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/15/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class EditProfileTableViewController: UITableViewController {
	
	// MARK: - Public properties
	
	var userData: EditableUserData? {
		didSet {
			validateUserData()
		}
	}
	
	// MARK: - Private properties
	
	private var currentTextView: UITextView?
	
	// MARK: - Outlets
	
	@IBOutlet private var saveButton: UIBarButtonItem!
	
	// MARK: - Actions
	
	@IBAction private func cancelAction(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
	// MARK: - Life cycle
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		currentTextView?.resignFirstResponder()
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(indexPath: indexPath) as EditProfileTableViewCell
		
		cell.editableText = editableText(for: indexPath)
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Section(section).rawValue
	}
}

// MARK: - Private
private extension EditProfileTableViewController {
	
	func editableText(for indexPath: IndexPath) -> String {
		let text: String?
		
		switch Section(at: indexPath) {
		case .firstName:	text = userData?.firstName
		case .lastName:		text = userData?.lastName
		case .userName:		text = userData?.userName
		case .biography:	text = userData?.biography
		case .location:		text = userData?.location
		}
		
		return text ?? ""
	}
	
	func saveText(_ text: String, at indexPath: IndexPath) {
		switch Section(at: indexPath) {
		case .firstName:	 userData?.firstName = text
		case .lastName:		 userData?.lastName = text
		case .userName:		 userData?.userName = text
		case .biography:	 userData?.biography = text
		case .location:		 userData?.location = text
		}
	}
	
	func validateUserData() {
		guard let userData = userData else { return }
		
		if userData.firstName.count == 0 ||
			userData.userName.count == 0 {
			
			saveButton.isEnabled = false
		} else {
			saveButton.isEnabled = true
		}
	}
}

// MARK: - UITextViewDelegate
extension EditProfileTableViewController: UITextViewDelegate {

	func textViewDidBeginEditing(_ textView: UITextView) {
		currentTextView = textView
	}
	
	func textViewDidChange(_ textView: UITextView) {
		
		if let indexPath = tableView.indexPathForRow(with: textView) {
			saveText(textView.text, at: indexPath)
		}

		//Needs for proper updating of cell's size
		DispatchQueue.main.async {
			self.tableView.beginUpdates()
			self.tableView.endUpdates()
		}
	}
}

// MARK: - Types
private extension EditProfileTableViewController {
	
	enum Section: String, CaseIterable {
		case firstName = "First name"
		case lastName = "Last name"
		case userName = "Username"
		case biography = "Biography"
		case location = "Location"
		
		init(at indexPath: IndexPath) {
			self = Section.allCases[indexPath.section]
		}
		
		init(_ section: Int) {
			self = Section.allCases[section]
		}
	}
}

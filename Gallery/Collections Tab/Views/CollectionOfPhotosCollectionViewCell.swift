//
//  CollectionsOfPhotosCollectionViewCell.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/22/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class CollectionOfPhotosCollectionViewCell: ImageCollectionViewCell {

	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	private var titleLabel = UILabel(frame: .zero)
	private var dimmingView = UIView(frame: .zero)

	override init(frame: CGRect) {
		super.init(frame: frame)

		setupDimmingView()
		setupTitleLabel()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		dimmingView.frame = bounds
	}
}

private extension CollectionOfPhotosCollectionViewCell {

	func setupTitleLabel() {
		titleLabel.numberOfLines = 2
		titleLabel.textAlignment = .center
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.textColor = .white
		titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)

		contentView.addSubview(titleLabel)
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
			titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
			titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.leadingAnchor),
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
			titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}

	func setupDimmingView() {
		dimmingView.alpha = 0.4
		dimmingView.backgroundColor = .black
//		dimmingView.translatesAutoresizingMaskIntoConstraints = false
//
		contentView.addSubview(dimmingView)
//		NSLayoutConstraint.activate([
//			dimmingView.topAnchor.constraint(equalTo: contentView.topAnchor),
//			dimmingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//			dimmingView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
//			dimmingView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
//		])
	}
}

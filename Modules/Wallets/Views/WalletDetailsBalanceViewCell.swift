//
//  WalletDetailsBalanceViewCell.swift
//  MyMonero
//
//  Created by Paul Shapiro on 7/15/17.
//  Copyright © 2017 MyMonero. All rights reserved.
//

import UIKit

extension WalletDetails
{
	struct Balance
	{
		class Cell: UICommonComponents.Tables.ReusableTableViewCell
		{
			override class func reuseIdentifier() -> String {
				return "UICommonComponents.Details.WalletDetails.Balance.Cell"
			}
			override class func height() -> CGFloat {
				return DisplayView.height
			}
			//
			let balanceDisplayView = DisplayView()
			override func setup()
			{
				super.setup()
				do {
					self.selectionStyle = .none
					self.backgroundColor = UIColor.contentBackgroundColor
					self.addSubview(self.balanceDisplayView)
				}
			}
			//
			// Overrides
			override func layoutSubviews()
			{
				super.layoutSubviews()
				self.balanceDisplayView.frame = self.bounds.insetBy(
					dx: WalletDetailsViewController.margin_h - DisplayView.imagePaddingInsets.left,
					dy: -DisplayView.imagePaddingInsets.top
				)
			}
			override func _configureUI()
			{
				let configuration = self.configuration!
				let wallet = configuration.dataObject as? Wallet
				if wallet == nil {
					assert(false)
					return
				}
				if wallet!.didFailToInitialize_flag == true || wallet!.didFailToBoot_flag == true {
					self.balanceDisplayView.label.textColor = .white
					self.balanceDisplayView.label.text = NSLocalizedString("ERROR LOADING", comment: "")
				} else if wallet!.hasEverFetched_accountInfo == false {
					self.balanceDisplayView.set(
						utilityText: NSLocalizedString("LOADING…", comment: ""),
						withWallet: wallet!
					)
				} else {
					self.balanceDisplayView.set(balanceWithWallet: wallet!)
				}
			}
		}

		class DisplayView: UIImageView
		{
			//
			// Constants
			static let height: CGFloat = 71
			//
			static let imagePaddingInsets = UIEdgeInsetsMake(2, 1, 2, 1)
			static let cornerRadius: CGFloat = 5
			static func stretchableBackgroundImage(forSwatchColor swatchColor: Wallet.SwatchColor) -> UIImage
			{
				let name = "balanceDisplayBG_stretchable_\(swatchColor.colorName)"
				let image = UIImage(named: name)!
				let stretchableImage = image.stretchableImage(
					withLeftCapWidth: Int(imagePaddingInsets.left + cornerRadius),
					topCapHeight: Int(imagePaddingInsets.top + cornerRadius)
				)
				return stretchableImage
			}
			//
			// Properties
			let label = UILabel()
			//
			// Init
			init()
			{
				super.init(frame: .zero)
				self.setup()
			}
			required init?(coder aDecoder: NSCoder) {
				fatalError("init(coder:) has not been implemented")
			}
			func setup()
			{
				do {
					let view = self.label
					view.numberOfLines = 1
					view.lineBreakMode = .byTruncatingTail
					view.font = UIFont(name: UIFont.lightMonospaceFontName, size: 32)
					self.addSubview(view)
				}
			}
			//
			// Overrides
			override func layoutSubviews() {
				super.layoutSubviews()
				let imagePaddingInsets = type(of: self).imagePaddingInsets
				let contentFrame = self.bounds.insetBy(dx: imagePaddingInsets.left, dy: imagePaddingInsets.top)
				do {
					var labelFrame = contentFrame.insetBy(dx: 18, dy: 0)
					labelFrame.origin.y -= 2 // visual vertical alignment
					self.label.frame = labelFrame
				}
			}
			//
			// Accessors
			func mainSectionColor(withWallet wallet: Wallet) -> UIColor {
				if wallet.swatchColor.isADarkColor {
					return UIColor(rgb: 0xF8F7F8) // so use light text
				} else {
					return UIColor(rgb: 0x161416) // so use dark text
				}
			}
			func paddingZeroesSectionColor(withWallet wallet: Wallet) -> UIColor {
				if wallet.swatchColor.isADarkColor {
					return UIColor(red: 248/255, green: 247/255, blue: 248/255, alpha: 0.2)
				} else {
					return UIColor(red: 29/255, green: 26/255, blue: 29/255, alpha: 0.2)
				}
			}
			//
			// Imperatives
			func set(balanceWithWallet wallet: Wallet)
			{
				var finalized_main_string = ""
				var finalized_paddingZeros_string = ""
				do {
					let raw_balanceString = wallet.balance_formattedString
					let coinUnitPlaces = MoneroConstants.currency_unitPlaces
					let raw_balanceString__components = raw_balanceString.components(separatedBy: ".")
					if raw_balanceString__components.count == 1 {
						let balance_aspect_integer = raw_balanceString__components[0]
						if balance_aspect_integer == "0" {
							finalized_main_string = ""
							finalized_paddingZeros_string = "00." + String(repeating: "0", count: coinUnitPlaces)
						} else {
							finalized_main_string = balance_aspect_integer + "."
							finalized_paddingZeros_string = String(repeating: "0", count: coinUnitPlaces)
						}
					} else if raw_balanceString__components.count == 2 {
						finalized_main_string = raw_balanceString
						let decimalComponent = raw_balanceString__components[1]
						let decimalComponent_length = decimalComponent.characters.count
						if decimalComponent_length < coinUnitPlaces + 2 {
							finalized_paddingZeros_string = String(repeating: "0", count: coinUnitPlaces - decimalComponent_length + 2)
						}
					} else {
						assert(false, "Couldn't parse formatted balance string.")
						finalized_main_string = raw_balanceString
						finalized_paddingZeros_string = ""
					}
				}
				let attributes: [String: Any] = [:]
				let attributedText = NSMutableAttributedString(string: "\(finalized_main_string)\(finalized_paddingZeros_string)", attributes: attributes)
				let mainSectionColor = self.mainSectionColor(withWallet: wallet)
				let paddingZeroesSectionColor = self.paddingZeroesSectionColor(withWallet: wallet)
				do {
					attributedText.addAttributes(
						[
							NSForegroundColorAttributeName: mainSectionColor,
							],
						range: NSMakeRange(0, finalized_main_string.characters.count)
					)
					if finalized_paddingZeros_string.characters.count > 0 {
						attributedText.addAttributes(
							[
								NSForegroundColorAttributeName: paddingZeroesSectionColor,
								],
							range: NSMakeRange(
								finalized_main_string.characters.count,
								attributedText.string.characters.count - finalized_paddingZeros_string.characters.count
							)
						)
					}
				}
				self.label.textColor = paddingZeroesSectionColor // for the '…' during truncation
				self.label.attributedText = attributedText
				self._configureBackgroundColor(withWallet: wallet)
			}
			func set(utilityText text: String, withWallet wallet: Wallet)
			{
				self.label.textColor = self.mainSectionColor(withWallet: wallet)
				self.label.text = text
				self._configureBackgroundColor(withWallet: wallet)
			}
			func _configureBackgroundColor(withWallet wallet: Wallet)
			{
				self.image = type(of: self).stretchableBackgroundImage(forSwatchColor: wallet.swatchColor)
			}
		}
	}
}
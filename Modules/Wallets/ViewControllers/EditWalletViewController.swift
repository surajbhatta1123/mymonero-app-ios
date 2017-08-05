//
//  EditWalletViewController.swift
//  MyMonero
//
//  Created by Paul Shapiro on 7/19/17.
//  Copyright © 2017 MyMonero. All rights reserved.
//

import UIKit

struct EditWallet {}

extension EditWallet
{
	class ViewController: UICommonComponents.FormViewController
	{
		//
		// Properties
		var wallet: Wallet // think it should be fine if it's a strong reference since self will be torn down 
		//
		// Lifecycle - Init
		required init(wallet: Wallet)
		{
			self.wallet = wallet
			super.init()
		}
		required init?(coder aDecoder: NSCoder)
		{
			fatalError("init(coder:) has not been implemented")
		}
		//
		// Properties
		var walletLabel_label: UICommonComponents.Form.FieldLabel!
		var walletLabel_inputView: UICommonComponents.FormInputField!
		//
		var walletColorPicker_label: UICommonComponents.Form.FieldLabel!
		var walletColorPicker_inputView: UICommonComponents.WalletColorPickerView!
		//
		override func setup_views()
		{
			super.setup_views()
			do { // wallet label field
				do {
					let view = UICommonComponents.Form.FieldLabel(
						title: NSLocalizedString("WALLET NAME", comment: ""),
						sizeToFit: true
					)
					self.walletLabel_label = view
					self.scrollView.addSubview(view)
				}
				do {
					let view = UICommonComponents.FormInputField(
						placeholder: NSLocalizedString("For your reference", comment: "")
					)
					view.text = self.wallet.walletLabel
					view.addTarget(self, action: #selector(aField_editingChanged), for: .editingChanged)
					view.delegate = self
					view.returnKeyType = .go
					self.walletLabel_inputView = view
					self.scrollView.addSubview(view)
				}
			}
			do { // wallet color field
				do {
					let view = UICommonComponents.Form.FieldLabel(
						title: NSLocalizedString("COLOR", comment: ""),
						sizeToFit: true
					)
					self.walletColorPicker_label = view
					self.scrollView.addSubview(view)
				}
				do {
					let view = UICommonComponents.WalletColorPickerView(
						optl__currentlySelected_color: self.wallet.swatchColor
					)
					self.walletColorPicker_inputView = view
					self.scrollView.addSubview(view)
				}
			}
		}
		override func setup_navigation()
		{
			super.setup_navigation()
			//
			self.navigationItem.title = NSLocalizedString("Edit Wallet", comment: "")
			self.navigationItem.leftBarButtonItem = UICommonComponents.NavigationBarButtonItem(
				type: .cancel,
				target: self,
				action: #selector(tapped_barButtonItem_cancel)
			)
			self.navigationItem.rightBarButtonItem = UICommonComponents.NavigationBarButtonItem(
				type: .save,
				target: self,
				action: #selector(tapped_barButtonItem_save)
			)
		}
		//
		// Accessors - Lookups/Derived - Input values
		var walletLabel: String? {
			return self.walletLabel_inputView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
		}
		//
		// Accessors - Form submittable
		override func new_isFormSubmittable() -> Bool
		{
			if self.submissionController != nil {
				return false
			}
			guard let walletLabel = self.walletLabel, walletLabel != "" else {
				return false
			}
			return true
		}
		//
		// Imperatives - Modal
		func dismissModal()
		{
			self.navigationController?.dismiss(animated: true, completion: nil)
		}
		//
		// Runtime - Imperatives - Overrides
		override func disableForm()
		{
			super.disableForm()
			//
			self.scrollView.isScrollEnabled = false
			//
			self.walletColorPicker_inputView.set(isEnabled: false)
			self.walletLabel_inputView.isEnabled = false
		}
		override func reEnableForm()
		{
			super.reEnableForm()
			//
			self.scrollView.isScrollEnabled = true
			//
			self.walletColorPicker_inputView.set(isEnabled: true)
			self.walletLabel_inputView.isEnabled = true
		}
		var submissionController: EditWallet.SubmissionController?
		override func _tryToSubmitForm()
		{
			if self.submissionController != nil {
				assert(false) // should be impossible
				return
			}
			let parameters = EditWallet.SubmissionController.Parameters(
				walletInstance: self.wallet,
				walletLabel: self.walletLabel!,
				swatchColor: self.walletColorPicker_inputView.currentlySelected_color!,
				preSuccess_terminal_validationMessage_fn:
				{ [unowned self] (localized_errStr) in
					self.setValidationMessage(localized_errStr)
				})
				{ (wallet) in
					// success
					self.submissionController = nil // free
					self.dismissModal()
				}
			let controller = EditWallet.SubmissionController(parameters: parameters)
			self.submissionController = controller
			controller.handle()
		}
		//
		// Delegation - View
		override func viewDidLayoutSubviews()
		{
			super.viewDidLayoutSubviews()
			//
			let topPadding: CGFloat = 13
			let y: CGFloat = 0
			let textField_w = self.new__textField_w
			let fieldset_topMargin: CGFloat = UICommonComponents.Form.FieldLabel.marginAboveLabelForUnderneathField_textInputView // what we would expect for a starting y offset for form fields…
			do {
				self.walletLabel_label.frame = CGRect(
					x: CGFloat.form_label_margin_x,
					y: y + fieldset_topMargin,
					width: textField_w,
					height: self.walletLabel_label.frame.size.height
				).integral
				self.walletLabel_inputView.frame = CGRect(
					x: CGFloat.form_input_margin_x,
					y: self.walletLabel_label.frame.origin.y + self.walletLabel_label.frame.size.height + UICommonComponents.Form.FieldLabel.marginBelowLabelAboveTextInputView,
					width: textField_w,
					height: self.walletLabel_inputView.frame.size.height
				).integral
			}
			do {
				self.walletColorPicker_label.frame = CGRect(
					x: CGFloat.form_label_margin_x,
					y: self.walletLabel_inputView.frame.origin.y + self.walletLabel_inputView.frame.size.height + fieldset_topMargin,
					width: textField_w,
					height: self.walletColorPicker_label.frame.size.height
				).integral
				//
				let colorPicker_x = CGFloat.form_input_margin_x
				let colorPicker_maxWidth = self.scrollView.frame.size.width - colorPicker_x
				let colorPicker_height = self.walletColorPicker_inputView.heightThatFits(width: colorPicker_maxWidth)
				self.walletColorPicker_inputView.frame = CGRect(
					x: colorPicker_x,
					y: self.walletColorPicker_label.frame.origin.y + self.walletColorPicker_label.frame.size.height + UICommonComponents.Form.FieldLabel.marginBelowLabelAboveTextInputView,
					width: colorPicker_maxWidth,
					height: colorPicker_height
				).integral
			}
			self.scrollableContentSizeDidChange(withBottomView: self.walletColorPicker_inputView, bottomPadding: topPadding)
		}
		//
		// Delegation - Interactions
		func tapped_barButtonItem_cancel()
		{
			self.dismissModal()
		}
		func tapped_barButtonItem_save()
		{
			self.aFormSubmissionButtonWasPressed()
		}
	}
}

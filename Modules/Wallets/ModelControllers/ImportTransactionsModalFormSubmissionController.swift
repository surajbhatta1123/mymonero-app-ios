//
//  ImportTransactionsModalFormSubmissionController.swift
//  MyMonero
//
//  Created by Paul Shapiro on 7/20/17.
//  Copyright (c) 2014-2019, MyMonero.com
//
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of
//	conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list
//	of conditions and the following disclaimer in the documentation and/or other
//	materials provided with the distribution.
//
//  3. Neither the name of the copyright holder nor the names of its contributors may be
//	used to endorse or promote products derived from this software without specific
//	prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
//  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//
import Foundation

extension ImportTransactionsModal
{
	class SubmissionController
	{
		struct Parameters
		{
			let fromWallet: Wallet
			let infoRequestParsingResult: HostedMonero.ParsedResult_ImportRequestInfoAndStatus
			//
			var preSuccess_nonTerminal_validationMessageUpdate_fn: (_ localizedString: String) -> Void
			var preSuccess_terminal_validationMessage_fn: (_ localizedString: String) -> Void // aka error
			var canceled_fn: () -> Void
			var success_fn: () -> Void
		}
		var parameters: Parameters
		// TODO:
//		var sendFunds_requestHandle: HostedMoneroAPIClient.RequestHandle?
		init(parameters: Parameters)
		{
			self.parameters = parameters
		}
		deinit
		{
			// TODO
//			self.cancel() // if any
		}
		//
		// Imperatives
		func handle()
		{
			self.parameters.fromWallet.sendFunds(
				enteredAddressValue: self.parameters.infoRequestParsingResult.payment_address,
				resolvedAddress: nil,
				manuallyEnteredPaymentID: self.parameters.infoRequestParsingResult.payment_id,
				resolvedPaymentID: nil,
				hasPickedAContact: false,
				resolvedAddress_fieldIsVisible: false,
				manuallyEnteredPaymentID_fieldIsVisible: true,
				resolvedPaymentID_fieldIsVisible: false,
				//
				contact_payment_id: nil,
				cached_OAResolved_address: nil,
				contact_hasOpenAliasAddress: nil,
				contact_address: nil,
				//
				raw_amount_string: self.parameters.infoRequestParsingResult.import_fee.doubleParseable_formattedString, // sort of a shame to go back and forth but not a big deal, especially in this case
				isSweeping: false,
				simple_priority: MoneroTransferSimplifiedPriority.defaultPriority,
				//
				didUpdateProcessStep_fn: { [weak self] (msg) in
					guard let thisSelf = self else {
						return
					}
					thisSelf.parameters.preSuccess_nonTerminal_validationMessageUpdate_fn(msg)
				},
				success_fn: { [weak self] (sentTo_address, isXMRAddressIntegrated, integratedAddressPIDForDisplay_orNil, final_sentAmount, sentPaymentID_orNil, tx_hash, tx_fee, tx_key, mockedTransaction) in
					guard let thisSelf = self else {
						return
					}
					// TODO: show transactionHash to user somehow!
					thisSelf.parameters.success_fn()

				},
				canceled_fn: { [weak self] in
					guard let thisSelf = self else {
						return
					}
					thisSelf.parameters.canceled_fn()
				},
				failWithErr_fn: { [weak self] (err_str) in
					guard let thisSelf = self else {
						return
					}
					thisSelf.parameters.preSuccess_terminal_validationMessage_fn(err_str)
				}
			)
		}
		// TODO
//		func cancel()
//		{
//			if self.sendFunds_requestHandle != nil {
//				self.sendFunds_requestHandle!.cancel()
//				self.sendFunds_requestHandle = nil
//			}
//			// if someone else is cancelling this, or the cancel is actually going to succeed on a deinit, we'll assume the consumer is the one initiating the cancel, so there's no need to call a cb
//		}
	}
}

//
//  HomeViewController.swift
//  StripeExample
//
//  Created by Glenn Von Posadas on 5/22/20.
//  Copyright © 2020 GAM Dynamics. All rights reserved.
//

import Kingfisher
import Stripe
import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var purchaseButton: UIButton!
    
    var paymentContext: STPPaymentContext!
    var hasPresentedPaymentOptions = false
    
    private var item: Item!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadData()
    }
    
    private func setupPayment() {
        let config = STPPaymentConfiguration.shared()
        config.appleMerchantIdentifier = "merchant.com.gsample.app"
        config.companyName = "GAM Dynamics"
        config.requiredBillingAddressFields = .none

        let customerContext = STPCustomerContext(keyProvider: API.shared)
        
        let paymentContext = STPPaymentContext(
            customerContext: customerContext,
            configuration: config,
            theme: STPTheme.default()
        )
        
        let userInformation = STPUserInformation()
        paymentContext.prefilledInformation = userInformation
        paymentContext.paymentAmount = 10
        paymentContext.paymentCurrency = "usd"
        
        self.paymentContext = paymentContext
        
        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self
    }
    
    private func loadData() {
        let item = """
[{
  "id" : 1,
  "price" : 11,
  "title" : "a",
  "updatedAt" : "2020-06-21T09:47:36.000Z",
  "description" : "a",
  "createdAt" : "2020-06-21T09:47:36.000Z",
  "photoURL" : "https://www.placekitten.com/100/100"
}]
"""
        let d = item.data(using: .utf8)!
        
                        if let items = try? JSONDecoder().decode([Item].self, from: d) {
                            self.setupPayment()
                            return
                        }
    }
        
    @IBAction func purchaseTapped(_ sender: Any) {
        self.startPaymentFlow()
    }
    
    private func startPaymentFlow() {
        if !hasPresentedPaymentOptions {
            self.paymentContext.presentPaymentOptionsViewController()
            hasPresentedPaymentOptions = true
        } else {
            self.paymentContext.requestPayment()
        }
    }
}

// MARK: - STPPaymentContextDelegate

extension HomeViewController: STPPaymentContextDelegate {
    static var readyForPayment = 0
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        if self.paymentContext.selectedPaymentOption != nil && self.hasPresentedPaymentOptions {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.paymentContext.requestPayment()
            }
        }
        
        HomeViewController.readyForPayment += 1
        print("😎😎😎😎😎😎😎😎😎😎 --- \(HomeViewController.readyForPayment)")
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        self.alert(title: "ERROR: \(error.localizedDescription)", okayButtonTitle: "OK", withBlock: nil)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        API.shared.createPaymentIntent(for: self.item) { (result) in
            switch result {
            case .success(let clientSecret):
                // Confirm the PaymentIntent
                let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                paymentIntentParams.configure(with: paymentResult)
                paymentIntentParams.returnURL = "payments-example://stripe-redirect"
                STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { status, paymentIntent, error in
                    switch status {
                    case .succeeded:
                        // Our example backend asynchronously fulfills the customer's order via webhook
                        // See https://stripe.com/docs/payments/payment-intents/ios#fulfillment
                        completion(.success, nil)
                    case .failed:
                        completion(.error, error)
                    case .canceled:
                        completion(.userCancellation, nil)
                    @unknown default:
                        completion(.error, nil)
                    }
                }
            case .failure(let error):
                // A real app should retry this request if it was a network error.
                print("Failed to create a Payment Intent: \(error)")
                completion(.error, error)
                break
            }
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        let title: String
        let message: String
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            title = "Success"
            message = "Your purchase was successful!"
        case .userCancellation:
            return()
        @unknown default:
            return()
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}

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
    
    private var item: Item!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.purchaseButton.isEnabled = false
        self.purchaseButton.backgroundColor = .gray
        
        self.loadData()
    }
    
    private func setupPayment() {
        let config = STPPaymentConfiguration.shared()
        config.appleMerchantIdentifier = "merchant.com.gsample.app"
        config.companyName = "GAM Dynamics"
        config.requiredBillingAddressFields = .full
        //config.requiredShippingAddressFields = .all
        //config.shippingType = settings.shippingType
        config.additionalPaymentOptions = .applePay
        
        let customerContext = STPCustomerContext(keyProvider: API.shared)
        let paymentContext = STPPaymentContext(
            customerContext: customerContext,
            configuration: config,
            theme: STPTheme.default()
        )
        
        let userInformation = STPUserInformation()
        paymentContext.prefilledInformation = userInformation
        paymentContext.paymentAmount = Int(item.price) * 100 //$9.99 * 100 cents
        paymentContext.paymentCurrency = "usd"
        
        self.paymentContext = paymentContext
        
        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self
    }
    
    private func loadData() {
        ARSLineProgress.show()
        
        API.provider.request(.getItems) { (result) in
            ARSLineProgress.hide()
            
            switch result {
            case let .success(response):
                if let items = try? JSONDecoder().decode([Item].self, from: response.data) {
                    self.handleItems(items)
                    return
                }
                
                self.alert(
                    title: "Erorr Getting Items!",
                    okayButtonTitle: "OK",
                    withBlock: nil
                )
                
            case .failure:
                self.alert(
                    title: "Server error getting items.",
                    okayButtonTitle: "OK",
                    withBlock: nil
                )
            }
        }
    }
    
    private func handleItems(_ items: [Item]) {
        guard let item = items.first,
            let url = URL(string: item.photoURL) else { return }
        
        let resource = ImageResource(downloadURL: url)
        
        self.item = item
        
        self.titleLabel.text = item.title
        self.descLabel.text = item.descriptionField
        self.bannerImageView.kf.setImage(with: resource)
        self.purchaseButton.setTitle("Purchase: $\(String(format:"%.2f", item.price))", for: .normal)
        
        self.setupPayment()
    }
    
    @IBAction func purchaseTapped(_ sender: Any) {
        self.startPaymentFlow()
    }
    
    private func startPaymentFlow() {
        if let paymentOption = paymentContext.selectedPaymentOption, HomeViewController.readyForPayment > 2  {
            self.paymentContext.requestPayment()
            return
        }
        
        self.paymentContext.pushPaymentOptionsViewController()
    }
}

// MARK: - STPPaymentContextDelegate

extension HomeViewController: STPPaymentContextDelegate {
    static var readyForPayment = 0
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
//                self.paymentRow.loading = paymentContext.loading
//        if let paymentOption = paymentContext.selectedPaymentOption {
//            self.paymentRow.detail = paymentOption.label
//        } else {
//            self.paymentRow.detail = "Select Payment"
//        }
//        if let shippingMethod = paymentContext.selectedShippingMethod {
//            self.shippingRow?.detail = shippingMethod.label
//        } else {
//            self.shippingRow?.detail = "Select address"
//        }
        
        var localeComponents: [String: String] = [
            NSLocale.Key.currencyCode.rawValue: "usd",
        ]
        localeComponents[NSLocale.Key.languageCode.rawValue] = NSLocale.preferredLanguages.first
        let localeID = NSLocale.localeIdentifier(fromComponents: localeComponents)
        let locale: Locale = Locale(identifier: localeID)

        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = locale
        numberFormatter.numberStyle = .currency
        numberFormatter.usesGroupingSeparator = true

        print("CONTEXT DID CHANGE: \(numberFormatter.string(from: NSNumber(value: Float(self.paymentContext.paymentAmount)/100))!)")
        self.purchaseButton.isEnabled = paymentContext.selectedPaymentOption != nil
        self.purchaseButton.backgroundColor = self.purchaseButton.isEnabled ? UIColor.colorWithRGBHex(0x00589C) : .gray
        
        //HomeViewController.readyForPayment = true
        // this is the dirtiest hack i've ever created.
        HomeViewController.readyForPayment += 1
        
        if HomeViewController.readyForPayment > 2 {
            self.purchaseButton.setTitle("PAY NOW", for: .normal)
        }
        
        print("-----> \(HomeViewController.readyForPayment)")
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        self.alert(title: "ERROR: \(error.localizedDescription)", okayButtonTitle: "OK", withBlock: nil)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        // Create the PaymentIntent on the backend
        // To speed this up, create the PaymentIntent earlier in the checkout flow and update it as necessary (e.g. when the cart subtotal updates or when shipping fees and taxes are calculated, instead of re-creating a PaymentIntent for every payment attempt.
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

// MARK: - STPAddCardViewControllerDelegate

extension HomeViewController: STPAddCardViewControllerDelegate {
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        addCardViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - STPPaymentOptionsViewControllerDelegate

extension HomeViewController: STPPaymentOptionsViewControllerDelegate {
    func paymentOptionsViewController(_ paymentOptionsViewController: STPPaymentOptionsViewController, didFailToLoadWithError error: Error) {
        paymentOptionsViewController.alert(
            title: "Error",
            message: error.localizedDescription,
            okayButtonTitle: "OK") { _ in
                paymentOptionsViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func paymentOptionsViewControllerDidFinish(_ paymentOptionsViewController: STPPaymentOptionsViewController) {
        paymentOptionsViewController.dismiss(animated: true, completion: nil)
    }
    
    func paymentOptionsViewControllerDidCancel(_ paymentOptionsViewController: STPPaymentOptionsViewController) {
        paymentOptionsViewController.dismiss(animated: true, completion: nil)
    }
}



////


class MockAPIClient: STPAPIClient {
    override func createPaymentMethod(with paymentMethodParams: STPPaymentMethodParams, completion: @escaping STPPaymentMethodCompletionBlock) {
        guard let card = paymentMethodParams.card, let billingDetails = paymentMethodParams.billingDetails else { return }
        
        // Generate a mock card model using the given card params
        var cardJSON: [String: Any] = [:]
        var billingDetailsJSON: [String: Any] = [:]
        cardJSON["id"] = "\(card.hashValue)"
        cardJSON["exp_month"] = "\(card.expMonth ?? 0)"
        cardJSON["exp_year"] = "\(card.expYear ?? 0)"
        cardJSON["last4"] = card.number?.suffix(4)
        billingDetailsJSON["name"] = billingDetails.name
        billingDetailsJSON["line1"] = billingDetails.address?.line1
        billingDetailsJSON["line2"] = billingDetails.address?.line2
        billingDetailsJSON["state"] = billingDetails.address?.state
        billingDetailsJSON["postal_code"] = billingDetails.address?.postalCode
        billingDetailsJSON["country"] = billingDetails.address?.country
        cardJSON["country"] = billingDetails.address?.country
        if let number = card.number {
            let brand = STPCardValidator.brand(forNumber: number)
            cardJSON["brand"] = STPCard.string(from: brand)
        }
        cardJSON["fingerprint"] = "\(card.hashValue)"
        cardJSON["country"] = "US"
        let paymentMethodJSON: [String: Any] = [
            "id": "\(card.hashValue)",
            "object": "payment_method",
            "type": "card",
            "livemode": false,
            "created": NSDate().timeIntervalSince1970,
            "used": false,
            "card": cardJSON,
            "billing_details": billingDetailsJSON,
        ]
        let paymentMethod = STPPaymentMethod.decodedObject(fromAPIResponse: paymentMethodJSON)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            completion(paymentMethod, nil)
        }
    }
}

import Foundation
import Stripe

class MockCustomer: STPCustomer {
    var mockPaymentMethods: [STPPaymentMethod] = []
    var mockDefaultPaymentMethod: STPPaymentMethod? = nil
    var mockShippingAddress: STPAddress?
    
    override init() {
        /**
         Preload the mock customer with saved cards.
         last4 values are from test cards: https://stripe.com/docs/testing#cards
         Not using the "4242" and "4444" numbers, since those are the easiest
         to remember and fill.
         */
        let visa = [
            "card": [
                "id": "preloaded_visa",
                "exp_month": "10",
                "exp_year": "2020",
                "last4": "1881",
                "brand": "visa",
            ],
            "type": "card",
            "id": "preloaded_visa",
            ] as [String : Any]
        if let card = STPPaymentMethod.decodedObject(fromAPIResponse: visa) {
            mockPaymentMethods.append(card)
        }
        let masterCard = [
            "card": [
                "id": "preloaded_mastercard",
                "exp_month": "10",
                "exp_year": "2020",
                "last4": "8210",
                "brand": "mastercard",
            ],
            "type": "card",
            "id": "preloaded_mastercard",
            ] as [String : Any]
        if let card = STPPaymentMethod.decodedObject(fromAPIResponse: masterCard) {
            mockPaymentMethods.append(card)
        }
        let amex = [
            "card": [
                "id": "preloaded_amex",
                "exp_month": "10",
                "exp_year": "2020",
                "last4": "0005",
                "brand": "amex",
            ],
            "type": "card",
            "id": "preloaded_amex",
            ] as [String : Any]
        if let card = STPPaymentMethod.decodedObject(fromAPIResponse: amex) {
            mockPaymentMethods.append(card)
        }
    }
    
    var paymentMethods: [STPPaymentMethod] {
        get {
            return mockPaymentMethods
        }
        set {
            mockPaymentMethods = newValue
        }
    }
    
    var defaultPaymentMethod: STPPaymentMethod? {
        get {
            return mockDefaultPaymentMethod
        }
        set {
            mockDefaultPaymentMethod = newValue
        }
    }
    
    override var shippingAddress: STPAddress? {
        get {
            return mockShippingAddress
        }
        set {
            mockShippingAddress = newValue
        }
    }
}

class MockCustomerContext: STPCustomerContext {
    
    let customer = MockCustomer()
    
    override func retrieveCustomer(_ completion: STPCustomerCompletionBlock? = nil) {
        if let completion = completion {
            completion(customer, nil)
        }
    }
    
    override func attachPaymentMethod(toCustomer paymentMethod: STPPaymentMethod, completion: STPErrorBlock? = nil) {
        customer.paymentMethods.append(paymentMethod)
        if let completion = completion {
            completion(nil)
        }
    }
    
    override func detachPaymentMethod(fromCustomer paymentMethod: STPPaymentMethod, completion: STPErrorBlock? = nil) {
        if let index = customer.paymentMethods.firstIndex(where: { $0.stripeId == paymentMethod.stripeId }) {
            customer.paymentMethods.remove(at: index)
        }
        if let completion = completion {
            completion(nil)
        }
    }
    
    override func listPaymentMethodsForCustomer(completion: STPPaymentMethodsCompletionBlock? = nil) {
        if let completion = completion {
            completion(customer.paymentMethods, nil)
        }
    }
    
    func selectDefaultCustomerPaymentMethod(_ paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
        if customer.paymentMethods.contains(where: { $0.stripeId == paymentMethod.stripeId }) {
            customer.defaultPaymentMethod = paymentMethod
        }
        completion(nil)
    }
    
    override func updateCustomer(withShippingAddress shipping: STPAddress, completion: STPErrorBlock?) {
        customer.shippingAddress = shipping
        if let completion = completion {
            completion(nil)
        }
    }
    
}

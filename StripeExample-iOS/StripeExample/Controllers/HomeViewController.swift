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
    
    var paymentContext: STPPaymentContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadData()
        self.setupPayment()
    }
    
    private func setupPayment() {
        let config = STPPaymentConfiguration.shared()
        config.appleMerchantIdentifier = "merchant.com.gsample.app"
        config.companyName = "GAM Dynamics"
        config.requiredBillingAddressFields = .full
        //config.requiredShippingAddressFields = .all
        //config.shippingType = settings.shippingType
        config.additionalPaymentOptions = .applePay
        
        let customerContext = STPCustomerContext(keyProvider: AuthService)
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
        
        self.titleLabel.text = item.title
        self.descLabel.text = item.descriptionField
        self.bannerImageView.kf.setImage(with: resource)
    }
    
    @IBAction func purchaseTapped(_ sender: Any) {
        self.startPaymentFlow()
    }
    
    private func startPaymentFlow() {
        let config = STPPaymentConfiguration()
        config.additionalPaymentOptions = .default
        config.requiredBillingAddressFields = .none
        config.appleMerchantIdentifier = "dummy-merchant-id"
        
        let paymentOptiosnController = STPPaymentOptionsViewController(
            configuration: config,
            theme: STPTheme.default(),
            customerContext: MockCustomerContext(),
            delegate: self
        )
        paymentOptiosnController.apiClient = MockAPIClient()
        
        let navigationController = UINavigationController(rootViewController: paymentOptiosnController)
        navigationController.navigationBar.stp_theme = STPTheme.default()
        
        self.present(navigationController, animated: true, completion: nil)
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

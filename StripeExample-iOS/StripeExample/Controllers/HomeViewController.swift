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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadData()
    }
    
    private func loadData() {
        ARSLineProgress.show()
        
        API.request(.getItems) { (result) in
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
        
    }
}

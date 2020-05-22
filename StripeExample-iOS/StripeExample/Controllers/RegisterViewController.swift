//
//  RegisterViewController.swift
//  StripeExample
//
//  Created by Glenn Von Posadas on 5/22/20.
//  Copyright © 2020 GAM Dynamics. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        ARSLineProgress.show()
        
        let email = self.emailTextField.text!
        let password = self.passwordTextField.text!
        
        API.request(
            .loginWithEmail(
                email: email,
                password: password
        )) { (result) in
            ARSLineProgress.hide()
            
            switch result {
            case let .success(response):
                if let authModel = try? JSONDecoder().decode(AuthModel.self, from: response.data) {
                    AppDefaults.store(authModel, key: .authModel)
                    self.startFlow()
                    return
                }
                
                self.alert(
                    title: "Registration was successful, but something wrong happened.",
                    okayButtonTitle: "OK",
                    withBlock: nil
                )
                
            case .failure:
                self.alert(
                    title: "Error registering. Please try again.",
                    okayButtonTitle: "OK",
                    withBlock: nil
                )
            }
        }
    }
    
    private func startFlow() {
        self.performSegue(withIdentifier: "showHome", sender: nil)
    }
}

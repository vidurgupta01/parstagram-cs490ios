//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Vidur Gupta on 2/21/20.
//  Copyright © 2020 Vidur Gupta. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func onSignIn(_ sender: Any) {
        PFUser.logInWithUsername(inBackground: txtUsername.text!, password: txtPassword.text!) { (user, error) in
            if (user != nil) {
                self.performSegue(withIdentifier: "loginSegue", sender: nil);
            } else {
                print("Error: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    
    @IBAction func onSignUp(_ sender: Any) {
        let user = PFUser()
        
        user.username = txtUsername.text;
        user.password = txtPassword.text;
        
        user.signUpInBackground { (success, error) in
            if (success) {
                self.performSegue(withIdentifier: "loginSegue", sender: nil);
            } else {
                print("Error: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
}

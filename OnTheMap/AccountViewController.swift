//
//  AccountViewController.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/7/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController, UITextFieldDelegate {
    
    
    struct AccountConstants{
        static let EmailError = "Please enter an email"
        static let PasswordError = "Please enter a password"
        static let LoadingLabel = "Loading..."
        static let SignUpAddress = "https://www.udacity.com/account/auth#!/signup"
        static let LoginMethod = "/session"
        static let AlertTitle = "Login Error"
        static let AlertMessage = "Couldn't connect to the server. Please try again"
        static let AlertButtonTitle = "OK"
        static let TabViewSegue = "TabView Segue"
    }
    

    @IBOutlet var emailTextField: UITextField!{
        didSet{
            emailTextField!.delegate = self
        }
    }
    @IBOutlet var passwordTextField: UITextField!{
        didSet{
            passwordTextField!.delegate = self
        }
    }
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginClicked(sender: UIButton) {
        login()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }else{
            login()
        }
        return true
    }
    
    func login(){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        let email = emailTextField.text
        let password = passwordTextField.text
        if email!.characters.count < 1{
            errorLabel.text = AccountConstants.EmailError
            emailTextField.becomeFirstResponder()
        }else if password!.characters.count < 1{
            errorLabel.text = AccountConstants.PasswordError
            passwordTextField.becomeFirstResponder()
        }else{
            loginButton.enabled = false
            errorLabel.text = AccountConstants.LoadingLabel
            UdacityClient.sharedInstance().login(email!, password: password!){(found,error) in
                performOnMain(){
                    self.loginButton.enabled = true
                    self.errorLabel.text = ""
                }
                if found{
                    performOnMain(){
                        self.passwordTextField.text = ""
                        self.performSegueWithIdentifier(AccountConstants.TabViewSegue, sender: nil)
                    }
                }else{
                    performOnMain(){
                        let alert = UIAlertController(title: AccountConstants.AlertTitle, message: "\(error!)", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: AccountConstants.AlertButtonTitle, style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
            
        }
    }
    
    
    @IBAction func signupClicked(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: AccountConstants.SignUpAddress)!)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

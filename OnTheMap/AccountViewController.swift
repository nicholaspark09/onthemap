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
            //Log them in via POST
            let params = [String:AnyObject]()
            let jsonBody = "{\"udacity\": {\"username\":\"\(email!)\",\"password\":\"\(password!)\"}}"
            UdacityClient.sharedInstance().httpPost(AccountConstants.LoginMethod, parameters: params, jsonBody: jsonBody){ (results,error) in
                if let error = error{
                    print("Error: \(error)")
                }else{
                    print("Found results: \(results)")
                    if let originalerror = results[UdacityClient.JSONResponseKeys.Error] as? String{
                        if let status = results[UdacityClient.JSONResponseKeys.StatusCode] as? Int{
                                if status >= 200 && status <= 299 {
                                    performOnMain(){
                                        let alert = UIAlertController(title: AccountConstants.AlertTitle, message: AccountConstants.AlertMessage, preferredStyle: UIAlertControllerStyle.Alert)
                                        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    }
                                    
                                }else{
                                    performOnMain(){
                                        let alert = UIAlertController(title: AccountConstants.AlertTitle, message: originalerror, preferredStyle: UIAlertControllerStyle.Alert)
                                        alert.addAction(UIAlertAction(title: "Ok", style: .Default,handler: nil))
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    }
                            }
                        }
                        performOnMain(){
                            self.errorLabel.text = ""
                        }
                    }else{
                        if let account = results[UdacityClient.JSONResponseKeys.Account] as? [String:AnyObject]{
                            UdacityClient.sharedInstance().accountKey = account[UdacityClient.JSONResponseKeys.AccountKey] as? String
                        }
                        if let session = results[UdacityClient.JSONResponseKeys.Session] as? [String:AnyObject]{
                            UdacityClient.sharedInstance().sessionID = session[UdacityClient.JSONResponseKeys.SessionId] as? String
                            UdacityClient.sharedInstance().sessionExpiration = session[UdacityClient.JSONResponseKeys.SessionExpiration] as? String
                            performOnMain(){
                                self.performSegueWithIdentifier(AccountConstants.TabViewSegue, sender: nil)
                            }
                        }
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

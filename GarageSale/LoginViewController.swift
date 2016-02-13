//
//  LoginViewController.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/20/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {

    var delegate: LoginSignUpViewControllerDelegate?
    
    
    // MARK: IBOutlets
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    
    // MARK: IBActions
    
    @IBAction func loginButtonTapped(sender: UIButton) {
        if let username = usernameText.text {
            if let password = passwordText.text {
                
                // TODO: Validate Username and password
                
                EZLoadingActivity.show("Logging in...", disableUI: true)
                PFUser.logInWithUsernameInBackground(username, password: password) { (user: PFUser?, error: NSError?) -> Void in
                    EZLoadingActivity.hide()
                    if user != nil {
                        // login succesful
                        print("Login Successful")
                        UserProfile.sharedInstance.loadProfile()
                        if let delegate = self.delegate {
                            delegate.didLogInSignUp(self)
                        }
                    } else {
                        // Login Failed
                        print("Login Failed \(error) \(error?.userInfo)")
                    }
                }
            }
        }
    }
    
    @IBAction func signupButtonTapped(sender: UIButton) {
        if let delegate = delegate {
            delegate.loginWantsToSignUp(self)
        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        if let delegate = delegate {
            delegate.done(self)
        }
    }
    
    
    
    
    // MARK: TextField Delegate 
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        view.endEditing(true)
    }
    
    
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

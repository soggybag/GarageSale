//
//  SignupViewController.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/22/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController, UITextFieldDelegate {

    var delegate: LoginSignUpViewControllerDelegate?
    
    
    // MARK: IBOutlets
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var passwordConfirmText: UITextField!
    
    
    // MARK: IBActions
    
    @IBAction func signupButtonTapped(sender: UIButton) {
        // TODO: Parse Signup 
        // TODO: Validate Form
        
        let user = PFUser()
        user.username = usernameText.text
        user.password = passwordText.text
        user.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if let error = error {
                print("Sign up error: \(error.userInfo)")
            } else {
                if let delegate = self.delegate {
                    delegate.didLogInSignUp(self)
                }
            }
        }
    }
    
    @IBAction func loginButtonTapped(sender: UIButton) {
        if let delegate = delegate {
            delegate.signUpWantsToLogin(self)
        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        if let delegate = delegate {
            delegate.done(self)
        }
    }
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameText.delegate = self
        passwordText.delegate = self
        passwordConfirmText.delegate = self
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

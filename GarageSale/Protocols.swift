//
//  Protocols.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/22/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import UIKit

protocol ProfileViewControllerDelegate {
    func done(sender: UIViewController)
    func logout(sender: UIViewController)
}

protocol LoginSignUpViewControllerDelegate {
    func done(sender: UIViewController)
    func didLogInSignUp(sender: UIViewController)
    func loginWantsToSignUp(sender: UIViewController)
    func signUpWantsToLogin(sender: UIViewController)
}

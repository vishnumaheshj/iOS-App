//
//  ViewController.swift
//  SignUp
//
//  Created by Pradul MT on 24/07/17.
//  Copyright © 2017 Pradul MT. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the delegates for the text fields
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Process the text here, if required
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDashboard" {
            guard let username = usernameTextField.text, let password = passwordTextField.text else {
                print("username/password empty")
                return
            }
            
            print(segue.destination.splitViewController ?? "none")
            print(segue.destination.splitViewController?.childViewControllers ?? "none")
            print(username)
            print(password)

            print(segue.destination.contents)
        } else {
            return
        }
    }
    

}


//
//  ViewControllerAdminRegister.swift
//  cTOM
//
//  Created by Conor O'Grady on 12/02/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import UIKit

class ViewControllerAdminRegister: UIViewController {
    
    
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var fnameField: UITextField!
    @IBOutlet weak var lnameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var retypedPasswordField: UITextField!
    
    @IBAction func registerAction(_ sender: UIButton) {
        
        if fnameField.text! == "" {
            createAlert(title: "Error", message: "First Name Field Is Empty!")
        } else if lnameField.text! == "" {
            createAlert(title: "Error", message: "Surname Field Is Empty!")
        } else if emailField.text! == "" {
            createAlert(title: "Error", message: "Email Field Is Empty!")
        } else if passwordField.text! == "" {
            createAlert(title: "Error", message: "Password Field Is Empty!")
        } else if retypedPasswordField.text! == "" {
            createAlert(title: "Error", message: "Please retype password!")
        } else if retypedPasswordField.text! != passwordField.text! {
            createAlert(title: "Error", message: "Passwords do not match!")
        } else if DBManager.checkEmailForRegister(email: emailField.text!, password: passwordField.text!, fName: fnameField.text!, lName: lnameField.text!) == false {
            errorMessage.isHidden = false
        } else {
            Trackers.adminLoggedIn = true
            Trackers.currentAdmin = DBManager.getCurrentAdmin(email: emailField.text!)
            Trackers.currentAdminEmail = emailField.text!
            self.performSegue(withIdentifier: "registerToHome", sender: self)
        }
    }
    // logic for when admin tries to login i.e. what alerts should display first etc.
    
    func createAlert (title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    // function to create alert

    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorMessage.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK:- Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

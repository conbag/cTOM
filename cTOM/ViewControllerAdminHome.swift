//
//  ViewControllerAdminHome.swift
//  cTOM
//
//  Created by Conor O'Grady on 12/02/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import UIKit

class ViewControllerAdminHome: UIViewController {

    
    @IBOutlet weak var testButtom: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var participantError: UILabel!
    @IBOutlet weak var selectParticipant: UITextField!
    @IBOutlet weak var currentAdmin: UILabel!
    
    var selectedParticipant: String?
    
    @IBAction func enterTestsButton(_ sender: UIButton) {
        if selectParticipant.text == "" {
            participantError.isHidden = false
        } else {
            self.performSegue(withIdentifier: "testsFromAdmin", sender: self)
        }
    }
    // if participant has not been selected display error message. Else move to tests scene
    
    @IBAction func logoutButton(_ sender: UIButton) {
        Trackers.adminLoggedIn = false
        Trackers.currentAdmin = nil
        Trackers.currentAdminEmail = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        participantError.isHidden = true
        // displayed when participant has not been selected
        DBManager.getAllAddedParticipants()
        createParticipantPicker()
        
        currentAdmin.text = "\(Trackers.currentAdminEmail!) is logged in"
        
        testButtom.layer.cornerRadius = 10
        testButtom.layer.borderWidth = 3
        
        selectParticipant.layer.borderWidth = 2
        selectParticipant.layer.cornerRadius = 8
        
        logoutButton.layer.cornerRadius = 10
        logoutButton.layer.borderWidth = 3
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createParticipantPicker() {
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewControllerAdminHome.dismissKeyboard))
        toolbar.setItems([done], animated: false)
        
        selectParticipant.inputAccessoryView = toolbar
        
        let genderPicker = UIPickerView()
        genderPicker.delegate = self
        
        selectParticipant.inputView = genderPicker
    }
    // creates participant picker
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    // dismiss keyboard when participant is picked

}

extension ViewControllerAdminHome: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DBManager.allParticipants.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return DBManager.allParticipants[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedParticipant = DBManager.allParticipants[row]
        selectParticipant.text = selectedParticipant
    }
}

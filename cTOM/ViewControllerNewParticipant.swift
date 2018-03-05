//
//  ViewControllerNewParticipant.swift
//  cTOM
//
//  Created by Conor O'Grady on 17/02/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import UIKit

class ViewControllerNewParticipant: UIViewController {
    
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var addParticipantButton: UIButton!
    
    
    let gender = ["Male", "Female"]
    var selectedGender: String?

    @IBAction func newParticipantButton(_ sender: UIButton) {
        
        if idField.text! == "" {
            createAlert(title: "Error", message: "Participant ID Field Is Empty!")
        } else if ageField.text! == "" {
            createAlert(title: "Error", message: "Date of Birth Field Is Empty!")
        } else if Int(ageField.text!) == nil {
            createAlert(title: "Error", message: "Please enter valid age!")
        } else if genderField.text! == "" {
            createAlert(title: "Error", message: "Gender Field Is Empty!")
        } else if DBManager.checkParticipantID(id: idField.text!, age: ageField.text!, gender: genderField.text!) == false {
            errorMessage.isHidden = false
        } else {
            DBManager.getAllAddedParticipants()
            self.performSegue(withIdentifier: "returnAfterNewParticipant", sender: self)
        }  
    }
    // logic for completing new participant form
    
    func createGenderPicker() {
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewControllerNewParticipant.dismissKeyboard))
        toolbar.setItems([done], animated: false)
        
        genderField.inputAccessoryView = toolbar
        
        let genderPicker = UIPickerView()
        genderPicker.delegate = self
        
        genderField.inputView = genderPicker
    }
    // creates male/female picker for when dobField is pressed
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    // dismiss keyboard when gender is picked
    
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

        createGenderPicker()
        
        addParticipantButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ViewControllerNewParticipant: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gender[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGender = gender[row]
        genderField.text = selectedGender
    }
}

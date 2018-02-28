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
    @IBOutlet weak var addParticipant: UIButton!
    
    
    var selectedParticipant: String?
    
    @IBAction func enterTestsButton(_ sender: UIButton) {
        if selectParticipant.text == "" || selectParticipant.text == "Select Participant" {
            participantError.isHidden = false
        } else {
            Trackers.currentParticipant = selectParticipant.text
            self.performSegue(withIdentifier: "testsFromAdmin", sender: self)
        }
    }
    // if participant has not been selected display error message. Else move to tests scene
    
    @IBAction func logoutButton(_ sender: UIButton) {
        Trackers.adminLoggedIn = false
        Trackers.currentAdmin = nil
        Trackers.currentAdminEmail = nil
    }
    
    @IBAction func exportResults(_ sender: UIButton) {
        
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = "ctomresults@gmail.com"
        smtpSession.password = "ctomNUIG"
        smtpSession.port = 465
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    print("Connectionlogger: \(string)")
                }
            }
        }
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: Trackers.currentAdminFirstName!, mailbox: Trackers.currentAdminEmail!)]
        // display name and email address are taken from current logged in admin
        builder.header.from = MCOAddress(displayName: "cTOM Results", mailbox: "ctomresults@gmail.com")
        builder.header.subject = "cTOM Results"
        builder.htmlBody="<p>Please find results in csv format attached</p>"
        
        let attachment = MCOAttachment()
        var dataCSV: Data?

        do {
            dataCSV = try Data(contentsOf: DBManager.createResultsCSV())
        } catch {
            print(error)
        }

        attachment.data = dataCSV
        attachment.filename = "results.csv"
        builder.addAttachment(attachment)
        // exporting results csv file generated in DBManager
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                print("Error sending email: \(error.debugDescription)")
            } else {
                print("Successfully sent email!")
            }
        }
    }
    // function to email results to Admin
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        participantError.isHidden = true
        // displayed when participant has not been selected
        DBManager.getAllAddedParticipants()
        createParticipantPicker()
        
        selectParticipant.text = "Select Participant"
        
        currentAdmin.text = "\(Trackers.currentAdminEmail!) is logged in"
        
        testButtom.layer.cornerRadius = 10
        testButtom.layer.borderWidth = 3
        
        addParticipant.layer.cornerRadius = 10
        addParticipant.layer.borderWidth = 3
        addParticipant.titleLabel?.adjustsFontSizeToFitWidth = true
        
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

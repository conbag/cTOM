//
//  ViewControllerResults.swift
//  cTOM
//
//  Created by Conor O'Grady on 02/03/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import UIKit

class ViewControllerResults: UIViewController {
    
    var gazeSummary: ResultSummary?
    var storiesSummary: ResultSummary?
    
    @IBOutlet weak var gazeView: UIView!
    @IBOutlet weak var storiesView: UIView!
    // views for summary results
    
    @IBOutlet weak var gazeSession: UILabel!
    @IBOutlet weak var gazeParticipant: UILabel!
    @IBOutlet weak var gazeDate: UILabel!
    @IBOutlet weak var gazeAccuracy: UILabel!
    @IBOutlet weak var gazeReaction: UILabel!
    // gaze result fields
    
    @IBOutlet weak var storiesSession: UILabel!
    @IBOutlet weak var storiesParticipant: UILabel!
    @IBOutlet weak var storiesDate: UILabel!
    @IBOutlet weak var storiesAccuracy: UILabel!
    @IBOutlet weak var storiesReaction: UILabel!
    // stories result fields

    @IBOutlet weak var resultEmail: UITextField!
    @IBOutlet weak var emailErrorMsg: UILabel!
    @IBAction func exportResultsButton(_ sender: UIButton) {
    // button, text field and error message for exporting results
        
        if resultEmail.text == "" {
            emailErrorMsg.isHidden = false
        } else {
        
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
            builder.header.to = [MCOAddress(displayName: Trackers.currentAdminFirstName!, mailbox: resultEmail.text)]
            // display name is takenfrom current logged in admin. Email is passed in through text field
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
                    self.createAlert(title: "Sending Failed", message: "Please check internet connection and/or entered email address!")
                    // alert that pops up on screen for user if email fails
                    
                    print("Error sending email: \(error.debugDescription)")
                } else {
                    self.createAlert(title: "Success", message: "Email has been sent!")
                    // alert that pops up on screen for user if email is success
                    
                    print("Successfully sent email!")
                }
            }
        }
    }
    // function to email results to Admin
    
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
        
        emailErrorMsg.isHidden = true
        gazeView.layer.borderWidth = 3
        storiesView.layer.borderWidth = 3
        
        if DBManager.checkForNoSession(test: 1) == false {
            gazeSummary = DBManager.getLatestResultSummary(test: 1)
            
            gazeSession.text = String(gazeSummary!.getSessionID())
            gazeParticipant.text = gazeSummary!.getParticipantID()
            gazeDate.text = gazeSummary!.getDate()
            gazeAccuracy.text = gazeSummary!.getAccuracyMeasure()
            gazeReaction.text = gazeSummary!.getMeanReaction()
        }
        
        if DBManager.checkForNoSession(test: 2) == false {
            storiesSummary = DBManager.getLatestResultSummary(test: 2)
            
            storiesSession.text = String(storiesSummary!.getSessionID())
            storiesParticipant.text = storiesSummary!.getParticipantID()
            storiesDate.text = storiesSummary!.getDate()
            storiesAccuracy.text = storiesSummary!.getAccuracyMeasure()
            storiesReaction.text = storiesSummary!.getMeanReaction()
        }
        
        // checks that results data exists and, if so, populates fields appropriately.
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

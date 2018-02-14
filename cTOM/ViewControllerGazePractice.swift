//
//  ViewControllerGazePractice.swift
//  cTOM
//
//  Created by Conor O'Grady on 05/02/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import UIKit

class ViewControllerGazePractice: UIViewController {
    

    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var straightInstruction: UILabel!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    
    var buttonTag: Int?
    
    
    @IBAction func beginPractice(_ sender: UIButton) {
        
        rightButton.isHidden = false
        centerButton.isHidden = false
        
        sender.isEnabled = false
        sender.isHidden = true
        
    }
    // Initial button to begin parctice. Hidden and disabled once pressed
    
    
    @IBAction func practiceButton(_ sender: UIButton) {
        if sender.tag == buttonTag! {
            
            sender.isHidden = true
            
            if sender.tag == 1 {
                buttonTag! += 1
                
                self.view.viewWithTag(buttonTag!)?.isHidden = false
                let button = self.view.viewWithTag(4) as? UIButton
                let img = UIImage(named: "c-TOM_Gaze_practice_looking_left")
                
                button?.setBackgroundImage(img, for: .normal)
            } else if sender.tag == 2 {
                buttonTag! += 1
                
                self.view.viewWithTag(buttonTag!)?.isHidden = false
                let button = self.view.viewWithTag(4) as? UIButton
                let img = UIImage(named: "c-TOM_Gaze_practice_looking_up")
                
                button?.setBackgroundImage(img, for: .normal)
            } else if sender.tag == 3 {
                buttonTag! += 1
                self.view.viewWithTag(buttonTag!)?.isHidden = false
                
                straightInstruction.isHidden = false
                let button = self.view.viewWithTag(4) as? UIButton
                let img = UIImage(named: "c-TOM_Gaze_practice_looking_straight_ahead")
                
                button?.setBackgroundImage(img, for: .normal)
            } else {
                buttonTag = 1
                readyButton.isEnabled = true
                readyButton.isHidden = false
                
                straightInstruction.isHidden = true
            }
        }
    }
    // logic for displaying and hiding the various practice buttons and changing centre image


    override func viewDidLoad() {
        super.viewDidLoad()
        
        readyButton.isEnabled = false
        readyButton.isHidden = true
        readyButton.layer.cornerRadius = 10
        
        leftButton.isHidden = true
        leftButton.layer.cornerRadius = 15
        
        rightButton.isHidden = true
        rightButton.layer.cornerRadius = 15
        
        topButton.isHidden = true
        topButton.layer.cornerRadius = 15
        
        centerButton.isHidden = true
        
        straightInstruction.isHidden = true

        buttonTag = 1
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

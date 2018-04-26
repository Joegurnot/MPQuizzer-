//
//  SinglePlayerVC.swift
//  MPQuizzer-
//
//  Created by Robert Grizzard on 4/25/18.
//  Copyright © 2018 Robert Grizzard. All rights reserved.
//

import UIKit

class SinglePlayerVC: UIViewController {
    
    var myJSONHandler = JSONHandler()
    
    var myNumQuestions: Int!

    @IBOutlet weak var numQuestionsLbl: UILabel!
    
    @IBOutlet weak var questionLbl: UILabel!
    
    @IBOutlet weak var aLbl: UILabel!
    @IBOutlet weak var bLbl: UILabel!
    @IBOutlet weak var cLbl: UILabel!
    @IBOutlet weak var dLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myJSONHandler = JSONHandler()
        
        myJSONHandler.setupUIElements(myQuestionCounterLbl: numQuestionsLbl, myQuestionLbl: questionLbl, myALbl: aLbl, myBLbl: bLbl, myCLbl: cLbl, myDLbl: dLbl)
        
        let aLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(aLabelTap(sender:)))
        aLbl.addGestureRecognizer(aLabelTapGestureRecognizer)
        
        let bLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bLabelTap(sender:)))
        bLbl.addGestureRecognizer(bLabelTapGestureRecognizer)
        
        let cLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cLabelTap(sender:)))
        cLbl.addGestureRecognizer(cLabelTapGestureRecognizer)
        
        let dLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dLabelTap(sender:)))
        dLbl.addGestureRecognizer(dLabelTapGestureRecognizer)

        // Do any additional setup after loading the view.
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

    @IBAction func getJsonTapped(_ sender: UIButton) {
        myJSONHandler.testGrabJSON()
        if (myJSONHandler.gameOver) {
            sender.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                sender.isUserInteractionEnabled = true
                let temporaryAlert = UIAlertController(title: "ALERT", message: "Handle end of game", preferredStyle: .alert)
                temporaryAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(temporaryAlert, animated: true, completion: nil)
            }
            
        }
    }
    
    @objc func aLabelTap(sender: UILabel) {
        print("A tapped! \(aLbl.text!)")
    }
    
    @objc func bLabelTap(sender: UILabel) {
        print("B tapped! \(bLbl.text!)")
    }
    
    @objc func cLabelTap(sender: UILabel) {
        print("C tapped! \(cLbl.text!)")
    }
    
    @objc func dLabelTap(sender: UILabel) {
        print("D tapped!  \(dLbl.text!)")
    }
    
    
    
}

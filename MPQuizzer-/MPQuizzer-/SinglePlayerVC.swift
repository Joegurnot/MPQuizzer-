//
//  SinglePlayerVC.swift
//  MPQuizzer-
//
//  Created by Robert Grizzard on 4/25/18.
//  Copyright © 2018 Robert Grizzard. All rights reserved.
//

import UIKit
import CoreMotion

class SinglePlayerVC: UIViewController {
    
    var myJSONHandler = JSONHandler()
    
    var myNumQuestions: Int!
    
    var correctAnswer: String!
    
    var motionManager = CMMotionManager()

    @IBOutlet weak var numQuestionsLbl: UILabel!
    
    @IBOutlet weak var questionLbl: UILabel!
    
    @IBOutlet weak var aLbl: UILabel!
    @IBOutlet weak var bLbl: UILabel!
    @IBOutlet weak var cLbl: UILabel!
    @IBOutlet weak var dLbl: UILabel!
    
    @IBOutlet weak var scoreLbl: UILabel!
    
    @IBOutlet weak var timerLbl: UILabel!
    
    var hiddenCorrectAnswerLbl: UILabel = UILabel(frame: CGRect(x: 1, y: 1, width: 1, height: 1))
    
    var timer: Timer!
    //var secondsLeft: Int = 20
    var secondsLeft: Int = 5
    
    var score: Int = 0
    
    var firstTappedLbl: UILabel?
    var secondTappedLbl: UILabel?
    
    var attitude: CMAttitude!
    var startAttitude: CMAttitude!
    var firstPosition: Bool = true
    
    var motionTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myJSONHandler = JSONHandler()
        
        hiddenCorrectAnswerLbl.isHidden = true
        
        myJSONHandler.setupUIElements(myQuestionCounterLbl: numQuestionsLbl, myQuestionLbl: questionLbl, myALbl: aLbl, myBLbl: bLbl, myCLbl: cLbl, myDLbl: dLbl, myHiddenCorrectLbl: hiddenCorrectAnswerLbl )
        
        let aLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(aLabelTap(sender:)))
        aLbl.addGestureRecognizer(aLabelTapGestureRecognizer)
        
        let bLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bLabelTap(sender:)))
        bLbl.addGestureRecognizer(bLabelTapGestureRecognizer)
        
        let cLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cLabelTap(sender:)))
        cLbl.addGestureRecognizer(cLabelTapGestureRecognizer)
        
        let dLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dLabelTap(sender:)))
        dLbl.addGestureRecognizer(dLabelTapGestureRecognizer)
        
        //timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: true)
        
        nextQuestion()
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        motionManager.deviceMotionUpdateInterval = 1/60
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical)
        
        motionTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateDeviceMotion), userInfo: nil, repeats: true)
    }
    
    @objc func timerHandler() {
        timerLbl.text = "Seconds: \(secondsLeft)"
        secondsLeft -= 1
        if secondsLeft == -1 {
            timer.invalidate()
            //secondsLeft = 20
            secondsLeft = 5
            
            enableChoiceLbls()
            unsetFirstAndSecondTap()
            nextQuestion()
        }
        print("secondsLeft: \(secondsLeft)")
    }
    
    @objc func updateDeviceMotion(){
        
        if let data = motionManager.deviceMotion {
            
            attitude = data.attitude
            
            if (firstPosition == true) {
                startAttitude = attitude
                firstPosition = false
            }
            
            let userAcceleration = data.userAcceleration
            print("\n\nZ ACC: \(userAcceleration.z)")
            if (userAcceleration.z < -2.5) {
                if let tempFirstTap = firstTappedLbl {
                    switch tempFirstTap {
                    case aLbl:
                        aLabelTap(sender: aLbl)
                    case bLbl:
                        bLabelTap(sender: bLbl)
                    case cLbl:
                        cLabelTap(sender: cLbl)
                    case dLbl:
                        dLabelTap(sender: dLbl)
                    default:
                        print("Unexpected default in z-accel")
                    }
                }
            }
            
            //let gravity = data.gravity
            
            //let rotation = data.rotationRate
            
            print("pitch: \(attitude.pitch), roll: \(attitude.roll), yaw: \(attitude.yaw)")
            
            
            //var str = "Pitch: \(attitude.pitch)\n Roll: \(attitude.roll) \nYaw: \(attitude.yaw)"
            
            if ((startAttitude.pitch - attitude.pitch) < -0.25) {
                print("\n\nPITCH UP!")
                pitchUP()
            }
            else if ((startAttitude.pitch - attitude.pitch) > 0.25) {
                print("\n\nPITCH DOWN!")
                pitchDown()
            }
            
            if ((startAttitude.roll - attitude.roll) < -0.2) {
                print("\n\nROLL RIGHT!")
                rollRight()
            }
            else if ((startAttitude.roll - attitude.roll) > 0.8) {
                print("\n\nROLL LEFT!")
                rollLeft()
            }
        }
    }
    
    func pitchUP() {
        if (aLbl.backgroundColor == UIColor.yellow) {
            cLabelTap(sender: cLbl)
        }
        else if (bLbl.backgroundColor == UIColor.yellow) {
            dLabelTap(sender: dLbl)
        }
    }
    func pitchDown() {
        if (cLbl.backgroundColor == UIColor.yellow) {
            aLabelTap(sender: aLbl)
        }
        else if (dLbl.backgroundColor == UIColor.yellow) {
            bLabelTap(sender: bLbl)
        }
    }
    
    func rollLeft() {
        if (bLbl.backgroundColor == UIColor.yellow) {
            aLabelTap(sender: aLbl)
        }
        else if (dLbl.backgroundColor == UIColor.yellow) {
            cLabelTap(sender: cLbl)
        }
    }
    
    func rollRight() {
        if (aLbl.backgroundColor == UIColor.yellow) {
            bLabelTap(sender: bLbl)
        }
        else if (cLbl.backgroundColor == UIColor.yellow) {
            dLabelTap(sender: dLbl)
        }
    }

    func updateScore() {
        animateScoreLabel()
        scoreLbl.text = "Your score: \(score)"
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

    /*
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
    */
    
    func nextQuestion() {
        myJSONHandler.testGrabJSON()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: true)
        clearSubmission()
        if (myJSONHandler.gameOver) {
            timer.invalidate()
            //_ = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(gameOverHandler), userInfo: nil, repeats: false)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(lastQuestionTimerHandler), userInfo: nil, repeats: true)
        }
    }
    
    @objc func lastQuestionTimerHandler() {
        timerLbl.text = "Seconds: \(secondsLeft)"
        secondsLeft -= 1
        if (secondsLeft == -1) {
            timer.invalidate()
            //secondsLeft = 20
            secondsLeft = 5
            
            gameOverHandler()
        }
    }
    
    @objc func gameOverHandler() {
        let temporaryAlert = UIAlertController(title: "ALERT", message: "Handle end of game", preferredStyle: .alert)
        //temporaryAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        temporaryAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (alert: UIAlertAction!) in
            self.myJSONHandler.currentQuestion = 0
            self.myJSONHandler.currentURLIndex += 1
            if (self.myJSONHandler.currentURLIndex == self.myJSONHandler.arrayOfURLs.count) {
                self.myJSONHandler.currentURLIndex = 0
            }
            self.myJSONHandler.gameOver = false
            self.enableChoiceLbls()
            self.unsetFirstAndSecondTap()
            self.nextQuestion()
        }))
        //self.present(temporaryAlert, animated: true, completion: {})
        self.present(temporaryAlert, animated: true, completion: nil)
    }
    
    @objc func aLabelTap(sender: UILabel) {
        print("A tapped! \(aLbl.text!)")
        if let tempFirstTappedLbl = firstTappedLbl {
            if tempFirstTappedLbl == aLbl {
                disableChoiceLbls()
                if (aLbl.backgroundColor == UIColor.blue) {
                    
                }
                else {
                    aLbl.backgroundColor = UIColor.blue
                    checkSubmissionForCorrectness(lbl: aLbl)
                    print("Submit: \(tempFirstTappedLbl.text!)")
                }
            }
            else {
                firstTappedLbl = aLbl
                highlightSelection(lbl: aLbl)
            }
        }
        if firstTappedLbl == nil {
            firstTappedLbl = aLbl
            highlightSelection(lbl: aLbl)
        }
    }
    
    @objc func bLabelTap(sender: UILabel) {
        print("B tapped! \(bLbl.text!)")
        if let tempFirstTappedLbl = firstTappedLbl {
            if tempFirstTappedLbl == bLbl {
                disableChoiceLbls()
                if (bLbl.backgroundColor == UIColor.blue) {
                    
                }
                else {
                    bLbl.backgroundColor = UIColor.blue
                    checkSubmissionForCorrectness(lbl: bLbl)
                    print("Submit: \(tempFirstTappedLbl.text!)")
                }
            }
            else {
                firstTappedLbl = bLbl
                highlightSelection(lbl: bLbl)
            }
        }
        if firstTappedLbl == nil {
            firstTappedLbl = bLbl
            highlightSelection(lbl: bLbl)
        }
    }
    
    @objc func cLabelTap(sender: UILabel) {
        print("C tapped! \(cLbl.text!)")
        if let tempFirstTappedLbl = firstTappedLbl {
            if tempFirstTappedLbl == cLbl {
                disableChoiceLbls()
                if (cLbl.backgroundColor == UIColor.blue) {
                    
                }
                else {
                    cLbl.backgroundColor = UIColor.blue
                    checkSubmissionForCorrectness(lbl: cLbl)
                    print("Submit: \(tempFirstTappedLbl.text!)")
                }
            }
            else {
                firstTappedLbl = cLbl
                highlightSelection(lbl: cLbl)
            }
        }
        if firstTappedLbl == nil {
            firstTappedLbl = cLbl
            highlightSelection(lbl: cLbl)
        }
    }
    
    @objc func dLabelTap(sender: UILabel) {
        print("D tapped!  \(dLbl.text!)")
        if let tempFirstTappedLbl = firstTappedLbl {
            if tempFirstTappedLbl == dLbl {
                disableChoiceLbls()
                if (dLbl.backgroundColor == UIColor.blue) {
                    
                }
                else {
                    dLbl.backgroundColor = UIColor.blue
                    checkSubmissionForCorrectness(lbl: dLbl)
                    print("Submit: \(tempFirstTappedLbl.text!)")
                }
            }
            else {
                firstTappedLbl = dLbl
                highlightSelection(lbl: dLbl)
            }
        }
        if firstTappedLbl == nil {
            firstTappedLbl = dLbl
            highlightSelection(lbl: dLbl)
        }
    }
    
    func disableChoiceLbls() {
        aLbl.isUserInteractionEnabled = false
        bLbl.isUserInteractionEnabled = false
        cLbl.isUserInteractionEnabled = false
        dLbl.isUserInteractionEnabled = false
    }
    
    func enableChoiceLbls() {
        aLbl.isUserInteractionEnabled = true
        bLbl.isUserInteractionEnabled = true
        cLbl.isUserInteractionEnabled = true
        dLbl.isUserInteractionEnabled = true
    }
    
    func unsetFirstAndSecondTap() {
        firstTappedLbl = nil
        secondTappedLbl = nil
    }
    
    func highlightSelection(lbl: UILabel) {
        aLbl.backgroundColor = UIColor.clear
        bLbl.backgroundColor = UIColor.clear
        cLbl.backgroundColor = UIColor.clear
        dLbl.backgroundColor = UIColor.clear
        
        lbl.backgroundColor = UIColor.yellow
    }
    
    func clearSubmission() {
        aLbl.backgroundColor = UIColor.clear
        bLbl.backgroundColor = UIColor.clear
        cLbl.backgroundColor = UIColor.clear
        dLbl.backgroundColor = UIColor.clear
    }
    
    func checkSubmissionForCorrectness(lbl: UILabel) {
        if let tempLblText = lbl.text,
            let tempHiddenCorrectLblText = hiddenCorrectAnswerLbl.text {
            if tempLblText == tempHiddenCorrectLblText {
                score += 1
                updateScore()
            }
        }
    }
    
    func animateScoreLabel() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
            self.scoreLbl.frame.origin.x += 50
        }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: 0.1, options: [], animations: {
            self.scoreLbl.frame.origin.x -= 100
        }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: 0.3, options: [], animations: {
            self.scoreLbl.frame.origin.x += 100
        }, completion: nil)
        UIView.animate(withDuration: 0.1, delay: 0.4, options: [], animations: {
            self.scoreLbl.frame.origin.x -= 50
        }, completion: nil)
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        if motion == .motionShake {
            var rand = arc4random_uniform(4)
            while((rand == 0 && aLbl.backgroundColor == UIColor.yellow) ||
                (rand == 1 && bLbl.backgroundColor == UIColor.yellow) ||
                (rand == 2 && cLbl.backgroundColor == UIColor.yellow) ||
                (rand == 3 && dLbl.backgroundColor == UIColor.yellow)) {
                    rand = arc4random_uniform(4)
            }
            switch rand {
            case 0:
                aLabelTap(sender: aLbl)
            case 1:
                bLabelTap(sender: bLbl)
            case 2:
                cLabelTap(sender: cLbl)
            case 3:
                dLabelTap(sender: dLbl)
            default:
                print("Unexpected default in shake gesture")
            }
        }
    }
    
    
    
}

//
//  MultiPlayerVC.swift
//  MPQuizzer-
//
//  Created by Robert Grizzard on 5/2/18.
//  Copyright © 2018 Robert Grizzard. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreMotion

class MultiPlayerVC: UIViewController, MCSessionDelegate {
    
    @IBOutlet weak var myAnswerLbl: UILabel!
    @IBOutlet weak var pOneAnswerLbl: UILabel!
    @IBOutlet weak var pTwoAnswerLbl: UILabel!
    @IBOutlet weak var pThreeAnswerLbl: UILabel!
    
    @IBOutlet weak var pOneView: UIView!
    @IBOutlet weak var pTwoView: UIView!
    @IBOutlet weak var pThreeView: UIView!
    
    
    @IBOutlet weak var myScoreLbl: UILabel!
    @IBOutlet weak var pOneScoreLbl: UILabel!
    @IBOutlet weak var pTwoScoreLbl: UILabel!
    @IBOutlet weak var pThreeScoreLbl: UILabel!
    
    @IBOutlet weak var numQuestionsLbl: UILabel!
    
    @IBOutlet weak var questionLbl: UILabel!
    
    @IBOutlet weak var ALbl: UILabel!
    @IBOutlet weak var BlBl: UILabel!
    @IBOutlet weak var CLbl: UILabel!
    @IBOutlet weak var DLbl: UILabel!
    
    @IBOutlet weak var timerLbl: UILabel!
    
    var hiddenCorrectAnswerLbl: UILabel = UILabel(frame: CGRect(x: 1, y: 1, width: 1, height: 1))
    
    var myJSONHandler = JSONHandler()
    
    var numQuestions: Int!
    
    var correctAnswer: String!
    
    var motionManager = CMMotionManager()
    
    var motionTimer: Timer!
    
    var attitude: CMAttitude!
    var startAttitude: CMAttitude!
    var firstPosition: Bool = true
    
    var timer: Timer!
    //var secondsLeft: Int = 20
    var secondsLeft: Int = 5
    
    var firstTappedLbl: UILabel?
    var secondTappedLbl: UILabel?
    
    var myScore: Int = 0
    var pOneScore: Int = 0
    var pTwoScore: Int = 0
    var pThreeScore: Int = 0
    
    var myAnswer: String!
    var pOneAnswer: String!
    var pTwoAnswer: String!
    var pThreeAnswer: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMultipeerHandler.session.delegate = self

        myJSONHandler = JSONHandler()
        
        hiddenCorrectAnswerLbl.isHidden = true
        
        myJSONHandler.setupUIElements(myQuestionCounterLbl: numQuestionsLbl, myQuestionLbl: questionLbl, myALbl: ALbl, myBLbl: BlBl, myCLbl: CLbl, myDLbl: DLbl, myHiddenCorrectLbl: hiddenCorrectAnswerLbl)
        
        let aLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(aLabelTap(sender:)))
        ALbl.addGestureRecognizer(aLabelTapGestureRecognizer)
        
        let bLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bLabelTap(sender:)))
        BlBl.addGestureRecognizer(bLabelTapGestureRecognizer)
        
        let cLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cLabelTap(sender:)))
        CLbl.addGestureRecognizer(cLabelTapGestureRecognizer)
        
        let dLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dLabelTap(sender:)))
        DLbl.addGestureRecognizer(dLabelTapGestureRecognizer)
        
        print("\n\n\(myMultipeerHandler.session.connectedPeers)")
        
        updatePlayerImages()
        
        nextQuestion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        motionManager.deviceMotionUpdateInterval = 1/60
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical)
        
        motionTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateDeviceMotion), userInfo: nil, repeats: true)
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
                    case ALbl:
                        aLabelTap(sender: ALbl)
                    case BlBl:
                        bLabelTap(sender: ALbl)
                    case CLbl:
                        cLabelTap(sender: CLbl)
                    case DLbl:
                        dLabelTap(sender: DLbl)
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
        if (ALbl.backgroundColor == UIColor.yellow) {
            cLabelTap(sender: CLbl)
        }
        else if (BlBl.backgroundColor == UIColor.yellow) {
            dLabelTap(sender: DLbl)
        }
    }
    func pitchDown() {
        if (CLbl.backgroundColor == UIColor.yellow) {
            aLabelTap(sender: ALbl)
        }
        else if (DLbl.backgroundColor == UIColor.yellow) {
            bLabelTap(sender: BlBl)
        }
    }
    
    func rollLeft() {
        if (BlBl.backgroundColor == UIColor.yellow) {
            aLabelTap(sender: ALbl)
        }
        else if (DLbl.backgroundColor == UIColor.yellow) {
            cLabelTap(sender: CLbl)
        }
    }
    
    func rollRight() {
        if (ALbl.backgroundColor == UIColor.yellow) {
            bLabelTap(sender: BlBl)
        }
        else if (CLbl.backgroundColor == UIColor.yellow) {
            dLabelTap(sender: BlBl)
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    /*
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Session receieved data!")
        
        DispatchQueue.main.async {
            if let receievedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? String{
                for i in 0..<myMultipeerHandler.session.connectedPeers.count {
                    if (peerID == myMultipeerHandler.session.connectedPeers[i]) {
                        switch i {
                        case 0:
                            self.pOneAnswerLbl.text = receievedData
                        case 1:
                            self.pTwoAnswerLbl.text = receievedData
                        case 2:
                            self.pThreeAnswerLbl.text = receievedData
                        default:
                            print("unexpected default when receiving string data")
                        }
                        
                    }
                }
            }
            if let receivedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? Bool {
                for i in 0..<myMultipeerHandler.session.connectedPeers.count {
                    if (peerID == myMultipeerHandler.session.connectedPeers[i]) {
                        switch i {
                        case 0:
                            if receivedData == true {
                                self.pOneScore += 1
                                self.pOneScoreLbl.text = "\(self.pOneScore)"
                            }
                        case 1:
                            if receivedData == true {
                                self.pTwoScore += 1
                                self.pTwoScoreLbl.text = "\(self.pTwoScore)"
                            }
                        case 2:
                            if receivedData == true {
                                self.pThreeScore += 1
                                self.pThreeScoreLbl.text = "\(self.pThreeScore)"
                            }
                        default:
                            print("unexpected default when receiving bool data")
                        }
                    }
                }
            }
        }
    }
    */
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            if let receivedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? String {
                for i in 0..<myMultipeerHandler.session.connectedPeers.count {
                    if (peerID == myMultipeerHandler.session.connectedPeers[i]) {
                        switch i {
                        case 0:
                            self.pOneAnswer = receivedData
                        case 1:
                            self.pTwoAnswer = receivedData
                        case 2:
                            self.pThreeAnswer = receivedData
                        default:
                            print("unexpected default when receiving string data")
                        }
                        
                    }
                }
            }
            if let receivedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? Bool {
                for i in 0..<myMultipeerHandler.session.connectedPeers.count {
                    if (peerID == myMultipeerHandler.session.connectedPeers[i]) {
                        switch i {
                        case 0:
                            if receivedData == true {
                                self.pOneScore += 1
                                //self.pOneScoreLbl.text = "\(self.pOneScore)"
                            }
                        case 1:
                            if receivedData == true {
                                self.pTwoScore += 1
                                //self.pTwoScoreLbl.text = "\(self.pTwoScore)"
                            }
                        case 2:
                            if receivedData == true {
                                self.pThreeScore += 1
                                //self.pThreeScoreLbl.text = "\(self.pThreeScore)"
                            }
                        default:
                            print("unexpected default when receiving bool data")
                        }
                    }
                }
            }
        }
    }
    
    func handleEndOfQuestion() {
        if (ALbl.text == hiddenCorrectAnswerLbl.text) {
            ALbl.backgroundColor = UIColor.green
        }
        else if (BlBl.text == hiddenCorrectAnswerLbl.text) {
            BlBl.backgroundColor = UIColor.green
        }
        else if (CLbl.text == hiddenCorrectAnswerLbl.text) {
            CLbl.backgroundColor = UIColor.green
        }
        else if (DLbl.text == hiddenCorrectAnswerLbl.text) {
            DLbl.backgroundColor = UIColor.green
        }
        myAnswerLbl.text = myAnswer
        if let tempPOneAnswer = pOneAnswer {
            pOneAnswerLbl.text = tempPOneAnswer
        }
        if let tempPTwoAnswer = pTwoAnswer {
            pTwoAnswerLbl.text = tempPTwoAnswer
        }
        if let tempPThreeAnswer = pThreeAnswer {
            pThreeAnswerLbl.text = tempPThreeAnswer
        }
        myScoreLbl.text = "\(myScore)"
        pOneScoreLbl.text = "\(pOneScore)"
        pTwoScoreLbl.text = "\(pTwoScore)"
        pThreeScoreLbl.text = "\(pThreeScore)"
        
    }
    
    //Not used
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    //Not used
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    //Not used
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    @objc func timerHandler() {
        timerLbl.text = "Seconds: \(secondsLeft)"
        secondsLeft -= 1
        if secondsLeft == -1 {
            timer.invalidate()
            //secondsLeft = 20
            secondsLeft = 5
            
            handleEndOfQuestion()
            Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(endOfQuestionTimerHandler), userInfo: nil, repeats: false)
            
            //enableChoiceLbls()
            //unsetFirstAndSecondTap()
            //nextQuestion()
        }
        print("secondsLeft: \(secondsLeft)")
    }
    
    @objc func endOfQuestionTimerHandler() {
        enableChoiceLbls()
        unsetFirstAndSecondTap()
        nextQuestion()
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
        temporaryAlert.addAction(UIAlertAction(title: "Quit", style: .default, handler: { (alert: UIAlertAction!) in
            myMultipeerHandler.session.disconnect()
            self.performSegue(withIdentifier: "unwindToVC", sender: self)
        }))
        temporaryAlert.addAction(UIAlertAction(title: "Play Again", style: .cancel, handler: { (alert: UIAlertAction!) in
            self.myJSONHandler.currentQuestion = 0
            self.myJSONHandler.currentURLIndex += 1
            self.myJSONHandler.gameOver = false
            self.enableChoiceLbls()
            self.unsetFirstAndSecondTap()
            self.nextQuestion()
        }))
        self.present(temporaryAlert, animated: true, completion: nil)
    }
    
    func nextQuestion() {
        clearAnswerLbls()
        myJSONHandler.testGrabJSON()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: true)
        clearSubmission()
        if (myJSONHandler.gameOver) {
            timer.invalidate()
            //_ = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(gameOverHandler), userInfo: nil, repeats: false)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(lastQuestionTimerHandler), userInfo: nil, repeats: true)
        }
    }
    
    @objc func aLabelTap(sender: UILabel) {
        if let tempFirstTappedLbl = firstTappedLbl {
            if tempFirstTappedLbl == ALbl {
                disableChoiceLbls()
                if (ALbl.backgroundColor == UIColor.blue) {
                    
                }
                else {
                    ALbl.backgroundColor = UIColor.blue
                    checkMyTapForCorrectness(lbl: ALbl)
                    print("Submit: \(tempFirstTappedLbl.text!)")
                    sendAnswer(lbl: ALbl)
                }
            }
            else {
                firstTappedLbl = ALbl
                highlightSelection(lbl: ALbl)
            }
        }
        if firstTappedLbl == nil {
            firstTappedLbl = ALbl
            highlightSelection(lbl: ALbl)
        }
    }
    
    @objc func bLabelTap(sender: UILabel) {
        print("B tapped! \(BlBl.text!)")
        if let tempFirstTappedLbl = firstTappedLbl {
            if tempFirstTappedLbl == BlBl {
                disableChoiceLbls()
                if (BlBl.backgroundColor == UIColor.blue) {
                    
                }
                else {
                    BlBl.backgroundColor = UIColor.blue
                    checkMyTapForCorrectness(lbl: BlBl)
                    print("Submit: \(tempFirstTappedLbl.text!)")
                    sendAnswer(lbl: BlBl)
                }
            }
            else {
                firstTappedLbl = BlBl
                highlightSelection(lbl: BlBl)
            }
        }
        if firstTappedLbl == nil {
            firstTappedLbl = BlBl
            highlightSelection(lbl: BlBl)
        }
    }
    
    @objc func cLabelTap(sender: UILabel) {
        print("C tapped! \(CLbl.text!)")
        if let tempFirstTappedLbl = firstTappedLbl {
            if tempFirstTappedLbl == CLbl {
                disableChoiceLbls()
                if (CLbl.backgroundColor == UIColor.blue) {
                    
                }
                else {
                    CLbl.backgroundColor = UIColor.blue
                    checkMyTapForCorrectness(lbl: CLbl)
                    print("Submit: \(tempFirstTappedLbl.text!)")
                    sendAnswer(lbl: CLbl)
                }
            }
            else {
                firstTappedLbl = CLbl
                highlightSelection(lbl: CLbl)
            }
        }
        if firstTappedLbl == nil {
            firstTappedLbl = CLbl
            highlightSelection(lbl: CLbl)
        }
    }
    
    @objc func dLabelTap(sender: UILabel) {
        print("D tapped!  \(DLbl.text!)")
        if let tempFirstTappedLbl = firstTappedLbl {
            if tempFirstTappedLbl == DLbl {
                disableChoiceLbls()
                if (DLbl.backgroundColor == UIColor.blue) {
                    
                }
                else {
                    DLbl.backgroundColor = UIColor.blue
                    checkMyTapForCorrectness(lbl: DLbl)
                    print("Submit: \(tempFirstTappedLbl.text!)")
                    sendAnswer(lbl: DLbl)
                }
            }
            else {
                firstTappedLbl = DLbl
                highlightSelection(lbl: DLbl)
            }
        }
        if firstTappedLbl == nil {
            firstTappedLbl = DLbl
            highlightSelection(lbl: DLbl)
        }
    }
    
    func disableChoiceLbls() {
        ALbl.isUserInteractionEnabled = false
        BlBl.isUserInteractionEnabled = false
        CLbl.isUserInteractionEnabled = false
        DLbl.isUserInteractionEnabled = false
    }
    
    func enableChoiceLbls() {
        ALbl.isUserInteractionEnabled = true
        BlBl.isUserInteractionEnabled = true
        CLbl.isUserInteractionEnabled = true
        DLbl.isUserInteractionEnabled = true
    }
    
    func unsetFirstAndSecondTap() {
        firstTappedLbl = nil
        secondTappedLbl = nil
    }
    
    func highlightSelection(lbl: UILabel) {
        ALbl.backgroundColor = UIColor.clear
        BlBl.backgroundColor = UIColor.clear
        CLbl.backgroundColor = UIColor.clear
        DLbl.backgroundColor = UIColor.clear
        
        lbl.backgroundColor = UIColor.yellow
    }
    
    func clearSubmission() {
        ALbl.backgroundColor = UIColor.clear
        BlBl.backgroundColor = UIColor.clear
        CLbl.backgroundColor = UIColor.clear
        DLbl.backgroundColor = UIColor.clear
    }
    
    func checkMyTapForCorrectness(lbl: UILabel) {
        if var lblText = lbl.text {
            let charForMyAnswerLbl = lblText.remove(at: lblText.startIndex)
            myAnswer = "\(charForMyAnswerLbl)"
            //myAnswerLbl.text = "\(charForMyAnswerLbl)"
        }
        if let tempLblText = lbl.text,
            let tempHiddenCorrectLblText = hiddenCorrectAnswerLbl.text {
            if tempLblText == tempHiddenCorrectLblText {
                myScore += 1
                //myScoreLbl.text = "\(myScore)"
            }
        }
    }
    
    func checkSubmissionForCorrectness(lbl: UILabel) -> Bool {
        var toReturn: Bool = false
        if let tempLblText = lbl.text,
            let tempHiddenCorrectLblText = hiddenCorrectAnswerLbl.text {
            if tempLblText == tempHiddenCorrectLblText {
                //myScore += 1
                //myScoreLbl.text = "\(myScore)"
                toReturn = true
            }
        }
        return toReturn
    }
    
    func sendAnswer(lbl: UILabel) {
        var str = lbl.text!
        let msg = "\(str.remove(at: str.startIndex))"
        print("message: \(msg)")
        let correctNess: Bool = checkSubmissionForCorrectness(lbl: lbl)
        let strToSend = NSKeyedArchiver.archivedData(withRootObject: msg)
        let boolToSend = NSKeyedArchiver.archivedData(withRootObject: correctNess)
        do {
            try myMultipeerHandler.session.send(strToSend, toPeers: myMultipeerHandler.session.connectedPeers, with: .unreliable)
            try myMultipeerHandler.session.send(boolToSend, toPeers: myMultipeerHandler.session.connectedPeers, with: .unreliable)
        }
        catch let err {
            print("error: \(err)")
        }
    }
    
    func clearAnswerLbls() {
        myAnswerLbl.text = ""
        pOneAnswerLbl.text = ""
        pTwoAnswerLbl.text = ""
        pThreeAnswerLbl.text = ""
    }
    
    func updatePlayerImages() {
        switch myMultipeerHandler.session.connectedPeers.count {
        case 1:
            pOneView.backgroundColor = UIColor.red
        case 2:
            pTwoView.backgroundColor = UIColor.green
        case 3:
            pThreeView.backgroundColor = UIColor.orange
        default:
            print("unexpected default when updating playerImages")
        }
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        if motion == .motionShake {
            var rand = arc4random_uniform(4)
            while((rand == 0 && ALbl.backgroundColor == UIColor.yellow) ||
                (rand == 1 && BlBl.backgroundColor == UIColor.yellow) ||
                (rand == 2 && CLbl.backgroundColor == UIColor.yellow) ||
                (rand == 3 && CLbl.backgroundColor == UIColor.yellow)) {
                    rand = arc4random_uniform(4)
            }
            switch rand {
            case 0:
                aLabelTap(sender: ALbl)
            case 1:
                bLabelTap(sender: BlBl)
            case 2:
                cLabelTap(sender: CLbl)
            case 3:
                dLabelTap(sender: DLbl)
            default:
                print("Unexpected default in shake gesture")
            }
        }
    }

}

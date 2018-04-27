//
//  ViewController.swift
//  MPQuizzer-
//
//  Created by Robert Grizzard on 4/23/18.
//  Copyright © 2018 Robert Grizzard. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    var session: MCSession!
    var peerID: MCPeerID!
    
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    
    
    
    

    @IBOutlet weak var titleView: UIImageView!
    @IBOutlet weak var singlePlayerIV: UIImageView!
    @IBOutlet weak var multiPlayerIV: UIImageView!
    
    @IBOutlet weak var singlePlayerButton: UIButton!
    @IBOutlet weak var multiPlayerButton: UIButton!
    
    var singleOrMulti: String!
    let defaultButtonTextColor = UIButton(type: UIButtonType.system).titleColor(for: .normal)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpConnectivity()
        
        let titleImage = UIImage(named: "Title.png")
        titleView.image = titleImage
        
        let singlePlayerImage = UIImage(named: "singlePlayer.png")
        singlePlayerIV.image = singlePlayerImage
        
        let multiPlayerImage = UIImage(named: "multiPlayer.png")
        multiPlayerIV.image = multiPlayerImage
        
        singlePlayerButton.layer.cornerRadius = 0.25 * singlePlayerButton.frame.height
        multiPlayerButton.layer.cornerRadius = 0.25 * multiPlayerButton.frame.height
        singlePlayerButton.clipsToBounds = true
        multiPlayerButton.clipsToBounds = true
        
        singleOrMulti = "single"
        
    }
    
    func setUpConnectivity() {
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        self.browser = MCBrowserViewController(serviceType: "MPQuizzer", session: session)
        self.assistant = MCAdvertiserAssistant(serviceType: "MPQuizzer", discoveryInfo: nil, session: session)
        
        session.delegate = self
        browser.delegate = self
        
    }
    
    func startHosting(action: UIAlertAction){
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func singlePlayerButtonTapped(_ sender: UIButton) {
        
        //print("Single player tapped")
        singleOrMulti = "single"
        singlePlayerButton.backgroundColor = defaultButtonTextColor
        singlePlayerButton.setTitleColor(UIColor.white, for: .normal)
        multiPlayerButton.backgroundColor = UIColor.white
        multiPlayerButton.setTitleColor(defaultButtonTextColor, for: .normal)
    }
    
    @IBAction func multiPlayerButtonTapped(_ sender: UIButton) {
        
        //print("Multi player tapped")
        singleOrMulti = "multi"
        multiPlayerButton.backgroundColor = defaultButtonTextColor
        multiPlayerButton.setTitleColor(UIColor.white, for: .normal)
        singlePlayerButton.backgroundColor = UIColor.white
        singlePlayerButton.setTitleColor(defaultButtonTextColor, for: .normal)
    }
    
    
    @IBAction func connectBarButtonTapped(_ sender: UIBarButtonItem) {
        assistant.start()
        present(browser, animated: true)
        /*  let temporaryAlert = UIAlertController(title: "ALERT", message: "Implement multiPeer Connectivity", preferredStyle: .alert)
        temporaryAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(temporaryAlert, animated: true, completion: nil)
        */
    }
    
    
    @IBAction func startQuizButtonTapped(_ sender: UIButton) {
        switch singleOrMulti {
        case "single":
            print("starting with single player")
            self.performSegue(withIdentifier: "segueToSinglePlayerVC", sender: self)
        case "multi":
            print("starting with multiple players")
        default:
            print("unexpected default in startQuizButtonTapped, check value of \"singleOrMulti\"")
        }
        
        
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func sendLetter(String: UILabel) {
        if session.connectedPeers.count > 0 {
            if let letter =
        }
    }
}


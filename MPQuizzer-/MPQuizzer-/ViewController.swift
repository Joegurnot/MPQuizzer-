//
//  ViewController.swift
//  MPQuizzer-
//
//  Created by Robert Grizzard on 4/23/18.
//  Copyright © 2018 Robert Grizzard. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleView: UIImageView!
    @IBOutlet weak var singlePlayerIV: UIImageView!
    @IBOutlet weak var multiPlayerIV: UIImageView!
    
    @IBOutlet weak var singlePlayerButton: UIButton!
    @IBOutlet weak var multiPlayerButton: UIButton!
    
    var singleOrMulti: String!
    let defaultButtonTextColor = UIButton(type: UIButtonType.system).titleColor(for: .normal)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let temporaryAlert = UIAlertController(title: "ALERT", message: "Implement multiPeer Connectivity", preferredStyle: .alert)
        temporaryAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(temporaryAlert, animated: true, completion: nil)
        
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
}


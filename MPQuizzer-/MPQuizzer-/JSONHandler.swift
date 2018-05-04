//
//  JSONHandler.swift
//  MPQuizzer-
//
//  Created by Robert Grizzard on 4/25/18.
//  Copyright © 2018 Robert Grizzard. All rights reserved.
//

import Foundation
import UIKit

class JSONHandler {
    
    //singleton, no configuration object, Lecture 19 slide 9
    let sharedSession = URLSession.shared
    
    //used to track which URL in the arrayOfURLs we're currently using
    var currentURLIndex: Int = 2
    //let arrayOfURLs: [String] = ["http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json", "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz2.json"]
    var myURL:String!
    
    //used to track the current question
    var currentQuestion: Int = 0
    
    //set this after grabbing the JSON data; it will be the value for the key "numberOfQuestions"
    var numQuestions: Int?
    
    //tracks questions in the form "Question \(currentQuestion) / \(numQuestions)"
    var questionCounterLbl: UILabel!
    
    //will display the question
    var questionLbl: UILabel!
    
    var aAnswerLbl: UILabel!
    var bAnswerLbl: UILabel!
    var cAnswerLbl: UILabel!
    var dAnswerLbl: UILabel!
    
    var hiddenCorrectLbl: UILabel!
    
    //used to signal the end of the game
    var gameOver: Bool = false
    
    func setupUIElements(myQuestionCounterLbl: UILabel, myQuestionLbl: UILabel, myALbl: UILabel, myBLbl: UILabel, myCLbl: UILabel, myDLbl: UILabel, myHiddenCorrectLbl: UILabel) {
        questionCounterLbl = myQuestionCounterLbl
        questionLbl = myQuestionLbl
        
        aAnswerLbl = myALbl
        bAnswerLbl = myBLbl
        cAnswerLbl = myCLbl
        dAnswerLbl = myDLbl
        
        hiddenCorrectLbl = myHiddenCorrectLbl
    }
    
    
    func setNumQuestions(num: Int) {
        self.numQuestions = num
    }
    
    func printNumQuestions() {
        print("1.  printNumQuestions")
        if let tempNumQuestions = numQuestions {
            print("2.  printNumQuestions")
            print("\(tempNumQuestions)")
        }
    }
    
    //func testGrabJSON(uiv: UIView) {
    
    func testGrabJSON() {
        
        currentQuestion += 1
        /*
        if (gameOver) {
         currentQuestion = 1
         currentURLIndex += 1
         if (currentURLIndex == 2) {
         currentURLIndex = 0
         }
            //gameOver = false
        }
        */
 
        if let optNumQuestions = numQuestions {
            if currentQuestion > optNumQuestions {
                currentQuestion = 1
            }
        }
        
        //let urlString = arrayOfURLs[currentURLIndex]
        myURL = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz\(currentURLIndex).json"
        
        let url = URL(string: myURL)
        
        let session = self.sharedSession
        //let session = URLSession.shared
        
        let task = session.dataTask(with: url!) { (data, response, error) in
            //print("1.  inside testGrabJSON")
            if let result = data{
                
                //print("2.  inside testGrabJSON")
                //print("\(result)")
                do {
                    let json = try JSONSerialization.jsonObject(with: result, options: .allowFragments)
                    
                    if !JSONSerialization.isValidJSONObject(json) {
                        self.currentURLIndex = 1
                        self.gameOver = true
                        print("\n\nINVALID JSON\n\n")
                    }
                    else {
                        if let dictionary = json as? [String:Any] {
                            //print("\(dictionary["numberOfQuestions"]!)")
                            if let tempNumQuestions = dictionary["numberOfQuestions"] as? Int {
                                //print("tempNumQuestions is Int, \(tempNumQuestions)")
                                DispatchQueue.main.async(execute: {
                                    self.setNumQuestions(num: tempNumQuestions)
                                    self.questionCounterLbl.text = "Question \(self.currentQuestion)/\(self.numQuestions!)"
                                    //if let optLabel = uiv as? UILabel {
                                    //    optLabel.text = "\(tempNumQuestions)"
                                    //}
                                })
                                //self.setNumQuestions(num: tempNumQuestions)
                            }
                            if let tempQuestionsDict = dictionary["questions"] as? [[String: Any]] {
                                //print("\(tempQuestionsDict)")
                                for element in tempQuestionsDict {
                                    if let tempQuestionNum = element["number"] as? Int,
                                        let tempQuestionSentence = element["questionSentence"] as? String,
                                        let tempOptions = element["options"] as? [String: String],
                                        let tempCorrectOption = element["correctOption"] as? String {
                                        //print("tempQuestionNum: \(tempQuestionNum)")
                                        if tempQuestionNum == self.currentQuestion {
                                            print(tempQuestionSentence)
                                            print("tempOptions: \(tempOptions)")
                                            DispatchQueue.main.async(execute: {
                                                self.questionLbl.text = tempQuestionSentence
                                                self.aAnswerLbl.text = "A)" + tempOptions["A"]!
                                                self.bAnswerLbl.text = "B)" + tempOptions["B"]!
                                                self.cAnswerLbl.text = "C)" + tempOptions["C"]!
                                                self.dAnswerLbl.text = "D)" + tempOptions["D"]!
                                                
                                                switch tempCorrectOption {
                                                case "A" :
                                                    print("A is correct")
                                                    self.hiddenCorrectLbl.text = self.aAnswerLbl.text
                                                case "B":
                                                    print("B is correct")
                                                    self.hiddenCorrectLbl.text = self.bAnswerLbl.text
                                                case "C":
                                                    print("C is correct")
                                                    self.hiddenCorrectLbl.text = self.cAnswerLbl.text
                                                case "D":
                                                    print("D is correct")
                                                    self.hiddenCorrectLbl.text = self.dAnswerLbl.text
                                                default:
                                                    print("Unexpected default in tempCorrectOption")
                                                }
                                            })
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                catch {
                    print(error)
                    self.currentURLIndex = 1
                    self.currentQuestion = 0
                    self.testGrabJSON()
                    print("\n\nERROR\n\n")
                    
                }
            }
        }
        task.resume()
        
        if (currentQuestion == numQuestions) {
            gameOver = true
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}

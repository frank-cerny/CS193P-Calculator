//
//  ViewController.swift
//  Calculator
//
//  Created by Frank  on 8/1/17.
//  Copyright © 2017 Frank . All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    /*
     User in the middle of typing keeps track of whether or not a user is in the middle of a computation, and when they finish the cycle starts over, so 5....stil typing -  DONE typing 6... still typing.... = DONE typing
    */
    
    var userIsInMiddleOfTyping = false
    var enteredDecimal = false
    // private var historyString = " "
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        /* Only way a decimal point can be added is if the digit is . and decimal point has not been used yet, if either is false then the decimal point cannot be used
        */
        
        if (digit == "." && !enteredDecimal || digit != ".") {
            
            if (digit == ".") {
                enteredDecimal = true
            }
 
            if userIsInMiddleOfTyping {
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + digit
            } else {
                display.text = digit
                userIsInMiddleOfTyping = true
            }
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            
            // Allows us to set the display value as shown above with display.text = digit
            
            display.text = formatNumber(number: newValue)
        }
    }
    
    private var brain: CalculatorBrain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        
        // Only let an operation be done if the user is in the middle of typing and numbers exist on the screen
        
        if userIsInMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle
        {
            brain.performOperation(mathematicalSymbol)
        }
        
        // Update display after an operation key was clicked
        
        if let result = brain.result {
            displayValue = result
        }
        
        // as user is done typing they can again use a decimal
        
        enteredDecimal = false
        historyLabel.text = brain.historyString + brain.suffix
    }
    
    @IBAction func performBackSpace(_ sender: UIButton) {

        /*
         If the user is in the middle of typing and they erase everything, set the display to " ", instead of the optional default value of nil, or just use ?? to deafult the optional value, then set isTyping to false, otherwise Cut off last digit and update display accordingly
        */
        
        if (userIsInMiddleOfTyping) {
        
            if (display.text?.characters.count == 1) {
                display.text = " "
                userIsInMiddleOfTyping = false
            } else {
                display.text!.remove(at: display.text!.index(before: display.text!.endIndex))
            }
        }
    }
    
    func formatNumber(number: Double) -> String {
        
        /*
         Create a numberFormatterObject and set its properties to allow for a maximum of 6 digits, also on whole numbers we can omit the .0
         */
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 6
        return numberFormatter.string(for: number)!
        
    }
    
}


//
//  CalculatorBrain.swift
//  Calculator
//  This is the model of the calculator, where all the non UI calculator stuff happens, when the controller needs to do calculator things it talks to this model
//
//  Created by Frank  on 8/1/17.
//  Copyright © 2017 Frank . All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    /* 
     The accumulator is exactly like display value, except that it keeps a running total of what is on the screen, while displayValue is simply a computed property
    */
    
    private var accumulator: Double?  // Use Optional Defaulting here maybe??
    private var resultIsPending = false
    
    // This is a test variable tuple that accumulator will become soon
    
    // private var testAccumulator: (currentNum: Double?, history: String?)
    
    // Keeps track of current operands and operators causing the current result (if result is pending) or the final result
    
    private var description = " "
    private var historyStringSuffix = " "

    
    // The enum allows us to create special data types that contain optional values that can be easily accessed
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equals
        case clear
        case random
    }
    
    /* 
     Because enums are types we can specify a type for every button we have on the calculator and figure out what each does independent of each other based on the title, dictionaires use key value pairs just like maps. Because functions are types as well we do not need to put sin(Double) beacause sin is techinically of type (Double) -> Double
    */
    
    private var operations: Dictionary<String,Operation> = [
        // Option p inserts pi fyi
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "＋": Operation.binaryOperation({ $0 + $1 }),
        "−": Operation.binaryOperation({ $0 - $1 }),
        "÷": Operation.binaryOperation({ $0 / $1 }),
        "×": Operation.binaryOperation({ $0 * $1 }),
        "±": Operation.unaryOperation({ -$0 }),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "tan": Operation.unaryOperation(tan),
        "=": Operation.equals,
         "∛": Operation.unaryOperation({pow( $0, 1/3 )}),
         "ln": Operation.unaryOperation({ log2($0) }),
         "^": Operation.binaryOperation({pow($0, $1)}),
         "rand": Operation.random,
         "c": Operation.clear
    ]
    
    /* 
     This switch statements switches over the enum and decides whether to make a calculation immediately or if the user is going to type more stuff in before hitting equals
    */
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                description += symbol
                accumulator = value
                // testAccumulator = (value, testAccumulator.1! + symbol)
                // print("History String: " + testAccumulator.1!)
            case .unaryOperation(let function):
                if resultIsPending {
                    description += symbol + "(" + formatNumber(number: accumulator!) + ")"
                }
                else {
                    description = symbol + "(" + description + ")"
                }
                    accumulator = function(accumulator!)
                    resultIsPending = false
            case .binaryOperation(let function):
                if accumulator != nil {
                    
                     description += symbol
                    
                    /*
                     In order to make chain operations happen performPendingBinaryOperations here as well, such as 6 x 5 x 4 x 3, just keeps storing the updated result as an "operand"
                     */
                    
                    performPendingBinaryOperation()
                    historyStringSuffix = "..."
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                    resultIsPending = true
                }
            case .equals:
                if (resultIsPending) {
                    if (accumulator != Double.pi) {
                        description += formatNumber(number: accumulator!)
                    }
                }
                historyStringSuffix = " = "
                resultIsPending = false
                performPendingBinaryOperation()
            case .clear:
                // Once clear button is clicked clear accumulator, pendingBinaryOpertaions and any history screen 
                resultIsPending = false
                accumulator = 0
                pendingBinaryOperation = nil
                description = " "
                historyStringSuffix = " "
                
            case .random:
                /*
                    Use arc4random to generate a number from 0 up to UINT.max then divide by UNINT.max to get a number between 0 and 1, cast both types to get double precision
                */
                
                accumulator = Double(arc4random()) / Double(UINT32_MAX)
            }
        }
        
    }
    
    /* 
     When the user hits a binary operator the expression is stored in pendingBinaryOperation which keeps track of which operand and what function was chosen, then when the user hits equals after another number the calculation actually happens (performePendingBinaryOperation) and the second operand is used in conjunction to get a result
     */
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
            resultIsPending = false
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    /*
        setOperand syncs up the display in the view and the actual number in the model so that the model can make calculations
    */
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        
        // Only add operand to description if the result is NOT pending a binary Operation
        
        if (!resultIsPending) {
            description = formatNumber(number: operand)
        }
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    // Allows us to track the private description string over time, not sure if this is needed or not but does ensure some encapsulation I think
    
    var historyString: String {
        get {
            return description
        }
        set {
            description = newValue
        }
    }
    
    var suffix: String {
        get {
            return historyStringSuffix
        }
        set {
            historyStringSuffix = newValue
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

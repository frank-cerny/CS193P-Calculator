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
    
//    private var accumulator: (currentValue: Double,description: String)?
//    private var resultIsPending = false
    private var historyStringSuffix = " "
    
    // In progress stack of Inputs to make the calculator fully functional
    private var stack = [Input]()

    
    // The enum allows us to create special data types that contain optional values that can be easily accessed
    // Will also be used to piece together the description by using a second optional value which takes care of the description part
    
    private enum Operation {
        case constant(Double, String)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double,Double) -> Double, (String,String) -> String)
        case equals
        case clear
        case random
    }
    
    // Specifies 3 types of valid input, an operand in String format (variable), an operand in numeric format (digit) or an operation
    
    private enum Input {
        case variable(String)
        case operand(Double)
        case operation(String)
    }
    
    /* 
     Because enums are types we can specify a type for every button we have on the calculator and figure out what each does independent of each other based on the title, dictionaires use key value pairs just like maps. Because functions are types as well we do not need to put sin(Double) beacause sin is techinically of type (Double) -> Double
    */
    
    private var operations: Dictionary<String,Operation> = [
        // Option p inserts pi fyi
        "π": Operation.constant(Double.pi,"π"),
        "e": Operation.constant(M_E, "e"),
        "√": Operation.unaryOperation(sqrt,{"√(" + $0 + ")"}),
        "＋": Operation.binaryOperation({ $0 + $1 }, {$0 + "+" + $1}),
        "−": Operation.binaryOperation({ $0 - $1 }, {$0 + "-" + $1}),
        "÷": Operation.binaryOperation({ $0 / $1 }, {$0 + "/" + $1}),
        "×": Operation.binaryOperation({ $0 * $1 }, {$0 + "*" + $1}),
        "±": Operation.unaryOperation({ -$0 }, {"±(" + $0 + ")"}),
        "cos": Operation.unaryOperation(cos, {"cos(" + $0 + ")"}),
        "sin": Operation.unaryOperation(sin, {"sin(" + $0 + ")"}),
        "tan": Operation.unaryOperation(tan, {"tan(" + $0 + ")"}),
        "=": Operation.equals,
        "∛": Operation.unaryOperation({pow( $0, 1/3 )}, {"∛(" + $0 + ")"}),
        "ln": Operation.unaryOperation({ log2($0) }, {"ln(" + $0 + ")"}),
        "^": Operation.binaryOperation({pow($0, $1)}, {$0 + "^" + $1}),
         "rand": Operation.random,
         "c": Operation.clear
    ]
    
    /* 
     This switch statements switches over the enum and decides whether to make a calculation immediately or if the user is going to type more stuff in before hitting equals
    */
    
    // This updated method adds to the stack and saves heavier computaion for the evaluate method
    
    mutating func performOperation(_ symbol: String) {
        stack.append(Input.operation(symbol))
    }
    
//    mutating func performOperation(_ symbol: String) {
//        if let operation = operations[symbol] {
//            switch operation {
//            case .constant(let value, let symbol):
//                // description += symbol
//                accumulator = (value, symbol)
//            case .unaryOperation(let function, let description):
//                    accumulator = (function(accumulator!.currentValue), description(accumulator!.description))
//                    resultIsPending = false
//            case .binaryOperation(let function, let description):
//                //if accumulator?.currentValue != nil {
//                    /*
//                     In order to make chain operations happen performPendingBinaryOperations here as well, such as 6 x 5 x 4 x 3, just keeps storing the updated result as an "operand"
//                     */
//                    performPendingBinaryOperation()
//                    historyStringSuffix = "..."
//                    if (accumulator != nil) {
//                        // Only create a pending operation if the accumulator is set, set to nil after so that both the value and description are reset and ready for the next key press
//                        pendingBinaryOperation = PendingBinaryOperation(function: function, description: description, firstOperand: accumulator!)
//                        accumulator = nil
//                    // }
//                    resultIsPending = true
//                }
//            case .equals:
//                if (resultIsPending) {
//                    if (accumulator!.currentValue != Double.pi) {
//                        // description += formatNumber(number: accumulator!)
//                    }
//                }
//                historyStringSuffix = " = "
//                resultIsPending = false
//                performPendingBinaryOperation()
//            case .clear:
//                // Once clear button is clicked clear accumulator, pendingBinaryOpertaions and any history screen 
//                resultIsPending = false
//                accumulator = (0, " ")
//                pendingBinaryOperation = nil
//                historyStringSuffix = " "
//                
//            case .random:
//                /*
//                    Use arc4random to generate a number from 0 up to UINT.max then divide by UNINT.max to get a number between 0 and 1, cast both types to get double precision
//                */
//                
//                accumulator!.currentValue = Double(arc4random()) / Double(UINT32_MAX)
//            }
//        }
//    }
    
    /* 
     When the user hits a binary operator the expression is stored in pendingBinaryOperation which keeps track of which operand and what function was chosen, then when the user hits equals after another number the calculation actually happens (performePendingBinaryOperation) and the second operand is used in conjunction to get a result
     */
    
//    private mutating func performPendingBinaryOperation() {
//        if pendingBinaryOperation != nil && accumulator?.currentValue != nil {
//            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
//            pendingBinaryOperation = nil
//            resultIsPending = false
//        }
//    }
//    
//    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let description: (String, String) -> String
        let firstOperand: (Double, String)
        
        func perform(with secondOperand: (Double,String)) -> (Double,String) {
            return (function(firstOperand.0, secondOperand.0), description(firstOperand.1,secondOperand.1))
        }
    }
    
    /*
        setOperand syncs up the display in the view and the actual number in the model so that the model can make calculations
    */
    
//    mutating func setOperand(_ operand: Double) {
//        accumulator = (operand, String(operand)) // or \(operand)
//    }
    
    // updated setOperand method
    
    mutating func setOperand(_ operand: Double) {
        stack.append(Input.operand(operand))
    }
    
    // setOperand for variable input
    
    mutating func setOperand(_ operand: String) {
        stack.append(Input.variable(operand))
    }
    
//    var result: Double? {
//        if accumulator?.currentValue != nil {
//            return accumulator!.currentValue
//        }
//        return nil
//    }
//    
    // new result
    
    var result: Double? {
        return evaluate().result
    }
    
    // Allows us to track the private description string over time, not sure if this is needed or not but does ensure some encapsulation I think
    // just have to make it work with pendingBinaryOperation Now
    
//    var historyString: String {
//        
//        if pendingBinaryOperation != nil {
//            // description storres the correct description function for the binary symbol, so pass firstOperand and then "" becasue accumulator is nil at this point so we print the pending calculation on screen
//            return (pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.description ?? ""))
//        }
//        return accumulator!.description
//    }
    
    // new description
    
    var historyString: String {
        return evaluate().description
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
    
    // In progress evaluate method, keeping 
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        
        var accumulator: (currentValue: Double,description: String)?
        var resultIsPending = false
        var historyStringSuffix = " "
        var pendingBinaryOperation: PendingBinaryOperation?
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && accumulator?.currentValue != nil {
                accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                pendingBinaryOperation = nil
                resultIsPending = false
            }
        }
        
        /*
         setOperand syncs up the display in the view and the actual number in the model so that the model can make calculations
         */
        
//        func setOperand(_ operand: Double) {
//            accumulator = (operand, String(operand)) // or \(operand)
//        }
        
        func performOperation(_ symbol: String) {
            if let operation = operations[symbol] {
                switch operation {
                case .constant(let value, let symbol):
                    accumulator = (value, symbol)
                case .unaryOperation(let function, let description):
                    accumulator = (function(accumulator!.currentValue), description(accumulator!.description))
                    resultIsPending = false
                case .binaryOperation(let function, let description):
                    /*
                     In order to make chain operations happen performPendingBinaryOperations here as well, such as 6 x 5 x 4 x 3, just keeps storing the updated result as an "operand"
                     */
                    performPendingBinaryOperation()
                    historyStringSuffix = "..."
                    if (accumulator != nil) {
                        // Only create a pending operation if the accumulator is set, set to nil after so that both the value and description are reset and ready for the next key press
                        pendingBinaryOperation = PendingBinaryOperation(function: function, description: description, firstOperand: accumulator!)
                        accumulator = nil
                        resultIsPending = true
                    }
                case .equals:
//                    if (resultIsPending) {
//                        if (accumulator!.currentValue != Double.pi) {
//                        }
//                    }
                    accumulator?.description = "="
                    historyStringSuffix = " = "
                    resultIsPending = false
                    performPendingBinaryOperation()
                case .clear:
                    // Once clear button is clicked clear accumulator, pendingBinaryOpertaions and any history screen
                    resultIsPending = false
                    accumulator = (0, " ")
                    pendingBinaryOperation = nil
                    historyStringSuffix = " "
                    
                case .random:
                    /*
                     Use arc4random to generate a number from 0 up to UINT.max then divide by UNINT.max to get a number between 0 and 1, cast both types to get double precision
                     */
                    accumulator!.currentValue = Double(arc4random()) / Double(UINT32_MAX)
                }
            }
        }
        
        // Now time to evaluate the stack with a for in and switch statement
        
        for element in stack {
            switch element {
                case .operand(let value):
                    accumulator = (value, String(value))
                case .operation(let symbol):
                    if operations[symbol] != nil {
                        performOperation(symbol)
                }
                case .variable(let value):
                    // work in progress
                    break
                }
            }
        
        // track all variables here
        
        var historyString: String {
            
            if pendingBinaryOperation != nil {
                // description storres the correct description function for the binary symbol, so pass firstOperand and then "" becasue accumulator is nil at this point so we print the pending calculation on screen
                return (pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.description ?? ""))
            }
            return accumulator!.description
        }
        
        var result: Double? {
            if accumulator?.currentValue != nil {
                return accumulator!.currentValue
            }
            return nil
        }
        
        return (result,resultIsPending,historyString)
    }
}

// Not sure if this belongs here or in another file....

struct Stack<Element> {
    var items = [Element]()
    mutating func push(_ item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
}

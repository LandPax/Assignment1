import Foundation
import Darwin

class Brain {
    // TODO: Description of the sequence of Operands and Operations to Result
    var description = ""
    // TODO: Returns true if there is a binary operation pending
    var isPartialResult:Bool = false {
        didSet {
            if isPartialResult {
                description.append(" ...")
            }
        }
    }
    
    private var currentResult = 0.0
    var result:Double {
        get {
            return self.currentResult
        }
    }
    var resultToString:String {
        get {
            return String(self.currentResult)
        }
    }
    
    func setCurrentResult(aResult:Double) {
        self.currentResult = aResult
        
        if self.isPartialResult {
            eraseThreeDots()
            appedThreeDots()
        } else {
            self.description.append(String(aResult))
        }
    }
    
    func eraseThreeDots() {
        self.description = self.description.replacingOccurrences(of: "...", with: "")
    }
    
    func appedThreeDots() {
        self.description.append("...")
    }
    
    private enum OperationTypes {
        case Constant(Double)
        case UnaryOperator((Double)->Double)
        case BinaryOperator((Double, Double)->Double)
        case Equals
    }
    
    private var operations:Dictionary<String,OperationTypes> = [
        "π" : .Constant(M_PI),
        "e" : .Constant(M_E),
        "rand" : .Constant(Double(arc4random())),
        "√" : .UnaryOperator(sqrt),
        "%" : .UnaryOperator({$0/100}),
        "×" : .BinaryOperator({$0*$1}),
        "÷" : .BinaryOperator({$0/$1}),
        "+" : .BinaryOperator({$0+$1}),
        "-" : .BinaryOperator({$0-$1}),
        "^" : .BinaryOperator({pow($0,$1)}),
        "=" : .Equals
    ]
    
    func performOperation(symbol:String) {
        if let operation = operations[symbol] {
            self.description.append(" "+symbol)
            switch operation {
            case .Constant(let theConstant):
                self.currentResult = theConstant
            case .UnaryOperator(let theUnaryFunction):
                self.currentResult = theUnaryFunction(self.currentResult)
            case .BinaryOperator(let theBinaryOperator):
                self.pendingOperation = PendingBinaryOperationInfo(binaryOperator: theBinaryOperator, firstOperand: self.currentResult)
                self.isPartialResult = true
            case .Equals:
                if let _ = pendingOperation {
                    self.currentResult = pendingOperation.binaryOperator(pendingOperation.firstOperand,
                                                                         self.currentResult)
                    pendingOperation = nil
                    self.isPartialResult = false
                    
                    setCurrentResult(aResult: self.currentResult)
                }
            }
        }
    }
    
    func clearBrain() {
        // TODO: Set Brain back to it's intial states, i.e.(0.0 in the accumulator, no pending operations)
        self.currentResult = 0.0
        self.isPartialResult = false
        self.description = ""
    }
    
    func undoOperation() {
        self.pendingOperation = nil
    }
    
    private var pendingOperation:PendingBinaryOperationInfo!
    
    struct PendingBinaryOperationInfo {
        var binaryOperator:(Double, Double)->Double
        var firstOperand:Double
    }
}

// TESTING my Brain

let myBrain = Brain()

// check clearBrain method
myBrain.setCurrentResult(aResult: 20)
myBrain.performOperation(symbol: "+")
myBrain.setCurrentResult(aResult: 2)
//myBrain.performOperation(symbol: "=")

print(myBrain.description)







import Foundation



public protocol Step {
  var label: String { get }
  
  var content: [String:String] { get }
  
  var choices: [String] { get }  // names of choices the default behaviours of which are defined by presenter.
  
  var handlers: [String : (@escaping () -> Void, Presenter) -> Void] { get } // choice : closure(defaultHandler, presenter); can be empty.
  
  var enabledOptions: [String] { get set } // to disable / enable options.
  
  mutating func enable(option: String)
  mutating func disable(option: String)
}

extension Step {
  mutating public func enable(option: String) {
    enabledOptions.append(option)
  }
  
  mutating public func disable(option: String) {
    let index = enabledOptions.index(of: option)
    enabledOptions.remove(at: index!)
  }
}



// MARK: -

public struct SimpleStep: Step {
  
  public let label: String
  
  public let content: [String:String]
  
  public let choices: [String]   // names of choices which default behaviours are defined by presenter
    // TODO make customisable / overridable in Step
  
  public let handlers: [String : (@escaping () -> Void, Presenter) -> Void]

  public var enabledOptions: [String]
  
  public init(label: String, choices: [String], content: [String : String] = [:], initiallyEnabled: [String]? = nil, handlers: [String : (@escaping () -> Void, Presenter) -> Void] = [:]) {
    self.label = label
    self.content = content
    self.choices = choices
    self.enabledOptions = initiallyEnabled ?? choices
    self.handlers = handlers
  }
  
  mutating public func enable(option: String) {
    enabledOptions.append(option)
  }
  
  mutating public func disable(option: String) {
    let index = enabledOptions.index(of: option)
    enabledOptions.remove(at: index!)
  }
  
}


/// allows a Sequence to use another Sequence as a subsequence (step).
public struct SequenceStep: Step {
  
  var sequence: Sequence
  
  var currentStep: Step

  public private(set) var isFinished: Bool = false

  
  public init(_ sequence: Sequence) {
    self.sequence = sequence
    self.currentStep = sequence.currentStep
  }
  
  public mutating func goNext() {
    sequence.goNext()
    
    self.currentStep = sequence.currentStep
    
    if sequence.steps.index(where: {$0.label == currentStep.label}) == sequence.steps.count - 1 {
      self.isFinished = true
    }

  }

  
  // MARK: -
  
  public var label: String {
    return currentStep.label
  }
  
  public var content: [String : String] {
    return currentStep.content
  }
  
  public var handlers: [String : (@escaping () -> Void, Presenter) -> Void] {
    return currentStep.handlers
  }
  
  public var choices: [String] {
    return currentStep.choices
  }
  
  public var enabledOptions: [String] {
    get {
      return currentStep.enabledOptions
    }
    set {
      currentStep.enabledOptions = newValue
    }
  }
  
}



// MARK: -

open class Sequence {
  
  var steps: [Step]
  
  var currentStep: Step {
    get {
      return steps[currentIndex]
    }
    set {
      // only allow changing current step for subsequences, since it needs to mutate.
      if newValue is SequenceStep {
        let index = self.steps.index(where: { $0.label == self.currentStep.label })!
        self.steps.remove(at: index)
        self.steps.insert(newValue, at: index)
      }
      else {
        fatalError()
      }
    }
  }
  
  private let stepDict: [String:Step]
  private var currentIndex: Int
  

  public init(steps: [Step]) {
    self.steps = steps
    self.stepDict = steps.reduce([:]) {
      var dict = $0
      dict[$1.label] = $1
      return dict
    }
    
    self.currentIndex = 0
  }
  
  public func goNext() {
    if var subsequence = self.currentStep as? SequenceStep {
      // come out of subsequence if we were at its last step.
      if subsequence.isFinished {
        currentIndex += 1
      }
      else {
        subsequence.goNext()
        self.currentStep = subsequence
      }
    }
    else {
      currentIndex += 1
    }
    
    // finish if we ran out of steps.
    if !(currentIndex < steps.count) {
      currentIndex = steps.count - 1
      self.finish()
    }
  }
  
  public func goPrevious() {
    currentIndex -= 1
  }
  
  
  open func finish() {
    print("\(self) finished presenting.")
  }
  
  
  public func enable(option optionName: String) {
    var modifiedStep = self.currentStep
    modifiedStep.enable(option: optionName)
    self.steps = self.steps.reduce([], { (acc, step) in
      var acc = acc
      if step.label == modifiedStep.label {
        acc.append(modifiedStep)
      } else {
        acc.append(step)
      }
      return acc
    })
  }
  
  public func disable(option optionName: String) {
    var modifiedStep = self.currentStep
    modifiedStep.disable(option: optionName)
    self.steps = self.steps.reduce([], { (acc, step) in
      var acc = acc
      if step.label == modifiedStep.label {
        acc.append(modifiedStep)
      } else {
        acc.append(step)
      }
      return acc
    })
  }
  
}



// MARK: -

public protocol Presenter {
  var sequence: Sequence { get }
  
  func present()
  
  func goNext()
  func goPrevious()
  
  func finish()
  
  func enable(choice: String)
  func disable(choice: String)
}



extension Presenter {
  public func goNext() {
    sequence.goNext()
    self.present()
  }
  
  public func goPrevious() {
    sequence.goPrevious()
    self.present()
  }
}



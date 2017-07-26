import Foundation



/// Models a series of steps.
open class Sequence {
  
  var steps: [Step]
  
  var currentStep: Step {
    get {
      // find the first step where condition evaluates to true.
      for step in steps {
        if steps.index(where: { $0.label == step.label })! < currentIndex {
          continue
        }
        if step.shouldPresent {
          return step
        }
      }
      // no step has condition met, just return the last one.
      return steps[currentIndex]
    }
    set {
      if let index = steps.index(where: { $0.label == newValue.label }) {
        currentIndex = index
      } else {
        fatalError()
      }
    }
  }
  
  fileprivate var currentIndex: Int
  
  
  public init(steps: [Step]) {
    self.steps = steps
    self.currentIndex = 0
  }
  
  open func goNext() {
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
      print("\(self) finished.")
      return
    }
    
  }
  
  open func goPrevious() {
    currentIndex -= 1
  }
  
  // MARK: -
  
  var isFinished: Bool {
    return self.currentIndex >= self.steps.count - 1
  }
}



public protocol Step {
  
  var shouldPresent: Bool { get }
  
  var label: String { get }
  
  var content: [String : String] { get }
  
  var choices: [String] { get }  // names of choices the default behaviours of which are defined by presenter.
  
  var handlers: [String : (@escaping () -> Void, Presenter) -> Void] { get } // choice : closure(defaultHandler, presenter); can be empty.
  
  var enabledChoices: [String] { get set }
  
  mutating func enable(choice: String)
  mutating func disable(choice: String)
  
}



extension Step {
  
  mutating public func enable(choice: String) {
    self.enabledChoices.append(choice)
  }
  
  mutating public func disable(choice: String) {
    let index = self.enabledChoices.index(of: choice)
    self.enabledChoices.remove(at: index!)
  }
  
}



// MARK: -

public struct BasicStep: Step {
  
  public let condition: () -> Bool
  
  public let label: String
  
  public let content: [String:String]
  
  public let choices: [String]   // names of choices which default behaviours are defined by presenter
    // TODO make customisable / overridable in Step
  
  public let handlers: [String : (@escaping () -> Void, Presenter) -> Void]

  public var enabledChoices: [String]
  
  
  public init(
              label: String,
              choices: [String],
              content: [String : String] = [:],
              initiallyEnabled: [String]? = nil,
              condition: @escaping () -> Bool = { return true },
              handlers: [String : (@escaping () -> Void, Presenter) -> Void] = [:]) {
    self.label = label
    self.content = content
    self.choices = choices
    self.enabledChoices = initiallyEnabled ?? choices
    self.condition = condition
    self.handlers = handlers
  }
  
  public var shouldPresent: Bool {
    return self.condition()
  }
}


/// allows a Sequence to use another Sequence as a subsequence (step).
public struct SequenceStep: Step {
  
  var sequence: Sequence
  
  public let sequenceLevelHandlers: [String : (@escaping () -> Void, Presenter) -> Void]
  
  
  public init(sequence: Sequence, handlers: [String : (@escaping () -> Void, Presenter) -> Void] = [:]) {
    self.sequence = sequence
    self.sequenceLevelHandlers = handlers
  }
  
  public mutating func goNext() {
    sequence.goNext()
    
  }

  
  // MARK: -
  
  var currentStep: Step {
    get {
      return self.sequence.currentStep
    }
    set {
      self.sequence.currentStep = newValue
    }
  }
  
  public var enabledChoices: [String] {
    get {
      return currentStep.enabledChoices
    }
    set {
      currentStep.enabledChoices = newValue
    }
  }
  
  public var label: String {
    return currentStep.label
  }
  
  public var content: [String : String] {
    return currentStep.content
  }
  
  public var shouldPresent: Bool {
    return true
  }
  
  public var handlers: [String : (@escaping () -> Void, Presenter) -> Void] {
    var handlers = currentStep.handlers
    for (handlerId, handler) in sequenceLevelHandlers {
      handlers[handlerId] = handler
    }
    return handlers
  }
  
  public var choices: [String] {
    return currentStep.choices
  }
  
  public var isFinished: Bool {
    return self.sequence.isFinished
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

  func shouldSkipIntro() -> Bool
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
  
  public func shouldSkipIntro() -> Bool {
    return false
  }
}



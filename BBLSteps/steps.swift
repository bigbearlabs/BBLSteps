
//
//  steps.swif.swift
//  BBLSteps
//
//  Created by Andy Park on 28/01/2017.
//  Copyright © 2017 Big Bear Labs. All rights reserved.
//

import Foundation



public struct Step {
  
  public let label: String
  
  let options: [String:()->()]   // name : block.
  var enabledOptions: [String]
  
  public var availableOptions: [String:()->()] {
    return options.reduce([:]) { (dict, entry) in
      var dict = dict
      if enabledOptions.contains(entry.key) {
        dict[entry.key] = entry.value
      }
      return dict
    }
  }

  public init(label: String, options: [String:()->()], initiallyEnabled: [String]? = nil) {
    self.label = label
    self.options = options
    self.enabledOptions = initiallyEnabled ?? Array(options.keys)
  }
  
  mutating public func enable(option: String) {
    enabledOptions.append(option)
  }
  
  mutating public func disable(option: String) {
    let index = enabledOptions.index(of: option)
    enabledOptions.remove(at: index!)
  }
  
}



open class StepSequence {
  
  var steps: [Step]
  private let stepDict: [String:Step]
  private var currentIndex: Int
  
  var currentStep: Step {
    return steps[currentIndex]
  }
  
  public init(steps: [Step], presenter: Presenter) {
    self.steps = steps
    self.stepDict = steps.reduce([:]) {
      var dict = $0
      dict[$1.label] = $1
      return dict
    }
    
    self.currentIndex = 0
    
    self.presenter = presenter
  }
  
  public func goNext() {
    currentIndex += 1
    self.present(step: self.currentStep)
  }
  
  public func goPrevious() {
    currentIndex -= 1
    self.present(step: self.currentStep)
  }
  
  
  public func present(step: Step? = nil) {
    let step = step ?? self.currentStep
    
    // use a presentation strategy based on steps to create interaction.
    // e.g. create views based on the steps to present on a gui.
    // e.g. create a text in / out interface based on the steps to to present on a console.
    
    self.presenter.present(step)
  }
  
  public func finish() {
    print("\(self) finished presenting.")
    presenter.finish()
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
  
  let presenter: Presenter
}



public protocol Presenter {
  
  func present(_ step: Step)
  
  func finish()
}

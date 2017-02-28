//
//  ConsolePresenter.swift
//  BBLSteps
//
//  Created by Andy Park on 28/01/2017.
//  Copyright © 2017 Big Bear Labs. All rights reserved.
//

import Foundation



public class ConsolePresenter: Presenter {

  public var sequence: Sequence
  
  public func present() {
    let step = sequence.currentStep
    Prompter(step: step, presenter: self).prompt()
  }

  public func finish() {
    print("finished presenting \(sequence).")
  }
  
  
  public func enable(choice: String) {
    sequence.currentStep.enable(option: choice)
  }
  public func disable(choice: String) {
    sequence.currentStep.disable(option: choice)
  }

  
  public init(sequence: Sequence) {
    self.sequence = sequence
  }
  
  
  struct Prompter {
    let step: Step
    let presenter: Presenter
    
    func prompt() {
      print(step.label)
      
      print("Options: \(step.choices)")
      var input: String? = nil
      while input == nil {
        print("Your choice:")
        input = readLine(strippingNewline: true)
        if let handler = step.handlers[input!] {
          handler({}, presenter)
        }
        // TODO default to the presenter's handlers -- consult NSWindowPresenter
        else {
          print("choice '\(input)' was not found.")
          
          input = nil
        }
      }
    }
  }
  
}



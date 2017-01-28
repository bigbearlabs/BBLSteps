//
//  ConsolePresenter.swift
//  BBLSteps
//
//  Created by Andy Park on 28/01/2017.
//  Copyright © 2017 Big Bear Labs. All rights reserved.
//

import Foundation



public class ConsolePresenter: Presenter {

  var sequence: StepSequence!
  
  public init() {}
  
  public func present(_ step: Step) {
    Prompter(step: step).prompt()
  }
  
  struct Prompter {
    let step: Step
    
    func prompt() {
      print(step.label)
      
      print("Options: \(Array(step.availableOptions.keys))")
      var input: String? = nil
      while input == nil {
        print("Your choice:")
        input = readLine(strippingNewline: true)
        if let option = step.availableOptions[input!] {
          option()
        }
        else {
          print("choice '\(input)' was not found.")
          
          input = nil
        }
      }
    }
  }
  
}



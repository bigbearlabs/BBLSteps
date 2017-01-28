//
//  IntroWorkflow.swift
//  BBLSteps
//
//  Created by Andy Park on 28/01/2017.
//  Copyright © 2017 Big Bear Labs. All rights reserved.
//

import Foundation
import BBLSteps



class IntroWorkflow: StepSequence {
  
  init(presenter: Presenter) {
    var theThing: IntroWorkflow!
    super.init(
      steps: [
        Step(
          label: "Welcome!",
          options: [
            "next": {
              theThing!.goNext()
            }
          ]
        ),
        Step(
          label: "What I need",
          options: [
            "requestAx": {
              theThing.beginAxRequestWorkflow(whenGranted: {
//                theThing.enable(option: "next") // should work on current step.
//                theThing.disable(option: "requestAx")
//                theThing.present()
                theThing!.goNext()
              })
            },
//            "next": {
//              theThing!.goNext()
//            },
          ],
          initiallyEnabled: [
            "requestAx",
          ]
        ),
        Step(
          label: "Thank you.",
          options: [
            "done": {
              theThing!.finish()
            },
            ],
          initiallyEnabled: [
            "done",
            ]
        ),
      ],
      presenter: presenter)
    
    theThing = self
    // ?? will this work?
  }
  
  func beginAxRequestWorkflow(whenGranted: ()->()) {
    // TODO delegate to system, then asyncly...
    whenGranted()
  }
}

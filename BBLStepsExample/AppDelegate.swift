//
//  AppDelegate.swift
//  BBLStepExample
//
//  Created by Andy Park on 28/01/2017.
//  Copyright © 2017 Big Bear Labs. All rights reserved.
//

import Cocoa
import BBLSteps


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!


  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    // use case 1: interacting through the console.
//    let intro = IntroWorkflow(presenter: ConsolePresenter())
//    intro.present()

    // use case 2: interacting through a macOS presenter.
    let intro = IntroWorkflow(presenter: NSViewPresenter(contentView: window.contentView!))
    intro.present()
  }

}



// an example sequence of steps that walks the user through highlights of the app.
class IntroWorkflow: StepSequence {
  
  init(presenter: Presenter) {
    var workflow: IntroWorkflow!  // to be set to self so the closures passed to super.init can reference the instance.
    
    super.init(
      steps: [
        Step(
          label: "Welcome!",
          options: [
            "next": {
              workflow.goNext()
            }
          ]
        ),
        Step(
          label: "What makes me so great?",
          options: [
            "next": {
              workflow.goNext()
              workflow.expectTrialMoveCompleted() {
                // enable the 'next' control only when the move has been made successfully.
                workflow.enable(option: "next")
              }
            },
            "previous": {
              workflow.goPrevious()
            }
          ]
        ),
        Step(
          label: "Try this move!",
          options: [
            "next": {
              workflow.goNext()
            },
            "previous": {
              workflow.goPrevious()
            }
          ],
          initiallyEnabled: [
            "previous",
            ]
        ),
        Step(
          label: "Thank you, and good luck.",
          options: [
            "done": {
              workflow.finish()
            },
          ]
        ),
        ],
      content: content,
      presenter: presenter)
    
    workflow = self
  }
  
  func expectTrialMoveCompleted(onComplete: ()->()) {
    // TODO perform the magic that detects the move, then ...
    
    onComplete()
  }
}

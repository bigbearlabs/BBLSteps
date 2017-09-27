//
//  NSViewPresenter.swift
//  BBLSteps
//
//  Created by ilo on 30/01/2017.
//  Copyright © 2017 Big Bear Labs. All rights reserved.
//

import Foundation
import BBLBasics



public class NSWindowPresenter: Presenter {
  
  var currentViewController: NSViewController!
  
  public let sequence: Sequence
  
  let window: NSWindow!
  
  private lazy var choiceHandlers: [String : () -> Void] = {
    [
      "next": {
        self.goNext()
      },
      "previous": {
        self.goPrevious()
      },
      "done": {
        self.finish()
      }]
  }()
  
  
  public init(window: NSWindow, sequence: Sequence) {
    self.window = window
    self.sequence = sequence
    self.window.center()
  }
  
  public func present() {
    let step = sequence.currentStep

    // make a view and add to the content view.
    self.currentViewController = viewControllerFor(step)
    
    // display the view.
    window.contentView!.removeAllSubviews()
    window.contentView!.addSubview(self.currentViewController.view, fit: true)
  }
  
  public func enable(choice: String) {
    let vc = self.currentViewController as! StepViewController
    if choice == "skipIntroCheckbox" {
      vc.isSkipCheckboxVisible = true
    } else {
      vc.step.enable(choice: choice)
    }
  }
  public func disable(choice: String) {
    let vc = self.currentViewController as! StepViewController
    vc.step.disable(choice: choice)
  }

  public func finish() {
//    window.performClose(self)  // doesn't work for window without a close button.
    window.orderOut(self)
  }

  
  private func viewControllerFor(_ step: Step) -> NSViewController {
    let vc = StepViewController(nibName: NSNib.Name(rawValue: "StepViewController"), bundle: Bundle.init(for: type(of: self)))
    vc.set(step: step, presenter: self)
    return vc
  }
  
  func handler(choice: String) -> (() -> Void) {
    let handler = choiceHandlers[choice] ?? {}
    
    // if step defines a handler for this choice, return a closure that composes that and default handler.
    if let stepHandler = sequence.currentStep.handlers[choice] {
      return {
        stepHandler(handler, self)
      }
    }
    else {
      return handler
    }
  }
  

  // FIXME detail leak from `contexter`.
  public func shouldSkipIntro() -> Bool {
    let vc = self.currentViewController as! StepViewController
    return vc.skipCheckBox.state == .on
  }
}



class StepViewController: NSViewController {
  
  @IBOutlet weak var optionsArea: NSStackView!  // RENAME to choicesArea
  
  weak var presenter: NSWindowPresenter!
  
  func set(step: Step, presenter: NSWindowPresenter) {
    self.presenter = presenter
    self.step = step
  }
  
  var step: Step! {
    didSet {
      _ = self.view

      self.label = self.step.content["title"]
      self.text = self.step.content["text"]

      execOnMain {
        refreshChoiceControls()
      }
    }
  }
  
  func refreshChoiceControls() {
      // make controls for the options and show them.
      self.optionsArea.removeAllSubviews()
      self.buttonHolders = []
  
      let choiceControls = self.step.enabledChoices.map { choice in
        return viewFor(choice: choice, handler: self.presenter.handler(choice: choice))
      }
  
      choiceControls.forEach {
        optionsArea.addArrangedSubview($0)
      }
    }
  
  

  // bindings-compatible properties.
  @objc dynamic var label: String?
  
  @objc dynamic var text: String?
  
  // FIXME details from the 'skip' feature for `contexter`.
  
  @objc dynamic var isSkipCheckboxVisible: Bool = false

  @IBOutlet weak var skipCheckBox: NSButton!
  
  
  private func viewFor(choice: String, handler: @escaping ()->()) -> NSView {
    let view = NSButton(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
    view.title = choice
    let buttonHolder = ButtonHolder(button: view, onPress: handler)

    self.buttonHolders.append(buttonHolder)
    return view
  }
  
  var buttonHolders: [ButtonHolder] = []
}


@objc
class ButtonHolder: NSObject {
  let button: NSButton
  
  var onButtonPress: ()->()
  
  init(button: NSButton, onPress: @escaping ()->()) {
    self.button = button
    self.onButtonPress = onPress
    super.init()
    
    button.target = self
    button.action = #selector(actionButtonPressed(_:))
    
    
  }
  
  @objc func actionButtonPressed(_ sender: Any) {
    onButtonPress()
  }
}

//
//  NSViewPresenter.swift
//  BBLSteps
//
//  Created by ilo on 30/01/2017.
//  Copyright © 2017 Big Bear Labs. All rights reserved.
//

import Foundation



public class NSWindowPresenter: Presenter {
  
  var currentViewController: NSViewController!
  
  let window: NSWindow!
  
  public init(window: NSWindow) {
    self.window = window
    self.window.center()
  }
  
  public func present(_ step: Step) {
    // make a view and add to the content view.
    self.currentViewController = viewControllerFor(step)
    
    window.contentView!.removeAllSubviews()
    window.contentView!.addSubview(self.currentViewController.view, fit: true)
  }
  
  public func finish() {
    window.performClose(self)
  }

  func viewControllerFor(_ step: Step) -> NSViewController {
    let vc = StepViewController(nibName: "StepViewController", bundle: Bundle.init(for: type(of: self)))
    vc!.step = step
    return vc!
  }
  
}



class StepViewController: NSViewController {
  
  @IBOutlet weak var optionsArea: NSStackView!
  
  var step: Step! {
    didSet {
      _ = self.view
      
      // make controls for the options and show them.
      self.optionsArea.removeAllSubviews()
      self.buttonHolders = []
      
      self.step.availableOptions.reversed().forEach { (k, v) in
        let optionView = optionViewFor((k, v))
        optionsArea.addArrangedSubview(optionView)
      }
    }
  }
  
  // bindings-compatible properties.
  var label: String {
    return self.step.label
  }
  
  func optionViewFor(_ option: (String, ()->()) ) -> NSView {
    let view = NSButton(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
    view.title = option.0
    let buttonHolder = ButtonHolder(button: view) {
      option.1()
    }
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
  
  func actionButtonPressed(_ sender: Any) {
    onButtonPress()
  }
}



extension NSView {
  
  func addSubview(_ subview: NSView, fit: Bool) {
    self.addSubview(subview)
    if fit {
      subview.frame = self.bounds
    }
  }
  
  func removeAllSubviews() {
    self.subviews.forEach { $0.removeFromSuperview() }
  }
  
}

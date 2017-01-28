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
    
//    let intro = IntroWorkflow(presenter: ConsolePresenter())
//    intro.present()

    let intro = IntroWorkflow(presenter: NSViewPresenter(contentView: window.contentView!))
    intro.present()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }


}



class NSViewPresenter: Presenter {
  
  var currentViewController: NSViewController!
  
  let contentView: NSView
  
  init(contentView: NSView) {
    self.contentView = contentView
  }
  
  func present(_ step: Step) {
    // make a view and add to the content view.
    self.currentViewController = viewControllerFor(step)
    
    contentView.removeAllSubviews()
    contentView.addSubview(self.currentViewController.view, fit: true)
    
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

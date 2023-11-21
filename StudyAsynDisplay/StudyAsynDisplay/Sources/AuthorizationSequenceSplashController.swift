//
//  AuthorizationSequenceSplashController.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/22/23.
//

import Foundation
import Display

class AuthorizationSequenceSplashController: ViewController {
    
    private let controller: RMIntroViewController
    private var validLayout: ContainerViewLayout?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(account: String) {
        self.controller = RMIntroViewController()
        super.init(navigationBarPresentationData: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .orange
    }
    
    public override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        self.validLayout = layout
        let controllerFrame = CGRect(origin: CGPoint(), size: layout.size)
//        self.controller.defaultFrame = controllerFrame
//
//        self.controllerNode.containerLayoutUpdated(layout, navigationBarHeight: 0.0, transition: transition)
        
        self.addControllerIfNeeded()
        if case .immediate = transition {
            self.controller.view.frame = controllerFrame
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.controller.view.frame = controllerFrame
            })
        }
    }
    
    func animateIn() {
        self.controller.animateIn()
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addControllerIfNeeded()
        self.controller.viewWillAppear(false)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        controller.viewDidAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        controller.viewWillDisappear(animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        controller.viewDidDisappear(animated)
    }
    
    private func addControllerIfNeeded() {
        if !self.controller.isViewLoaded || self.controller.view.superview == nil {
            self.displayNode.view.addSubview(self.controller.view)
            if let layout = self.validLayout {
                controller.view.frame = CGRect(origin: CGPoint(), size: layout.size)
            }
            self.controller.viewDidAppear(false)
        }
    }
}

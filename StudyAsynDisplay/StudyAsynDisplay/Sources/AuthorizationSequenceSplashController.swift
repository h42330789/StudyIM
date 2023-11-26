//
//  AuthorizationSequenceSplashController.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/22/23.
//

import UIKit
import Display

class AuthorizationSequenceSplashController: ViewController {
    
    private let controller: RMIntroViewController
    var nextPressed: (() -> Void)?
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(account: String) {
        self.controller = RMIntroViewController()
        super.init(navigationBarPresentationData: nil)
        self.controller.skipBlcok = {[weak self] in
            self?.nextPressed?()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
    }
    
    public override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
               
        self.addControllerIfNeeded()
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
            self.controller.viewDidAppear(false)
        }
    }
}

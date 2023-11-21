//
//  AuthorizationSequenceController.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/2/23.
//

import UIKit
import Display
import AuthenticationServices

class AuthorizationSequenceController: NavigationController  {
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    static func navigationBarTheme(_ theme: String) -> NavigationBarTheme {
        return NavigationBarTheme(buttonColor: .red, disabledButtonColor: .green, primaryTextColor: .yellow, backgroundColor: .clear, enableBackgroundBlur: false, separatorColor: .clear, badgeBackgroundColor: .blue, badgeStrokeColor: .gray, badgeTextColor: .orange)
    }
    private var didPlayPresentationAnimation = false
    public init(account: String) {
        
        let statusBar: NavigationStatusBarStyle = .black
        let navBar = AuthorizationSequenceController.navigationBarTheme("")
        let theme = NavigationControllerTheme(statusBar: statusBar, navigationBar: navBar , emptyAreaColor: .black)
        
        super.init(mode: .single, theme: theme, isFlat: true)
        self.updateState(state: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
    }
    
    private func updateState(state: String) {
        var controllers: [ViewController] = []
        controllers.append(self.splashController())
        
        self.setViewControllers(controllers, animated: !self.viewControllers.isEmpty)
    }
    
    override public func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        let wasEmpty = self.viewControllers.isEmpty
        super.setViewControllers(viewControllers, animated: animated)
        if wasEmpty {
            if self.topViewController is AuthorizationSequenceSplashController {
            } else {
                self.topViewController?.view.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.3)
            }
        }
//        if !self.didSetReady {
//            self.didSetReady = true
//            self._ready.set(.single(true))
//        }
    }

    private func splashController() -> AuthorizationSequenceSplashController {
        let vc = AuthorizationSequenceSplashController(account: "")
        vc.view.frame = CGRect(x: 0, y: 0, width: 393, height: 582)
        return vc
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.didPlayPresentationAnimation {
            self.didPlayPresentationAnimation = true
            self.animateIn()
        }
    }
    
    private func animateIn() {
//        if !self.otherAccountPhoneNumbers.1.isEmpty {
//            self.view.layer.animatePosition(from: CGPoint(x: self.view.layer.position.x, y: self.view.layer.position.y + self.view.layer.bounds.size.height), to: self.view.layer.position, duration: 0.5, timingFunction: kCAMediaTimingFunctionSpring)
//        } else {
            if let splashController = self.topViewController as? AuthorizationSequenceSplashController {
                splashController.animateIn()
            }
//        }
    }
}


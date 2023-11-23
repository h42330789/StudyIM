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
        var controllers: [ViewController] = []
        controllers.append(self.splashController())
        self.setViewControllers(controllers, animated: !self.viewControllers.isEmpty)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
    }
    
    private func splashController() -> AuthorizationSequenceSplashController {
        let vc = AuthorizationSequenceSplashController(account: "")
        return vc
    }
    
    
}


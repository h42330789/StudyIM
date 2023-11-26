//
//  AuthorizationSequenceController.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/2/23.
//

import UIKit
import Display

public enum UnauthorizedAccountStateContents: Equatable {
    case empty
    case phoneEntry
    case confirmationCodeEntry
    case passwordEntry
    case passwordRecovery
    case awaitingAccountReset
    case signUp
}

private enum InnerState: Equatable {
    case state(UnauthorizedAccountStateContents)
    case authorized
}

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
        if UserDefaults.standard.string(forKey: "guide") == nil {
            // 没有展示过引导页
            self.updateState(state: .state(.empty))
        } else {
            // 已经展示过引导页
            self.updateState(state: .state(.phoneEntry))
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
    }
    
    private func splashController() -> AuthorizationSequenceSplashController {
        let vc = AuthorizationSequenceSplashController(account: "")
        vc.nextPressed = {[weak self] in
            UserDefaults.standard.set("1", forKey: "guide")
            self?.updateState(state: .state(.phoneEntry))
        }
        return vc
    }
    
    private func phoneEntryController(splashController: AuthorizationSequenceSplashController?) -> AuthorizationSequencePhoneEntryController {
        let vc = AuthorizationSequencePhoneEntryController(account: "")
        return vc
    }
    
    private func updateState(state: InnerState) {
        switch state {
        case .authorized:
            break
        case let .state(stateInfo):
            switch stateInfo {
            case .empty:
                var controllers: [ViewController] = []
                controllers.append(self.splashController())
                self.setViewControllers(controllers, animated: !self.viewControllers.isEmpty)
                break
            case .phoneEntry:
                var controllers: [ViewController] = []
                var previousSplashController: AuthorizationSequenceSplashController?
                for c in self.viewControllers {
                    if let c = c as? AuthorizationSequenceSplashController {
                        previousSplashController = c
                        break
                    }
                }
                controllers.append(self.phoneEntryController(splashController: previousSplashController))
                self.setViewControllers(controllers, animated: !self.viewControllers.isEmpty && (previousSplashController == nil || self.viewControllers.count > 2))
                break
            default:
                break
            }
        }
    }
    public func dismiss() {
        self.animateOut(completion: { [weak self] in
            self?.presentingViewController?.dismiss(animated: false, completion: nil)
        })
    }
    private func animateOut(completion: (() -> Void)? = nil) {
        self.view.layer.animatePosition(from: self.view.layer.position, to: CGPoint(x: self.view.layer.position.x, y: self.view.layer.position.y + self.view.layer.bounds.size.height), duration: 0.2, timingFunction: CAMediaTimingFunctionName.easeInEaseOut.rawValue, removeOnCompletion: false, completion: { _ in
            completion?()
        })
    }
}


//
//  AppDelegate.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/2/23.
//

import UIKit
import Display
import AsyncDisplayKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    @objc var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = NativeWindow(frame: UIScreen.main.bounds)
        let rootViewController = WindowRootViewController()
        window.rootViewController = rootViewController
        self.window = window
        self.window?.makeKeyAndVisible()
        self.present(AuthorizationSequenceController(account: ""))
        
        return true
    }

    public func present(_ controller: ContainableController) {
        let boundsSize = UIScreen.main.bounds
        let statusBarHeight: CGFloat = 64
        let safeInsets = UIEdgeInsets.zero
//        let initialLayout = WindowLayout(size: boundsSize, metrics: LayoutMetrics(widthClass: .regular, heightClass: .regular), statusBarHeight: statusBarHeight, forceInCallStatusBarText: "", inputHeight: 0.0, safeInsets: safeInsets, onScreenNavigationHeight: 10, upperKeyboardInputPositionBound: 10, inVoiceOver: UIAccessibility.isVoiceOverRunning)
//       let (controllerLayout, controllerFrame) = self.layoutForController(containerLayout: initialLayout, controller: controller)
//       controller.view.frame = controllerFrame
//        controller.containerLayoutUpdated(controllerLayout, transition: .immediate)
        guard let rooVC = window?.rootViewController else {
            return
        }
        let authVC = AuthorizationSequenceController(account: "")
        authVC.view.frame = rooVC.view.bounds
        rooVC.addChild(authVC)
        rooVC.view.addSubview(authVC.view)
            
    }
    private func layoutForController(containerLayout: ContainerViewLayout, controller: ContainableController) -> (ContainerViewLayout, CGRect) {
        return (containerLayout, CGRect(origin: CGPoint(), size: containerLayout.size))
    }
}


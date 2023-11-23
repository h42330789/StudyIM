//
//  StatusBarHost.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/23/23.
//

import UIKit
import Display

class ApplicationStatusBarHost: StatusBarHost {
    private let application = UIApplication.shared
    
    var isApplicationInForeground: Bool {
        switch self.application.applicationState {
        case .background:
            return false
        default:
            return true
        }
    }
    
    var statusBarFrame: CGRect {
        return self.application.statusBarFrame
    }
    var statusBarStyle: UIStatusBarStyle {
        get {
            return self.application.statusBarStyle
        } set(value) {
            self.setStatusBarStyle(value, animated: false)
        }
    }
    
    func setStatusBarStyle(_ style: UIStatusBarStyle, animated: Bool) {
        if self.shouldChangeStatusBarStyle?(style) ?? true {
            self.application.internalSetStatusBarStyle(style, animated: animated)
        }
    }
    
    var shouldChangeStatusBarStyle: ((UIStatusBarStyle) -> Bool)?
    
    func setStatusBarHidden(_ value: Bool, animated: Bool) {
        self.application.internalSetStatusBarHidden(value, animation: animated ? .fade : .none)
    }
    
    var keyboardWindow: UIWindow? {
        if #available(iOS 16.0, *) {
            return UIApplication.shared.internalGetKeyboard()
        }
        
//        for window in UIApplication.shared.windows {
//            if isKeyboardWindow(window: window) {
//                return window
//            }
//        }
        return nil
    }
    
    var keyboardView: UIView? {
        guard let keyboardWindow = self.keyboardWindow else {
            return nil
        }
        
//        for view in keyboardWindow.subviews {
//            if isKeyboardViewContainer(view: view) {
//                for subview in view.subviews {
//                    if isKeyboardView(view: subview) {
//                        return subview
//                    }
//                }
//            }
//        }
        return nil
    }
}

//
//  AppDelegate.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/2/23.
//

import UIKit
import Display

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    @objc var window: UIWindow?
    var mainWindow: Window1!
    private var authContextValue: UnauthorizedApplicationContext?
    private var contextValue: AuthorizedApplicationContext?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let statusBarHost = ApplicationStatusBarHost()
        // 创建window，以及持有window和rootVC的view
        let (window, hostView) = nativeWindowHostView()
        // 持有hostView、stausBar的类
        self.mainWindow = Window1(hostView: hostView, statusBarHost: statusBarHost)
        // rooVC.view
        hostView.containerView.backgroundColor = UIColor.orange
        self.window = window
        
        self.window?.makeKeyAndVisible()
        
        self.updateRootVC()
        return true
    }

    func updateRootVC() {
        if UserDefaults.standard.object(forKey: "isLogined") == nil {
            // 未登录，进入未登录流程
            if self.authContextValue == nil {
                self.authContextValue = UnauthorizedApplicationContext(account: "")
            }
            if let vc = self.authContextValue?.rootController {
                self.mainWindow.present(vc, on: .root)
            }
            self.mainWindow.viewController = nil
        } else {
            // 已登录流程
            if self.contextValue == nil {
                self.contextValue = AuthorizedApplicationContext(account: "")
            }
            if let vc = self.contextValue?.rootController {
                self.mainWindow.viewController = vc
            }
            self.authContextValue?.rootController.dismiss()
        }
    }
}


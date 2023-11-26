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
        // 未登录，进入未登录流程
        if UserDefaults.standard.object(forKey: "isLogined") == nil {
            self.authContextValue = UnauthorizedApplicationContext(account: "")
            
            if let cxt = self.authContextValue {
                self.mainWindow.present(cxt.rootController, on: .root)
            }
        } else {
            let rootVC = TelegramRootController(context: "")
            rootVC.addRootControllers(showCallsTab: false)
            self.mainWindow.viewController = rootVC
        }
        return true
    }

    
}


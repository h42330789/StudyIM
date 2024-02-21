//
//  AppDelegate.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/2/23.
//

import UIKit
import GDPerformanceView_Swift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    @objc var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: RootViewController())
        self.window = window
        
        self.window?.makeKeyAndVisible()
        

        PerformanceMonitor.shared().performanceViewConfigurator.options = [.all]
        PerformanceMonitor.shared().performanceViewConfigurator.style = .custom(backgroundColor: .black.withAlphaComponent(0.2), borderColor: .black, borderWidth: 1, cornerRadius: 5, textColor: .white, font: UIFont.systemFont(ofSize: 14))
        PerformanceMonitor.shared().start()
        if let monitorView = PerformanceMonitor.shared().performanceViewConfigurator as? UIView {
            window.addSubview(monitorView)
        }
        return true
    }

    
}


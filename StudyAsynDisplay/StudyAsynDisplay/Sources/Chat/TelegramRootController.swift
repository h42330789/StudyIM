//
//  TelegramRootController.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/27/23.
//

import Foundation
import Display

public final class TelegramRootController: NavigationController {
    public var rootTabController: TabBarController?
    public var contactsController: ViewController?
    public var callListController: ViewController?
    public var chatListController: ViewController?
    public var accountSettingsController: ViewController?
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public init(context: String) {
        let statusBar: NavigationStatusBarStyle = .black
        let navBar = AuthorizationSequenceController.navigationBarTheme("")
        let theme = NavigationControllerTheme(statusBar: statusBar, navigationBar: navBar , emptyAreaColor: .black)
        super.init(mode: .automaticMasterDetail, theme: theme)
    }
    
    public func addRootControllers(showCallsTab: Bool) {
        let tabBarController = TabBarControllerImpl(navigationBarPresentationData: nil)
        let contactsController = ViewController(navigationBarPresentationData: nil)
        contactsController.view.backgroundColor = .purple
        let callListController = ViewController(navigationBarPresentationData: nil)
        let chatListController = ViewController(navigationBarPresentationData: nil)
        let accountSettingsController = ViewController(navigationBarPresentationData: nil)
        var controllers: [ViewController] = []
        controllers.append(contactsController)
        
        if showCallsTab {
            controllers.append(callListController)
        }
        controllers.append(chatListController)
        controllers.append(accountSettingsController)
        
        tabBarController.setControllers(controllers, selectedIndex: (controllers.count - 2))
        
        self.contactsController = contactsController
        self.callListController = callListController
        self.chatListController = chatListController
        self.accountSettingsController = accountSettingsController
        self.rootTabController = tabBarController
        self.pushViewController(tabBarController, animated: false)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
}

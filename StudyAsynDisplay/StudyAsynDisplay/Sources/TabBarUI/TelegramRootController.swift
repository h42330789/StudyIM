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
        
        
        let contactsController = ContactsController(navigationBarPresentationData: nil)
        contactsController.view.backgroundColor = .red
        contactsController.tabBarItem.title = "contacts"
        contactsController.tabBarItem.image = UIImage(named: "IconContacts")
        contactsController.tabBarItem.selectedImage = UIImage(named: "IconContacts")
        
        let callListController = CallListController(navigationBarPresentationData: nil)
        callListController.view.backgroundColor = .green
        callListController.tabBarItem.title = "calls"
        callListController.tabBarItem.image = UIImage(named: "IconCalls")
        callListController.tabBarItem.selectedImage = UIImage(named: "IconCalls")
        
        let chatListController = ChatListController(navigationBarPresentationData: nil)
        chatListController.view.backgroundColor = .blue
        chatListController.tabBarItem.title = "chats"
        chatListController.tabBarItem.image = UIImage(named: "IconChats")
        chatListController.tabBarItem.selectedImage = UIImage(named: "IconChats")
        
        let accountSettingsController = AccountSettingsController(navigationBarPresentationData: nil)
        accountSettingsController.view.backgroundColor = .purple
        accountSettingsController.tabBarItem.title = "setting"
        accountSettingsController.tabBarItem.image = UIImage(named: "IconSettings")
        accountSettingsController.tabBarItem.selectedImage = UIImage(named: "IconSettings")
        
        
        var controllers: [ViewController] = []
        controllers.append(contactsController)
        
//        if showCallsTab {
            controllers.append(callListController)
//        }
        controllers.append(chatListController)
        controllers.append(accountSettingsController)
        // 设置默认选择chat
        tabBarController.setControllers(controllers, selectedIndex: (controllers.count - 2))
        
        self.contactsController = contactsController
        self.callListController = callListController
        self.chatListController = chatListController
        self.accountSettingsController = accountSettingsController
        self.rootTabController = tabBarController
        self.pushViewController(tabBarController, animated: false)
    }
    
    public func updateRootControllers(showCallsTab: Bool) {
        guard let rootTabController = self.rootTabController as? TabBarControllerImpl else {
            return
        }
        var controllers: [ViewController] = []
        controllers.append(self.contactsController!)
        if showCallsTab {
            controllers.append(self.callListController!)
        }
        controllers.append(self.chatListController!)
        controllers.append(self.accountSettingsController!)
        rootTabController.setControllers(controllers, selectedIndex: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
}

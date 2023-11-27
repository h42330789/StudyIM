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
        let tabBarController = TabBarControllerImpl(navigationBarPresentationData: nil, theme: TabBarControllerTheme(backgroundColor: .white, tabBarBackgroundColor: .white, tabBarSeparatorColor: .white, tabBarIconColor: .white, tabBarSelectedIconColor: .white, tabBarTextColor: .white, tabBarSelectedTextColor: .white, tabBarBadgeBackgroundColor: .white, tabBarBadgeStrokeColor: .white, tabBarBadgeTextColor: .white, tabBarExtractedIconColor: .white, tabBarExtractedTextColor: .white))
        let contactsController = ContactsController(navigationBarPresentationData: nil)
        contactsController.view.backgroundColor = .red
        let callListController = CallListController(navigationBarPresentationData: nil)
        callListController.view.backgroundColor = .green
        let chatListController = ChatListController(navigationBarPresentationData: nil)
        chatListController.view.backgroundColor = .blue
        let accountSettingsController = AccountSettingsController(navigationBarPresentationData: nil)
        accountSettingsController.view.backgroundColor = .purple
        var controllers: [ViewController] = []
        controllers.append(contactsController)
        
        if showCallsTab {
            controllers.append(callListController)
        }
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
    
//    public override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
//        let needsRootWallpaperBackgroundNode: Bool
//        if case .regular = layout.metrics.widthClass {
//            needsRootWallpaperBackgroundNode = true
//        } else {
//            needsRootWallpaperBackgroundNode = false
//        }
//        
////        if needsRootWallpaperBackgroundNode {
////            let detailsPlaceholderNode: detai
////        }
//        
//        super.containerLayoutUpdated(layout, transition: transition)
//    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
}

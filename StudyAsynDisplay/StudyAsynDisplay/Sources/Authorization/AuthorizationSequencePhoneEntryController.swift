//
//  AuthorizationSequencePhoneEntryController.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/25/23.
//

import Foundation
import Display
import AsyncDisplayKit
//import CountrySelectionUI

class AuthorizationSequencePhoneEntryController: ViewController {
    var controllerNode: AuthorizationSequencePhoneEntryControllerNode {
        return self.displayNode as! AuthorizationSequencePhoneEntryControllerNode
    }
    var validLayout: ContainerViewLayout?
    
    public init(account: String?) {
        super.init(navigationBarPresentationData: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadDisplayNode() {
        self.displayNode = AuthorizationSequencePhoneEntryControllerNode(strings: "")
        self.displayNodeDidLoad()
        self.controllerNode.selectCountryCode = { [weak self] in
//                let controller = AuthorizationSequenceCountrySelectionController(strings: "", theme: nil)
//                controller.completeWithCountryCode = { code, name in
////                    if let strongSelf = self, let currentData = strongSelf.currentData {
////                        strongSelf.updateData(countryCode: Int32(code), countryName: name, number: currentData.2)
////                        strongSelf.controllerNode.activateInput()
////                    }
//                }
//                controller.dismissed = {
//                    self?.controllerNode.activateInput()
//                }
//                self?.push(controller)
            if let app = UIApplication.shared.delegate as? AppDelegate {
                UserDefaults.standard.set("1", forKey: "isLogined")
                let rootVC = TelegramRootController(context: "")
                rootVC.addRootControllers(showCallsTab: false)
                app.mainWindow.viewController = rootVC
                if let nav = self?.navigationController as? AuthorizationSequenceController {
                    nav.dismiss()
                }
                
            }
        }
    }
    
    override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        let hadLayout = self.validLayout != nil
        if hadLayout == false {
//            self.updateNavigationItems()
        }
        self.controllerNode.containerLayoutUpdated(layout, navigationBarHeight: 100, transition: transition)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
}

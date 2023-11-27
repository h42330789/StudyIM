//
//  ApplicationContext.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/23/23.
//

import Foundation
import Display

class UnauthorizedApplicationContext {
    let rootController: AuthorizationSequenceController
    
    init(account: String) {
        self.rootController = AuthorizationSequenceController(account: account)
    }
}

class AuthorizedApplicationContext {
    let rootController: TelegramRootController
    
    init(account: String) {
        self.rootController = TelegramRootController(context: account)
        self.rootController.addRootControllers(showCallsTab: false)
    }
}

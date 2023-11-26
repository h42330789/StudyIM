//
//  TabBarControllerImpl.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/27/23.
//

import Foundation
import Display
import AsyncDisplayKit

class TabBarControllerImpl: ViewController, TabBarController {
    var currentController: ViewController?
    
    var controllers: [ViewController] = []
    
    var selectedIndex: Int = 0
    
    var cameraItemAndAction: (item: UITabBarItem, action: () -> Void)?
    
    func updateBackgroundAlpha(_ alpha: CGFloat, transition: ContainedViewLayoutTransition) {
        
    }
    
    public func viewForCameraItem() -> UIView? {
        return nil
    }
    
    func frameForControllerTab(controller: Display.ViewController) -> CGRect? {
        return nil
    }
    
    func isPointInsideContentArea(point: CGPoint) -> Bool {
        return false
    }
    
    func sourceNodesForController(at index: Int) -> [ASDisplayNode]? {
        return nil
    }
    
    func updateIsTabBarEnabled(_ value: Bool, transition: Display.ContainedViewLayoutTransition) {
        
    }
    
    func updateIsTabBarHidden(_ value: Bool, transition: Display.ContainedViewLayoutTransition) {
        
    }
    
    func updateLayout(transition: Display.ContainedViewLayoutTransition) {
        
    }
    
    public func setControllers(_ controllers: [ViewController], selectedIndex: Int?) {
       
        self.controllers = controllers
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .orange
    }
}

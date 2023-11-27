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
    var validLayout: ContainerViewLayout?
    var theme: TabBarControllerTheme
    
    private var tabBarControllerNode: TabBarControllerNode {
        get {
            return super.displayNode as! TabBarControllerNode
        }
    }
    public var currentController: ViewController?
    
    public private(set) var controllers: [ViewController] = []
    
    public var _selectedIndex: Int?
    public var selectedIndex: Int {
        get {
            if let _selectedIndex = self._selectedIndex {
                return _selectedIndex
            } else {
                return 0
            }
        } set(value) {
            let index = max(0, min(self.controllers.count - 1, value))
            if _selectedIndex != index {
                _selectedIndex = index
            }
        }
    }
    
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
    
    // MARK: - 宽高布局
    func updateLayout(transition: ContainedViewLayoutTransition) {
        
    }
    // MARK: 切换tab
    public func setControllers(_ controllers: [ViewController], selectedIndex: Int?) {
       
        var updatedSelectedIndex: Int? = selectedIndex
        if updatedSelectedIndex == nil, let selectedIndex = self._selectedIndex, selectedIndex < self.controllers.count {
            if let index = controllers.firstIndex(where: { $0 === self.controllers[selectedIndex] }) {
                updatedSelectedIndex = index
            } else {
                updatedSelectedIndex = 0
            }
        }
        self.controllers = controllers
        
//        let tabBarItems = self.controllers.map { TabBarNodeItem(item: $0.tabBarItem) }
//        self.tabBarControllerNode.tabBarNode.tabBarItems = tabBarItems
        
        if let updatedSelectedIndex = updatedSelectedIndex {
            self.selectedIndex = updatedSelectedIndex
            self.updateSelectedIndex()
        }
    }
    private func updateSelectedIndex() {
        if self.isNodeLoaded == false {
            return
        }
        let tabBarSelectedIndex = self.selectedIndex
        self.tabBarControllerNode.tabBarNode.selectedIndex = tabBarSelectedIndex
        
        // 将旧的controller移除
        if let currentController = self.currentController {
            currentController.willMove(toParent: nil)
            self.tabBarControllerNode.currentControllerNode = nil
            currentController.removeFromParent()
            currentController.didMove(toParent: nil)
        }
        // 获取新的controller
        if let _selectedIndex = self._selectedIndex, _selectedIndex < self.controllers.count {
            self.currentController = self.controllers[_selectedIndex]
        }
        if let currentController = self.currentController {
            currentController.willMove(toParent: self)
            self.tabBarControllerNode.currentControllerNode = currentController.displayNode
            self.addChild(currentController)
            currentController.didMove(toParent: self)
            
            currentController.displayNode.recursivelyEnsureDisplaySynchronously(true)
            self.statusBar.statusBarStyle = currentController.statusBar.statusBarStyle
        }
        
        if let layout = self.validLayout {
            self.containerLayoutUpdated(layout, transition: .immediate)
        }
    }
    override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        self.validLayout = layout
        
//        self.tabBarControllerNode.conupdate
        if let currentController = self.currentController {
            currentController.view.frame = CGRect(origin: .zero, size: layout.size)
            
            var updatedLayout = layout
            
            var tabBarHeight: CGFloat
            var options: ContainerViewLayoutInsetOptions = []
            if updatedLayout.metrics.widthClass == .regular {
                options.insert(.input)
            }
            let bottomInset: CGFloat = updatedLayout.insets(options: options).bottom
            if !updatedLayout.safeInsets.left.isZero {
                tabBarHeight = 34.0 + bottomInset
            } else {
                tabBarHeight = 49.0 + bottomInset
            }
            updatedLayout.intrinsicInsets.bottom = tabBarHeight
            
            currentController.containerLayoutUpdated(updatedLayout, transition: transition)
        }
    }
    // MARK: - TabVC生命周期
    
    // MARK: - Node
    override func loadDisplayNode() {
        self.displayNode = TabBarControllerNode(theme: self.theme)
        
        self.updateSelectedIndex()
        self.displayNodeDidLoad()
    }
    
    
    
    
    init(navigationBarPresentationData: NavigationBarPresentationData?, theme: TabBarControllerTheme) {
        self.theme = theme
        super.init(navigationBarPresentationData: navigationBarPresentationData)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .orange
    }
}

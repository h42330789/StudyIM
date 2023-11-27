//
//  TabBarControllerNode.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/27/23.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Display

class TabBarNodeItem {
    let item: UITabBarItem
    init(item: UITabBarItem) {
        self.item = item
    }
}

class TabBarItemNode: ASDisplayNode {
//    let extractedContainerNode: ContextExtractedContentContainingNode
//    let containerNode: ContextControllerSourceNode
//    let imageNode: ASImageNode
//    let animationContainerNode: ASDisplayNode
    
}

class TabBarNode: ASDisplayNode, UIGestureRecognizerDelegate {
    var tabBarItems: [TabBarNodeItem] = [] {
        didSet {
            self.reloadTabBarItems()
        }
    }
    private func reloadTabBarItems() {
    }
    var selectedIndex: Int? {
        didSet {
            if self.selectedIndex != oldValue {
                if let oldValue = oldValue {
                    self.updateNodeImage(oldValue, layout: true)
                }
                
                if let selectedIndex = self.selectedIndex {
                    self.updateNodeImage(selectedIndex, layout: true)
                }
            }
        }
    }
    private func updateNodeImage(_ index: Int, layout: Bool) {
    }
}

final class TabBarControllerNode: ASDisplayNode {
    let tabBarNode: TabBarNode
//    private let disabledOverlayNode: ASDisplayNode
    private var theme: TabBarControllerTheme
    var currentControllerNode: ASDisplayNode? {
        didSet {
            oldValue?.removeFromSupernode()
            if let currentControllerNode = self.currentControllerNode {
                self.insertSubnode(currentControllerNode, at: 0)
            }
        }
    }
    
    init(theme: TabBarControllerTheme) {
        self.theme = theme
        self.tabBarNode = TabBarNode()
        super.init()
        
        self.setViewBlock({
            return UITracingLayerView()
        })
        
        self.addSubnode(self.tabBarNode)
    }
    
    override func didLoad() {
        super.didLoad()
    }
//    private var toolbarNode:
}
public final class TabBarControllerTheme {
    public let backgroundColor: UIColor
    public let tabBarBackgroundColor: UIColor
    public let tabBarSeparatorColor: UIColor
    public let tabBarIconColor: UIColor
    public let tabBarSelectedIconColor: UIColor
    public let tabBarTextColor: UIColor
    public let tabBarSelectedTextColor: UIColor
    public let tabBarBadgeBackgroundColor: UIColor
    public let tabBarBadgeStrokeColor: UIColor
    public let tabBarBadgeTextColor: UIColor
    public let tabBarExtractedIconColor: UIColor
    public let tabBarExtractedTextColor: UIColor

    public init(backgroundColor: UIColor, tabBarBackgroundColor: UIColor, tabBarSeparatorColor: UIColor, tabBarIconColor: UIColor, tabBarSelectedIconColor: UIColor, tabBarTextColor: UIColor, tabBarSelectedTextColor: UIColor, tabBarBadgeBackgroundColor: UIColor, tabBarBadgeStrokeColor: UIColor, tabBarBadgeTextColor: UIColor, tabBarExtractedIconColor: UIColor, tabBarExtractedTextColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.tabBarBackgroundColor = tabBarBackgroundColor
        self.tabBarSeparatorColor = tabBarSeparatorColor
        self.tabBarIconColor = tabBarIconColor
        self.tabBarSelectedIconColor = tabBarSelectedIconColor
        self.tabBarTextColor = tabBarTextColor
        self.tabBarSelectedTextColor = tabBarSelectedTextColor
        self.tabBarBadgeBackgroundColor = tabBarBadgeBackgroundColor
        self.tabBarBadgeStrokeColor = tabBarBadgeStrokeColor
        self.tabBarBadgeTextColor = tabBarBadgeTextColor
        self.tabBarExtractedIconColor = tabBarExtractedIconColor
        self.tabBarExtractedTextColor = tabBarExtractedTextColor
    }
    
//    public convenience init(rootControllerTheme: PresentationTheme) {
//        let theme = rootControllerTheme.rootController.tabBar
//        self.init(backgroundColor: rootControllerTheme.list.plainBackgroundColor, tabBarBackgroundColor: theme.backgroundColor, tabBarSeparatorColor: theme.separatorColor, tabBarIconColor: theme.iconColor, tabBarSelectedIconColor: theme.selectedIconColor, tabBarTextColor: theme.textColor, tabBarSelectedTextColor: theme.selectedTextColor, tabBarBadgeBackgroundColor: theme.badgeBackgroundColor, tabBarBadgeStrokeColor: theme.badgeStrokeColor, tabBarBadgeTextColor: theme.badgeTextColor, tabBarExtractedIconColor: rootControllerTheme.contextMenu.extractedContentTintColor, tabBarExtractedTextColor: rootControllerTheme.contextMenu.extractedContentTintColor)
//    }
}

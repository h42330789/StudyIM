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

final class TabBarControllerNode: ASDisplayNode {
    
    let tabBarNode: TabBarNode
    
    // 设置选择的tabbar，将旧的node移除，让新的node展示
    var currentControllerNode: ASDisplayNode? {
        didSet {
            oldValue?.removeFromSupernode()
            if let currentControllerNode = self.currentControllerNode {
                self.insertSubnode(currentControllerNode, at: 0)
            }
        }
    }
    
    init(itemSelected: @escaping TabBarNode.ItemSelectedBlock) {
        // 底部选择栏tabbar
        self.tabBarNode = TabBarNode(itemSelected: itemSelected)
        super.init()
        
        self.setViewBlock({
            return UITracingLayerView()
        })
        // 将选择栏添加到子node中
        self.addSubnode(self.tabBarNode)
    }
    var tabBarHeight: CGFloat = 0
    func updateTabBarHeightAndBottomInset(layout: ContainerViewLayout) -> CGFloat {
        // 1、计算tabbar的高度
        var tabBarHeight: CGFloat
        var options: ContainerViewLayoutInsetOptions = []
        if layout.metrics.widthClass == .regular {
            options.insert(.input)
        }
        let bottomInset: CGFloat = layout.insets(options: options).bottom
        if layout.safeInsets.left.isZero == false {
            tabBarHeight = 34.0 + bottomInset
        } else {
            tabBarHeight = 49.0 + bottomInset
        }
        self.tabBarHeight = tabBarHeight
        return bottomInset
    }
    func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        // 更新UI布局
        // 1、计算tabbar的高度
        let bottomInset = self.updateTabBarHeightAndBottomInset(layout: layout)
        // 计算tabbar的frame
        // layout是整体屏幕的信息
        let tabBarFrame = CGRect(origin: CGPoint(x: 0, y: layout.size.height - tabBarHeight), size: CGSize(width: layout.size.width, height: tabBarHeight))
        // 更新tabbar的frame信息
        transition.updateFrame(node: self.tabBarNode, frame: tabBarFrame)
        // 更新tabBarNode的布局
        self.tabBarNode.updateLayout(size: layout.size, leftInset: layout.safeInsets.left, rightInset: layout.safeInsets.right, additionalSideInsets: layout.additionalInsets, bottomInset: bottomInset, transition: transition)
    }

}

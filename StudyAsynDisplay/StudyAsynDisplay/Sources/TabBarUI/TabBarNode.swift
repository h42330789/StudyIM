//
//  TabBarNode.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 12/6/23.
//

import Foundation
import Display
import AsyncDisplayKit

class TabBarNodeContainer {
    let item: UITabBarItem
    let imageNode: TabBarItemNode
    
    init(item: TabBarNodeItem, imageNode: TabBarItemNode) {
        self.item = item.item
        self.imageNode = imageNode
    }
}

class TabBarItemNode: ASDisplayNode {

}

class TabBarNode: ASDisplayNode, UIGestureRecognizerDelegate {
    typealias ItemSelectedBlock = (Int, Bool, [ASDisplayNode]) -> Void
    private var validLayout: (CGSize, CGFloat, CGFloat, UIEdgeInsets, CGFloat)?
    let separatorNode: ASDisplayNode
    private var tabBarNodeContainers: [TabBarNodeContainer] = []
    private var tapRecognizer: TapLongTapOrDoubleTapGestureRecognizer?
    private var itemSelected: ItemSelectedBlock?
    
    init(itemSelected: @escaping ItemSelectedBlock) {
        self.separatorNode = ASDisplayNode()
        self.separatorNode.backgroundColor = .black
        self.separatorNode.isOpaque = true
        self.separatorNode.isLayerBacked = true
        self.itemSelected = itemSelected
        
        
        super.init()
        
        self.backgroundColor = .systemGray
        self.addSubnode(self.separatorNode)
    }
    
    override func didLoad() {
        super.didLoad()
        
        let tapRecognizer = TapLongTapOrDoubleTapGestureRecognizer(target: self, action: #selector(self.tapLongTapOrDoubleTapGesture(_:)))
        tapRecognizer.delegate = self
        tapRecognizer.tapActionAtPoint = { _ in
            return .keepWithSingleTap
        }
        self.tapRecognizer = tapRecognizer
        self.view.addGestureRecognizer(tapRecognizer)
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        return true
    }
    @objc private func tapLongTapOrDoubleTapGesture(_ recognizer: TapLongTapOrDoubleTapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let (gesture, location) = recognizer.lastRecognizedGestureAndLocation {
                if case .tap = gesture {
                    self.tapped(at: location, longTap: false)
                }
            }
        default:
            break
        }
    }
    private func tapped(at location: CGPoint, longTap: Bool) {
        if let bottomInset = self.validLayout?.4 {
            if location.y > self.bounds.size.height - bottomInset {
                return
            }
            var closestNode: (Int, CGFloat)?
            
            for i in 0 ..< self.tabBarNodeContainers.count {
                let node = self.tabBarNodeContainers[i].imageNode
                if !node.isUserInteractionEnabled {
                    continue
                }
                let distance = abs(location.x - node.position.x)
                if let previousClosestNode = closestNode {
                    if previousClosestNode.1 > distance {
                        closestNode = (i, distance)
                    }
                } else {
                    closestNode = (i, distance)
                }
            }
            
            if let closestNode = closestNode {
                let container = self.tabBarNodeContainers[closestNode.0]
                self.itemSelected?(closestNode.0, longTap, [container.imageNode])
            }
        }
    }
    // 设置items，更新UI
    var tabBarItems: [TabBarNodeItem] = [] {
        didSet {
            self.reloadTabBarItems()
        }
    }
    // MARK: 更新选中的项
    var selectedIndex: Int? {
        didSet {
            if self.selectedIndex != oldValue {
                // 如果选中的和之前的不是同一个
                if let oldValue = oldValue {
                    // 更新旧的item
                    self.updateNodeImage(oldValue, layout: true)
                }
                if let selectedIndex = self.selectedIndex {
                    // 更新新的item
                    self.updateNodeImage(selectedIndex, layout: true)
                }
            }
        }
    }
    private func reloadTabBarItems() {
        // 对旧的内容进行清除
        for node in self.tabBarNodeContainers {
            node.imageNode.removeFromSupernode()
        }
        // 重新布局items
        var tabBarNodeContainers: [TabBarNodeContainer] = []
        for i in 0 ..< self.tabBarItems.count {
            let item = self.tabBarItems[i]
            let node = TabBarItemNode()
            node.backgroundColor = .white
            let container = TabBarNodeContainer(item: item, imageNode: node)
            tabBarNodeContainers.append(container)
            self.addSubnode(node)
        }
        self.tabBarNodeContainers = tabBarNodeContainers

    }

    private func updateNodeImage(_ index: Int, layout: Bool) {
        // 判断是否越界
        guard index < self.tabBarNodeContainers.count else {
            return
        }
        // 拿到tabItem的node
        let node = self.tabBarNodeContainers[index].imageNode
        if index == self.selectedIndex {
            node.backgroundColor = .green
        } else {
            node.backgroundColor = .white
        }
        
    }
    
    private let separatorHeight: CGFloat = 1.0 / UIScreen.main.scale
    // MARK: 更新Frame
    func updateLayout(size: CGSize, leftInset: CGFloat, rightInset: CGFloat, additionalSideInsets: UIEdgeInsets, bottomInset: CGFloat, transition: ContainedViewLayoutTransition) {
        self.validLayout = (size, leftInset, rightInset, additionalSideInsets, bottomInset)
        
        transition.updateFrame(node: self.separatorNode, frame: CGRect(origin: .zero, size: CGSize(width: size.width, height: separatorHeight)))
        
        // 对item进行布局
        let width = size.width
        // 平均每个item的宽度
        let distanceBetweenNodes = width / CGFloat(tabBarNodeContainers.count)
        
        for i in 0 ..< tabBarNodeContainers.count {
            let container = tabBarNodeContainers[i]
            let node = container.imageNode
            // node的真实宽高
            let nodeSize = CGSize(width: 45, height: 45)
            let leftItemRight = CGFloat(i) * distanceBetweenNodes
            // 当前item在当前平分位置的中间
            let currentItemLeft = (distanceBetweenNodes - nodeSize.width)/2
            let originX = floor(leftItemRight + currentItemLeft)
            let nodeFrame = CGRect(origin: CGPoint(x: originX, y: 3.0), size: nodeSize)
            transition.updateFrame(node: node, frame: nodeFrame)
        }
    }
}

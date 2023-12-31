//
//  TabBarNode.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 12/6/23.
//

import Foundation
import Display
import AsyncDisplayKit
import AnimatedStickerNode
import TelegramAnimatedStickerNode

class TabBarNodeContainer {
    let item: UITabBarItem
    let imageNode: TabBarItemNode
    
    init(item: TabBarNodeItem, imageNode: TabBarItemNode) {
        self.item = item.item
        self.imageNode = imageNode
    }
}
// MARK: - TabBarItemNode
class TabBarItemNode: ASDisplayNode {
    let extractedContainerNode: ContextExtractedContentContainingNode
    let containerNode: ContextControllerSourceNode
    // 选中
    let imageNode: ASImageNode
    let textImageNode: ASImageNode
    // 非选中
    let contextImageNode: ASImageNode
    let contextTextImageNode: ASImageNode
    // 动画
    let animationContainerNode: ASDisplayNode
    let animationNode: AnimatedStickerNode
    
    var contentWidth: CGFloat?
    var isSelected: Bool = false
    
    override init() {
        self.extractedContainerNode = ContextExtractedContentContainingNode()
        self.containerNode = ContextControllerSourceNode()
        
        self.imageNode = ASImageNode()
        self.textImageNode = ASImageNode()
        
        self.animationContainerNode = ASDisplayNode()
        self.animationNode = DefaultAnimatedStickerNodeImpl()
        self.animationNode.autoplay = true
        self.animationNode.automaticallyLoadLastFrame = true
        
        self.contextImageNode = ASImageNode()
        self.contextImageNode.alpha = 0
        self.contextTextImageNode = ASImageNode()
        self.contextTextImageNode.alpha = 0
        
        super.init()
        // 选中时展示的内容
        self.extractedContainerNode.contentNode.addSubnode(self.textImageNode)
        self.extractedContainerNode.contentNode.addSubnode(self.imageNode)
        
        self.extractedContainerNode.contentNode.addSubnode(self.animationContainerNode)
        self.animationContainerNode.addSubnode(self.animationNode)
        
        // 未选中时展示的内容
        self.extractedContainerNode.contentNode.addSubnode(self.contextTextImageNode)
        self.extractedContainerNode.contentNode.addSubnode(self.contextImageNode)
        
        self.containerNode.addSubnode(self.extractedContainerNode)
        self.addSubnode(self.containerNode)
        
    }
}
// MARK: 使用图片、字符串生成新图片
extension CGSize {
    static var maxSize: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }
}
extension String {
    func sizeInMaxSize(with font: UIFont) -> CGSize {
        let text = self as NSString
        let size = text.boundingRect(with: CGSize.maxSize, options: [.usesLineFragmentOrigin], attributes: [.font: font], context: nil).size
        return size
    }
}
private func tabBarItemImage(_ image: UIImage?, title: String?, tintColor: UIColor, imageMode: Bool) -> (UIImage, CGFloat) {
    let font = Font.medium(10)
    // 文字的大小
    let titleText = title ?? ""
    let titleSize = titleText.sizeInMaxSize(with: font)
    // 图片的大小
    let imageSize = image?.size ?? .zero
    let width = max(1, titleSize.width, imageSize.width)
    let contentWidth = imageSize.width
    // 整体内容的大小
    let size = CGSize(width: width, height: 45)
    // 绘图
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(UIColor.clear.cgColor)
    context?.fill(CGRect(origin: .zero, size: size))
    // 如果有图片且是图片模式时，需要将图片也绘制
    if let image = image, imageMode == true {
        let imageRect = CGRect(origin: CGPoint(x: (size.width - imageSize.width)/2, y: 0), size: imageSize)
        context?.saveGState()
        context?.translateBy(x: imageRect.midX, y: imageRect.midY)
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: -imageRect.midX, y: -imageRect.midY)
        context?.clip(to: imageRect, mask: image.cgImage!)
        context?.setFillColor(tintColor.cgColor)
        context?.fill(imageRect)
        context?.restoreGState()
    }
    // 绘制文字在居中靠近底部
    if imageMode == false {
        (titleText as NSString).draw(at: CGPoint(x: (size.width - titleSize.width)/2, y: size.height - titleSize.height - 1), withAttributes: [.font: font, .foregroundColor: tintColor])
    }
    // 获取图片
    let resultImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return (resultImage!, contentWidth)
}
// MARK: - TabBarNode
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
        
        self.backgroundColor = .lightGray
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
    // MARK: 初始化items
    private func reloadTabBarItems() {
        // 对旧的内容进行清除
        for node in self.tabBarNodeContainers {
            node.imageNode.removeFromSupernode()
        }
        // 重新布局items
        var tabBarNodeContainers: [TabBarNodeContainer] = []
        for index in 0 ..< self.tabBarItems.count {
            let itemModel = self.tabBarItems[index]
            let item = itemModel.item
            let node = TabBarItemNode()
            
            // 设置图片
            updateTabItem(index, item: item, node: node)
            
            let container = TabBarNodeContainer(item: itemModel, imageNode: node)
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
        let item = self.tabBarNodeContainers[index].item
        updateTabItem(index, item: item, node: node)
    }
    
    func updateTabItem(_ index: Int, item: UITabBarItem, node: TabBarItemNode) {
        // 设置图片
        if index == self.selectedIndex {
            let selectedTintColor = UIColor.blue
            // 选中的 文字+图片
            let (textImage, contentWidth) = tabBarItemImage(item.selectedImage, title: item.title, tintColor: selectedTintColor, imageMode: false)
            let (image, imageContentWidth): (UIImage, CGFloat)
            if let _ = item.animationName {
                // 有动画
                (image, imageContentWidth) = (UIImage(), 0)
                node.animationNode.isHidden = false
                let animationSize = Int(51.0 * UIScreen.main.scale)
                node.animationNode.visibility = true
                if node.isSelected == false {
                    // 如果不是选中状态, 播放动画
                    node.animationNode.setup(source: AnimatedStickerNodeLocalFileSource(name: item.animationName ?? ""), width: animationSize, height: animationSize, playbackMode: .once, mode: .direct(cachePathPrefix: nil))
                }
                node.animationNode.setOverlayColor(selectedTintColor, replace: true, animated: false)
                node.animationNode.updateLayout(size: CGSize(width: 51.0, height: 51.0))
            } else {
                // 没有动画，将图片设置tintColor
                (image, imageContentWidth) = tabBarItemImage(item.selectedImage, title: item.title, tintColor: selectedTintColor, imageMode: true)
                node.animationNode.isHidden = true
                node.animationNode.visibility = false
            }
            node.textImageNode.image = textImage
            node.imageNode.image = image
            
            
            // 未选中的文字+图片
            let (contextTextImage, _) = tabBarItemImage(item.image, title: item.title, tintColor: .gray, imageMode: false)
            let (contextImage, _) = tabBarItemImage(item.image, title: item.title, tintColor: .gray, imageMode: true)
            node.contextTextImageNode.image = contextTextImage
            node.contextImageNode.image = contextImage
            // 设置item的宽度，
            node.contentWidth = max(contentWidth, imageContentWidth)
            node.isSelected = true
        } else {
            // 未选中的 文字+图片
            let (textImage, contentWidth) = tabBarItemImage(item.image, title: item.title, tintColor: .gray, imageMode: false)
            let (image, imageContentWidth) = tabBarItemImage(item.image, title: item.title, tintColor: .gray, imageMode: true)
            // 选中的文字+图片
            let (contextTextImage, _) = tabBarItemImage(item.selectedImage, title: item.title, tintColor: .blue, imageMode: false)
            let (contextImage, _) = tabBarItemImage(item.selectedImage, title: item.title, tintColor: .blue, imageMode: true)
            
            // 动画不可见
            node.animationNode.isHidden = true
            node.animationNode.visibility = false
            
            node.textImageNode.image = textImage
            node.imageNode.image = image
            node.contextTextImageNode.image = contextTextImage
            node.contextImageNode.image = contextImage
            node.contentWidth = max(contentWidth, imageContentWidth)
            node.isSelected = false
        }
    }
    
    private let separatorHeight: CGFloat = 1.0 / UIScreen.main.scale
    // MARK: 更新Frame
    func updateLayout(size: CGSize, leftInset: CGFloat, rightInset: CGFloat, additionalSideInsets: UIEdgeInsets, bottomInset: CGFloat, transition: ContainedViewLayoutTransition) {
        self.validLayout = (size, leftInset, rightInset, additionalSideInsets, bottomInset)
        // MARK: 更新分割线的frame
        transition.updateFrame(node: self.separatorNode, frame: CGRect(origin: .zero, size: CGSize(width: size.width, height: separatorHeight)))
        
        // 对item进行布局
        let width = size.width
        // 平均每个item的宽度
        let distanceBetweenNodes = width / CGFloat(tabBarNodeContainers.count)
        
        for i in 0 ..< tabBarNodeContainers.count {
            let container = tabBarNodeContainers[i]
            let node = container.imageNode
            // node的真实宽高
            let nodeSize = node.textImageNode.image?.size ?? CGSize()
            let leftItemRight = CGFloat(i) * distanceBetweenNodes
            // 当前item在当前平分位置的中间
            let currentItemLeft = (distanceBetweenNodes - nodeSize.width)/2
            let originX = floor(leftItemRight + currentItemLeft)
            let nodeFrame = CGRect(origin: CGPoint(x: originX, y: 3.0), size: nodeSize)
            // MARK: 更新每个item的frame
            transition.updateFrame(node: node, frame: nodeFrame)
            // MARK: 更新每个item的内容的frame
            node.imageNode.frame = CGRect(origin: .zero, size: nodeFrame.size)
            node.textImageNode.frame = CGRect(origin: .zero, size: nodeFrame.size)
            node.contextImageNode.frame = CGRect(origin: .zero, size: nodeFrame.size)
            node.contextTextImageNode.frame = CGRect(origin: .zero, size: nodeFrame.size)
            // MARK: 动画node的frame
            let animationOffset = self.tabBarItems[i].item.animationOffset
            // nodeSize=45,45
            let animationNodeSize = CGSize(width: 51, height: 51)
            // 左右居中，顶部固定位置-10，
            let animationNodeOrigin = CGPoint(x: floorToScreenPixels((nodeSize.width - animationNodeSize.width) / 2.0), y: -10.0 - UIScreenPixel).offsetBy(dx: animationOffset.x, dy: animationOffset.y)
            node.animationNode.frame = CGRect(origin: animationNodeOrigin, size: animationNodeSize)
        }
    }
}

//
//  MySwipeDeleteListVC.swift
//  StudyAsynDisplay
//
//  Created by flow on 3/4/24.
//

import Foundation
import AsyncDisplayKit
import Display
import SwiftSignalKit
import MergeLists

class MySwipeDeleteListVC: UIViewController {
    lazy var listViewNode: ListView = {
        let node = ListView()
        node.frame = self.view.bounds.changeOffset(dy: 100, dh: -100)
        node.scroller.showsVerticalScrollIndicator = true
        return node
    }()
    
    lazy var dataList: [NormalDataModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubnode(listViewNode)
        // 将 数据 -> UIModel -> InsertItem
        let newList = Array(0...9999).map{ NormalDataModel(avator: "", title: "title\($0)", status: "status\($0)", date: "date\($0)") }
        self.updateData(newList: newList)
    }
    
    func updateData(newList: [NormalDataModel], isShowReverse: Bool = false) {
        // 将数据转换为delete、insert、update
        // ([deleteIndex], [(index, dataModel, previousIndex)], [(index, dataModel, previousIndex)])
        let (deleteIndices, insertIndices, updateIndices) = mergeListsStableWithUpdates(leftList: self.dataList, rightList: newList, allUpdated: true)
        // 需要删除的内容
        let previousCount = self.dataList.count
        var deleteList: [ListViewDeleteItem] = []
        for index in deleteIndices {
            // 由于数据时倒序，真正的index是反着的
            let realIndex = isShowReverse ? (previousCount - 1 - index) : index
            deleteList.append(ListViewDeleteItem(index: realIndex, directionHint: nil))
        }
        // 需要添加的内容
        let updatedCount = newList.count
        let maxAnimatedInsertionIndex = -1
        var insertList: [ListViewInsertItem] = []
        for (index, dataModel, previousIndex) in insertIndices {
            // 由于是倒序，真正的index需要反着算
            // 数据时A、B、C，转换后展示成C、B、A
            // 真正的位置
            let adjustedIndex = isShowReverse ? (updatedCount - 1 - index) : index
            // 前一个位置
            let adjustedPrevousIndex: Int?
            if let previousIndex = previousIndex {
                // 由于数据与UI是反向的，所以计算真正的位置需要反着算
                adjustedPrevousIndex = isShowReverse ? (previousCount - 1 - previousIndex) : previousIndex
            } else {
                adjustedPrevousIndex = nil
            }
            // 方向
            var directionHint: ListViewItemOperationDirectionHint?
            if maxAnimatedInsertionIndex >= 0 && adjustedIndex <= maxAnimatedInsertionIndex {
                directionHint = .Down
            }
            
            let item = MySwipeDeleteItem(data: dataModel)
            let insertItem = ListViewInsertItem(index: adjustedIndex, previousIndex: adjustedPrevousIndex, item: item, directionHint: directionHint)
            insertList.append(insertItem)
        }
        // 更新的内容
        var updateList: [ListViewUpdateItem] = []
        for (index, dataModel, previousIndex) in updateIndices {
            // 数据与UI是反向的，需要倒着算位置
            let adjustedIndex = isShowReverse ? (updatedCount - 1 - index) : index
            let adjustedPreviousIndex = isShowReverse ? (previousCount - 1 - previousIndex) : previousIndex
            
            let directionHint: ListViewItemOperationDirectionHint? = nil
            let uiModel = NormalUIModel(data: dataModel)
            let updateItem = ListViewUpdateItem(index: adjustedIndex, previousIndex: adjustedPreviousIndex, item: uiModel, directionHint: directionHint)
            updateList.append(updateItem)
        }
        
        // listView的size信息
        let updateSizeAndInsets = ListViewUpdateSizeAndInsets(size: listViewNode.frame.size, insets: UIEdgeInsets.zero, duration: 0, curve: .Default(duration: nil))
        // option
        var options: ListViewDeleteAndInsertOptions = []
        let _ = options.insert(.LowLatency)
//        let _ = options.insert(.Synchronous)
        let _ = options.insert(.PreferSynchronousResourceLoading)
        
        // 需要更新的内容
        listViewNode.transaction(deleteIndices: deleteList, insertIndicesAndItems: insertList, updateIndicesAndItems: [], options: options, scrollToItem: nil, updateSizeAndInsets: updateSizeAndInsets, stationaryItemRange: nil, updateOpaqueState: nil, completion: { _ in })
        self.dataList = newList
    }
}

// MARK: - Item
class MySwipeDeleteItem: ListViewItem {
    var data: NormalDataModel
    // 是否可以点击
    let selectable: Bool = true
    init(data: NormalDataModel) {
        self.data = data
    }
    
    // MARK: - 创建Node时的回掉
    func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        // 在异步线程执行
        async {
            // UI上的Node，相当于自定义的UITableViewCell
            let node = MySwipeDeleteItemNode()
            let makeLayout = node.asyncLayout()
            let first = previousItem == nil
            let last = nextItem == nil
            // 执行计算布局
            let (nodeLayout, nodeApply) = makeLayout(self, params, first, last)
            node.contentSize = nodeLayout.contentSize
            node.insets = nodeLayout.insets
            
            // 返回主线程回调
            Queue.mainQueue().async {
                completion(node, {
                    return (nil, { _ in
                        nodeApply(synchronousLoads).1(false)
                    })
                })
            }
        }
    }
    
    func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: @escaping () -> ListViewItemNode, params: ListViewItemLayoutParams, previousItem: ListViewItem?, nextItem: ListViewItem?, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping (ListViewItemApply) -> Void) -> Void) {
//        Queue.mainQueue().async {
//            if let nodeValue = node() as? MySwipeDeleteItemNode {
//                let layout = nodeValue.asyncLayout()
//                async {
////                    let (first, last, firstWithHeader) = CallListCallItem.mergeType(item: self, previousItem: previousItem, nextItem: nextItem)
////                    let (nodeLayout, apply) = layout(self, params, first, last, firstWithHeader, callListNeighbors(item: self, topItem: previousItem, bottomItem: nextItem))
////                    var animated = true
////                    if case .None = animation {
////                        animated = false
////                    }
//                    Queue.mainQueue().async {
//                        completion(nodeLayout, { _ in
//                            apply(false).1(animated)
//                        })
//                    }
//                }
//            }
//        }
    }
    // MARK: 点击时的回掉
    func selected(listView: ListView) {
        // 设置不展示高亮
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            listView.clearHighlightAnimated(true)
        })
        
        print("\(self.data.title)")
    }
}
// MAKR: - Node
class MySwipeDeleteItemNode: ListViewItemNode {
    // 背景
    private let backgroundNode: ASDisplayNode
    // 高亮时的背景
    private let highlightedBackgroundNode: ASDisplayNode
    // 底部分隔线
    private let bottomStripeNode: ASDisplayNode
    // 容器
    private let containerNode: ASDisplayNode
    

    private let titleNode: TextNode // 标题
    private let infoButtonNode: HighlightableButtonNode // 右侧的按钮
    
    required init() {
        
        // 背景
        self.backgroundNode = ASDisplayNode()
        self.backgroundNode.isLayerBacked = true
        
        // 高亮时的背景
        self.highlightedBackgroundNode = ASDisplayNode()
        self.highlightedBackgroundNode.backgroundColor = UIColor(red: 232.0/255, green: 232.0/255, blue: 231.0/255, alpha: 1)
        self.highlightedBackgroundNode.isLayerBacked = true
        
        // 容器
        self.containerNode = ASDisplayNode()
        
        // 底部的线
        self.bottomStripeNode = ASDisplayNode(isLayerBacked: true, backgroundColor: .lightGray)
        
        self.titleNode = TextNode()
        
        // 右侧info的按钮，响应区域变大
        self.infoButtonNode = HighlightableButtonNode()
        self.infoButtonNode.hitTestSlop = UIEdgeInsets(top: -6.0, left: -6.0, bottom: -6.0, right: -10.0)
        
        
        super.init(layerBacked: false, dynamicBounce: false, rotated: false, seeThrough: false)
        // 添加显示内容
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.bottomStripeNode)
        self.addSubnode(self.containerNode)
        self.containerNode.addSubnode(self.titleNode)
        self.containerNode.addSubnode(self.infoButtonNode)
        // self不能在初始化之前直接使用
        self.infoButtonNode.addTarget(self, action: #selector(self.infoPressed), forControlEvents: .touchUpInside)
       
    }
    
    @objc func infoPressed() {
        print("infoPressed")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.infoButtonNode.slopFrame.contains(point) {
            return self.infoButtonNode.view
        } else {
            return super.hitTest(point, with: event)
        }
    }
    
    // MARK: 刷新数据及计算frame
    func asyncLayout() -> (_ item: MySwipeDeleteItem, _ params: ListViewItemLayoutParams, _ first: Bool, _ last: Bool) -> (ListViewItemNodeLayout, (Bool) -> (Signal<Void, NoError>?, (Bool) -> Void)) {
        
        // 布局需要的layout
        let makeTitleLayout = self.titleNode.makeLayout
        
        
       
        return { [weak self] item, params, first, last in
            
            let leftInset: CGFloat = 20.0 + params.leftInset
           
            // title: 设置内容，并计算出展示内容
            let titleAttributedString = NSAttributedString(string: item.data.title, font: UIFont.systemFont(ofSize: 12), textColor: .black)
            // title的最大宽度 = 总宽度 - left(包含头像的宽度) - 与date的间距 - date.width - 10
            let (titleLayout, titleApply) = makeTitleLayout(TextNodeLayoutArguments(attrStr: titleAttributedString, maxWidth: params.width - leftInset - 10.0))
         
            // 计算出最终Cell的布局
            let verticalInset: CGFloat = 10
            let nodeLayout = ListViewItemNodeLayout(width: params.width, height: titleLayout.height + verticalInset * 2.0)
            
            
            return (nodeLayout, { [weak self] synchronousLoads in
                guard let self = self else {
                    return (nil, { _ in })
                }
                return (nil, { [weak self] animated in
                    guard let self = self else {
                        return
                    }
                    let transition: ContainedViewLayoutTransition = .immediate
                    
                    // 背景
                    self.backgroundNode.insertIfNeed(superNode: self, at: 0)
                    // 容器
                    self.containerNode.frame = CGRect(origin: CGPoint(), size: self.backgroundNode.frame.size)
                    
                    // 背景的frame
                    self.backgroundNode.frame = CGRect(x: 0.0, y: -UIScreenPixel, width: params.width, height: nodeLayout.height + UIScreenPixel*2)
                    
                    // 高亮背景
                    self.highlightedBackgroundNode.frame = CGRect(origin: CGPoint(x: 0.0, y: -nodeLayout.insets.top - 0), size: CGSize(width: nodeLayout.size.width, height: nodeLayout.size.height + 0))

                    
                    transition.updateFrameAdditive(node: self.bottomStripeNode, frame: CGRect(x: leftInset, y: nodeLayout.height - UIScreenPixel, width: params.width - leftInset - 10, height: UIScreenPixel))
                    
                    // Info按钮
                    let infoIconRightInset: CGFloat = 10
                    if let infoIcon = UIImage(named: "InfoIcon") {
                        self.infoButtonNode.setImage(infoIcon, for: [])
                        transition.updateFrameAdditive(node: self.infoButtonNode, frame: CGRect(x: params.width - infoIconRightInset - infoIcon.size.width, y: nodeLayout.height=>infoIcon.size.height, size: infoIcon.size))
                    }
                   
                    
                    // 设置title内容及frame
                    let _ = titleApply()
                    let titleFrame = CGRect(x: leftInset, y: verticalInset, size: titleLayout.size)
                    transition.updateFrameAdditive(node: self.titleNode, frame: titleFrame)
                })
                
            })
        }
    }
    
    
    
    // MARK: 高亮点击
    override func setHighlighted(_ highlighted: Bool, at point: CGPoint, animated: Bool) {
        super.setHighlighted(highlighted, at: point, animated: animated)
        
        if highlighted {
            // 点击高亮时
            self.highlightedBackgroundNode.alpha = 1.0
            if self.highlightedBackgroundNode.supernode == nil {
                if self.backgroundNode.supernode != nil {
                    // 如果高亮背景没有加载，普通背景加载了，则高亮背景插入普通背景之上
                    self.insertSubnode(self.highlightedBackgroundNode, aboveSubnode: self.backgroundNode)
                } else {
                    // 如果没有普通背景，直接插入到最底层
                    self.insertSubnode(self.highlightedBackgroundNode, at: 0)
                }
            }
        } else {
            // 非高亮时
            if self.highlightedBackgroundNode.supernode != nil {
                // 如果高亮背景已经存在
                if animated {
                    // 使用动画的方式移除高亮背景
                    self.highlightedBackgroundNode.layer.animateAlpha(from: self.highlightedBackgroundNode.alpha, to: 0.0, duration: 0.4, completion: { [weak self] completed in
                        if let strongSelf = self {
                            if completed {
                                strongSelf.highlightedBackgroundNode.removeFromSupernode()
                            }
                        }
                    })
                    self.highlightedBackgroundNode.alpha = 0.0
                } else {
                    // 使用普通的方式移除高亮背景
                    self.highlightedBackgroundNode.removeFromSupernode()
                }
            }
        }
    }
}

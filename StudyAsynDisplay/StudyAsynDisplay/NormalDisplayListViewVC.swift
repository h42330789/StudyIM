//
//  NormalDisplayListViewVC.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 2/13/24.
//

import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import MergeLists
import Kingfisher

extension CGRect {
    func changeOffset(dx: CGFloat = 0, dy: CGFloat = 0, dw: CGFloat = 0, dh: CGFloat) -> CGRect {
        return CGRect(x: self.origin.x + dx, y: self.origin.y + dy, width: self.size.width + dw, height: self.size.height + dh)
    }
}
class NormalDisplayListViewVC: UIViewController {
    
    lazy var listView: ListView = {
        let node = ListView()
        node.frame = self.view.bounds.changeOffset(dy: 100, dh: -100)
        node.scroller.showsVerticalScrollIndicator = true
        return node
    }()
    
    lazy var dataList: [NormalDataModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubnode(listView)
        // 将 数据 -> UIModel -> InsertItem
        let newList = Array(0...9999).map{ NormalDataModel(avator: "https://h42330789.github.io/assets/img/lonelyflow.jpg", title: "title\($0)", status: "status\($0)", date: "date\($0)") }
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
        var maxAnimatedInsertionIndex = -1
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
            
            let uiModel = NormalUIModel(data: dataModel)
            let insertItem = ListViewInsertItem(index: adjustedIndex, previousIndex: adjustedPrevousIndex, item: uiModel, directionHint: directionHint)
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
        let updateSizeAndInsets = ListViewUpdateSizeAndInsets(size: listView.frame.size, insets: UIEdgeInsets.zero, duration: 0, curve: .Default(duration: nil))
        // option
        var options: ListViewDeleteAndInsertOptions = []
        let _ = options.insert(.LowLatency)
//        let _ = options.insert(.Synchronous)
        let _ = options.insert(.PreferSynchronousResourceLoading)
        
        // 需要更新的内容
        listView.transaction(deleteIndices: deleteList, insertIndicesAndItems: insertList, updateIndicesAndItems: [], options: options, scrollToItem: nil, updateSizeAndInsets: updateSizeAndInsets, stationaryItemRange: nil, updateOpaqueState: nil, completion: { _ in })
        self.dataList = newList
    }
}

class NormalDataModel {
    
    var avator: String = ""
    var title: String = ""
    var status: String = ""
    var date: String = ""
    
    init(avator: String, title: String, status: String, date: String) {
        self.avator = avator
        self.title = title
        self.status = status
        self.date = date
    }
    
}
extension NormalDataModel: Comparable, Identifiable {
    
    // Identifiable 用于确定唯一性
    var stableId: String {
        return self.date
    }
    // Comparable 用于比较
    static func <(lhs: NormalDataModel, rhs: NormalDataModel) -> Bool {
        return lhs.date < rhs.date
    }
    
    static func ==(lhs: NormalDataModel, rhs: NormalDataModel) -> Bool {
        return lhs.date == rhs.date
            
    }
}

class NormalUIModel: ListViewItem {
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
            let node = NormalItemNode()
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
//            if let nodeValue = node() as? NormalItemNode {
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
    // MARK: - 点击时的回掉
    func selected(listView: ListView) {
        // 设置不展示高亮
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            listView.clearHighlightAnimated(true)
        })
        
        print("\(self.data.title)")
    }
}

class NormalItemNode: ListViewItemNode {
    // 背景
    private let backgroundNode: ASDisplayNode
    // 高亮时的背景
    private let highlightedBackgroundNode: ASDisplayNode
    // 底部分隔线
    private let bottomStripeNode: ASDisplayNode
    // 容器
    private let containerNode: ASDisplayNode
    
    // 头像
    private let avatarNode: ImageNode
    private let titleNode: TextNode
    private let statusNode: TextNode
    private let dateNode: TextNode
    
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
        self.bottomStripeNode = ASDisplayNode()
        self.bottomStripeNode.backgroundColor = .lightGray
        self.bottomStripeNode.isLayerBacked = true
        
        // 头像
        self.avatarNode = ImageNode()
        self.avatarNode.backgroundColor = .lightGray
        self.avatarNode.cornerRadius = 20
        self.avatarNode.clipsToBounds = true
        
        self.titleNode = TextNode()
        self.statusNode = TextNode()
        self.dateNode = TextNode()
        
        super.init(layerBacked: false, dynamicBounce: false, rotated: false, seeThrough: false)
        // 添加显示内容
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.containerNode)
        // 将内容添加到容器里
        self.containerNode.addSubnode(self.avatarNode)
        self.containerNode.addSubnode(self.titleNode)
        self.containerNode.addSubnode(self.statusNode)
        self.containerNode.addSubnode(self.dateNode)
       
    }
    
    // MARK: 刷新数据及计算frame
    func asyncLayout() -> (_ item: NormalUIModel, _ params: ListViewItemLayoutParams, _ first: Bool, _ last: Bool) -> (ListViewItemNodeLayout, (Bool) -> (Signal<Void, NoError>?, (Bool) -> Void)) {
        let makeTitleLayout = TextNode.asyncLayout(self.titleNode)
        let makeStatusLayout = TextNode.asyncLayout(self.statusNode)
        let makeDateLayout = TextNode.asyncLayout(self.dateNode)
        
       
        return { [weak self] item, params, first, last in
            let avatarDiameter: CGFloat = 40.0
            let leftInset: CGFloat = 20.0 + avatarDiameter + params.leftInset
            let rightInset: CGFloat = 13.0 + params.rightInset
            
            
            
            
            // date: 设置内容，并计算出展示内容
            let dateAttributedString = NSAttributedString(string: item.data.date, attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.gray,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
            // date的最大宽度：总宽度 - left(包含头像的宽度) - right
            let (dateLayout, dateApply) = makeDateLayout(TextNodeLayoutArguments(attributedString: dateAttributedString, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: max(0.0, max(0.0, params.width - leftInset - rightInset)), height: CGFloat.infinity), alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
            
            // date与前面之间的距离
            let dateRightInset: CGFloat = 46.0 + params.rightInset
            
            // title: 设置内容，并计算出展示内容
            let titleAttributedString = NSAttributedString(string: item.data.title, attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
            // title的最大宽度 = 总宽度 - left(包含头像的宽度) - 与date的间距 - date.width - 10
            let (titleLayout, titleApply) = makeTitleLayout(TextNodeLayoutArguments(attributedString: titleAttributedString, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: max(0.0, params.width - leftInset - dateRightInset - dateLayout.size.width - 10.0), height: CGFloat.infinity), alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
            
            // status: 设置内容，并计算出展示内容
            let statusAttributedString = NSAttributedString(string: item.data.status, attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.gray,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
            
            // status的最大宽度：总宽度 - left(包含头像的宽度) - 与date的间距 - date.width - 10
            let (statusLayout, statusApply) = makeStatusLayout(TextNodeLayoutArguments(attributedString: statusAttributedString, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: max(0.0, params.width - leftInset - dateRightInset - dateLayout.size.width - 10.0), height: CGFloat.infinity), alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
            
            
            // 计算出全部内容
            let titleSpacing: CGFloat = -1.0
            let verticalInset: CGFloat = 10.0
            // 整个cell的高度 = title距离顶部的距离 + title.height + title与status的间距 + status.height + status距离底部的间距
            let nodeLayout = ListViewItemNodeLayout(contentSize: CGSize(width: params.width, height: titleLayout.size.height + titleSpacing + statusLayout.size.height + verticalInset * 2.0), insets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0))
            
            
//            let contentSize = nodeLayout.contentSize
            let revealOffset: CGFloat = 0
            let separatorHeight = UIScreenPixel
            return (nodeLayout, { [weak self] synchronousLoads in
                if let strongSelf = self {
                    return (nil, { [weak strongSelf] animated in
                        if let strongSelf = strongSelf {
                            let transition: ContainedViewLayoutTransition = .immediate
                            
                            // 背景
                            if strongSelf.backgroundNode.supernode == nil {
                                strongSelf.insertSubnode(strongSelf.backgroundNode, at: 0)
                            }
                            // 容器
                            strongSelf.containerNode.frame = CGRect(origin: CGPoint(), size: strongSelf.backgroundNode.frame.size)
                            
                            // 背景的frame
                            strongSelf.backgroundNode.frame = CGRect(origin: CGPoint(x: 0.0, y: -min(0, separatorHeight)), size: CGSize(width: params.width, height: nodeLayout.contentSize.height + min(0, separatorHeight) + min(0, separatorHeight)))
                            
                            // 高亮背景
                            strongSelf.highlightedBackgroundNode.frame = CGRect(origin: CGPoint(x: 0.0, y: -nodeLayout.insets.top - 0), size: CGSize(width: nodeLayout.size.width, height: nodeLayout.size.height + 0))
                            // 自己本身
//                            strongSelf.updateLayout(size: nodeLayout.contentSize, leftInset: params.leftInset, rightInset: params.rightInset)

                            // 底部的分隔线
                            if !last && strongSelf.bottomStripeNode.supernode == nil {
                                // 不是最后一行，且线没有加入，则加入
                                strongSelf.insertSubnode(strongSelf.bottomStripeNode, at: 1)
                            } else if last && strongSelf.bottomStripeNode.supernode != nil {
                                // 是最后一行，且底部的线存在，移除
                                strongSelf.bottomStripeNode.removeFromSupernode()
                            }
                            transition.updateFrameAdditive(node: strongSelf.bottomStripeNode, frame: CGRect(origin: CGPoint(x: leftInset, y: nodeLayout.contentSize.height - separatorHeight), size: CGSize(width: params.width - leftInset, height: separatorHeight)))
                            
                            // 头像 x: title.left - 间距10 - avatar.width
                            strongSelf.avatarNode.setSignal(strongSelf.createImageSignal(url: item.data.avator))
                            let avartorFrame = CGRect(origin: CGPoint(x: revealOffset + leftInset - avatarDiameter - 10, y: floor((nodeLayout.contentSize.height - avatarDiameter) / 2.0)), size: CGSize(width: avatarDiameter, height: avatarDiameter))
                            transition.updateFrameAdditive(node: strongSelf.avatarNode, frame: avartorFrame)
                            
                            // 设置title内容及frame
                            let _ = titleApply()
                            let titleFrame = CGRect(origin: CGPoint(x: revealOffset + leftInset, y: verticalInset), size: titleLayout.size)
                            transition.updateFrameAdditive(node: strongSelf.titleNode, frame: titleFrame)
                            
                            // 设置status的内容及frame
                            let _ = statusApply()
                            transition.updateFrameAdditive(node: strongSelf.statusNode, frame: CGRect(origin: CGPoint(x: revealOffset + leftInset, y: strongSelf.titleNode.frame.maxY + titleSpacing), size: statusLayout.size))
                            
                            // 设置date的内容及frame
                            let _ = dateApply()
                            transition.updateFrameAdditive(node: strongSelf.dateNode, frame: CGRect(origin: CGPoint(x: revealOffset + params.width - dateRightInset - dateLayout.size.width, y: floor((nodeLayout.contentSize.height - dateLayout.size.height) / 2.0) + 2.0), size: dateLayout.size))
                        }
                    })
                } else {
                    return (nil, { _ in })
                }
            })
        }
    }
    
    func createImageSignal(url: String) -> Signal<UIImage?, NoError> {
        return Signal { subscriber in
            let disposable = MetaDisposable()
            DispatchQueue.global().async {
                if let imageURL = URL(string: url) {
                    KingfisherManager.shared.retrieveImage(with: KF.ImageResource(downloadURL: imageURL), completionHandler: { result in
                        switch result {
                        case .success(let value):
                            subscriber.putNext(value.image)
                            subscriber.putCompletion()
                        case .failure(_):
                            subscriber.putCompletion()
                          }
                        
                    })
                } else {
                    subscriber.putCompletion()
                }
            }
            return disposable
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

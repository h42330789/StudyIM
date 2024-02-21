//
//  MyChatFolderVC.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 2/18/24.
//

import Foundation
import ItemListUI
import TelegramPresentationData
import SwiftSignalKit
import Display
import AsyncDisplayKit
import AnimatedStickerNode
import TelegramAnimatedStickerNode

private final class MyChatFolderArguments {
    var addNew: CommnoEmptyAction? = nil
}
public func defaultItemTheme() -> ItemListPresentationData {
    // 上下文主题信息
    let theme = defaultPresentationTheme
    let corners = PresentationChatBubbleCorners(mainRadius: 0, auxiliaryRadius: 0, mergeBubbleCorners: false)
    let dateFormat = PresentationDateTimeFormat.init(timeFormat: .regular, dateFormat: .dayFirst, dateSeparator: "", dateSuffix: "", requiresFullYear: false, decimalSeparator: "", groupingSeparator: "")
    let presentationData = PresentationData(strings: defaultPresentationStrings, theme: theme, autoNightModeTriggered: false, chatWallpaper: theme.chat.defaultWallpaper, chatFontSize: .regular, chatBubbleCorners: corners, listsFontSize: .regular, dateTimeFormat: dateFormat, nameDisplayOrder: .firstLast, nameSortOrder: .firstLast, reduceMotion: false, largeEmoji: false)
    return ItemListPresentationData(presentationData)
}
class MyChatFolderVC: ItemListController {
    
    static func create() -> MyChatFolderVC {
        
        // 上下文主题信息
//        let theme = defaultPresentationTheme
//        let corners = PresentationChatBubbleCorners(mainRadius: 0, auxiliaryRadius: 0, mergeBubbleCorners: false)
//        let dateFormat = PresentationDateTimeFormat.init(timeFormat: .regular, dateFormat: .dayFirst, dateSeparator: "", dateSuffix: "", requiresFullYear: false, decimalSeparator: "", groupingSeparator: "")
//        let presentationData = PresentationData(strings: defaultPresentationStrings, theme: theme, autoNightModeTriggered: false, chatWallpaper: theme.chat.defaultWallpaper, chatFontSize: .regular, chatBubbleCorners: corners, listsFontSize: .regular, dateTimeFormat: dateFormat, nameDisplayOrder: .firstLast, nameSortOrder: .firstLast, reduceMotion: false, largeEmoji: false)
        
        // 主题更新信息
        let updateDateSignal: Signal<ItemListPresentationData, NoError> = Signal { subscriber in
            let disposable = MetaDisposable()
            return disposable
        }
        
        // 交互回调
        let arguments = MyChatFolderArguments()
        arguments.addNew = {
                print("addNew")
        }

        // 数据配置信号
        let statePromise = ValuePromise("test", ignoreRepeated: true)
        let statePromise2 = ValuePromise("aaa", ignoreRepeated: true)
        let stateSignal2 = combineLatest(queue: .mainQueue(), statePromise.get(),statePromise2.get())
        |> map { state, state2 -> (ItemListControllerState, (ItemListNodeState, MyChatFolderArguments)) in
            // controller配置
            let controllerState = ItemListControllerState(presentationData: defaultItemTheme(), title: .text("MyTitle"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: "MyBack"), animateChanges: false)
            // 数据配置
            let enties = MyChatFolderVC.createEnties()
            let listState = ItemListNodeState(presentationData: defaultItemTheme(), entries: enties, style: .blocks, animateChanges: true)
            
            return (controllerState, (listState, arguments))
        }
        |> afterDisposed {
        }
        
        // 主题+主题变更+数据
        let vc = MyChatFolderVC(presentationData: defaultItemTheme(), updatedPresentationData: updateDateSignal, state: stateSignal2, tabBarItem: nil)
        
        // 由于没有在Display上下文里管理，需要手动设置layout
        let boundsSize = UIScreen.main.bounds.size
        let metrics: LayoutMetrics
        if boundsSize.width > 690.0 && boundsSize.height > 650.0 {
            metrics = LayoutMetrics(widthClass: .regular, heightClass: .regular)
        } else {
            metrics = LayoutMetrics(widthClass: .compact, heightClass: .compact)
        }
        let deviceMetrics = DeviceMetrics(screenSize: UIScreen.main.bounds.size, scale: UIScreen.main.scale, statusBarHeight: 54, onScreenNavigationHeight: 88)
        let layout = ContainerViewLayout(size: boundsSize, metrics: metrics, deviceMetrics: deviceMetrics, intrinsicInsets: .init(top: 0, left: 0, bottom: 34, right: 0), safeInsets: .init(top: 44, left: 0, bottom: 0, right: 0), additionalInsets: .zero, statusBarHeight: 54, inputHeight: nil, inputHeightIsInteractivellyChanging: false, inVoiceOver: false)
        // 这里会触发计算页面展示的宽高
        // 真实宽度>375,两边的间距 =  max(16, (width - 674)/2)
//        let inset = max(16.0, floor((layout.size.width - 674.0) / 2.0))
//        if layout.size.width >= 375.0 {
//            insets.left += inset
//            insets.right += inset
//        }
        vc.containerLayoutUpdated(layout, transition: .immediate)
        
        return vc
    }
    
    // MARK: - 创建数据 
    // Data -> UIDataModel -> UIModel -> Node
    // hello -> MyCreateFolderListEntry -> MyChatFolderSettingsHeaderItem -> MyChatFolderSettingsHeaderNode
    static func createEnties() -> [MyCreateFolderListEntry] {
        return [
            .screenHeader("Create folders for different groups of chats and quickly switch between them."),
            .listHeader("FOLDERS"),
            .addItem(text: "Create a Folder"),
            .listItem(index: 0, title: "All Chats", isAllChats: true, originData: ""),
            .listItem(index: 1, title: "Fd1", isAllChats: false, originData: "aaa"),
            .listFooter("Tap 'Edit' to change the order or delete folders.")
        ]
    }
}

// MARK: - UIDataModel
enum MyCreateFolderListEntry: ItemListNodeEntry {
    case screenHeader(String)   // 动画+标题
    case listHeader(String) // 列表标题
    case addItem(text: String) // 添加
    case listItem(index: Int, title: String, isAllChats: Bool, originData: String) // 条目, originData要遵循Codable, Equatable
    case listFooter(String) // 列表底部内容
    
    // 分组section排序
    var section: ItemListSectionId {
        switch self {
        case .screenHeader:
            return 0
        case .listHeader, .addItem, .listItem, .listFooter:
            return 1
        }
    }
    // 排序id
    var sortId: Int {
        switch self {
        case .screenHeader:
            return 0
        case .listHeader:
            return 100
        case .addItem:
            return 101
        case let .listItem(index, _, _, _):
            return 102 + index
        case .listFooter:
            return 1001
        }
    }
    enum MyChatFolderEntryStableId: Hashable {
        case screenHeader
        case listHeader
        case addItem
        case listItem(String)
        case listFooter
    }
    // 固定id
    var stableId: MyChatFolderEntryStableId {
        switch self {
        case .screenHeader:
            return .screenHeader
        case .listHeader:
            return .listHeader
        case .addItem:
            return .addItem
        case let .listItem(_, _,_, originData):
            return .listItem(originData)
        case .listFooter:
            return .listFooter
        }
    }
    // 排序
    static func <(lhs: MyCreateFolderListEntry, rhs: MyCreateFolderListEntry) -> Bool {
        return lhs.sortId < rhs.sortId
    }
    // 将数据转换为List里的Item
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {

        switch self {
        case let .screenHeader(text):
            return MyChatFolderScreenHeaderItem(text: text, sectionId: self.section)
        case let .listHeader(text):
            return MyChatFolderListHeaderItem(text: text, sectionId: self.section)
        case let .addItem(text):
            return MyChatFolderListAddItem(text: text, sectionId: self.section) {
                if let arguments = arguments as? MyChatFolderArguments {
                    arguments.addNew?()
                }
            }
        case let .listItem(_, title, isAllChats, originData):
            return MyChatFolderListItem(text: title, sectionId: self.section, isAllChats: isAllChats) {
                print(originData)
            }
        case let .listFooter(text):
            return MyChatFolderListHeaderItem(text: text, sectionId: self.section)
        }
    }
}
// MARK: - UIModel + ScreenHeader
class MyChatFolderScreenHeaderItem: ListViewItem, ItemListItem {
    let text: String
    // sectionId是实现ItemListItem的必须的内容
    public let sectionId: ItemListSectionId
    public init(text: String, sectionId: ItemListSectionId) {
        self.text = text
        self.sectionId = sectionId
    }
    // MARK: ListViewItem
    public func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        async {
            let node = MyChatFolderScreenHeaderNode()
            let (layout, apply) = node.asyncLayout()(self, params, itemListNeighbors(item: self, topItem: previousItem as? ItemListItem, bottomItem: nextItem as? ItemListItem))
            
            node.contentSize = layout.contentSize
            node.insets = layout.insets
            
            Queue.mainQueue().async {
                completion(node, {
                    return (nil, { _ in apply() })
                })
            }
        }
    }
    
    public func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: @escaping () -> ListViewItemNode, params: ListViewItemLayoutParams, previousItem: ListViewItem?, nextItem: ListViewItem?, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping (ListViewItemApply) -> Void) -> Void) {
        Queue.mainQueue().async {
            guard let nodeValue = node() as? MyChatFolderScreenHeaderNode else {
                assertionFailure()
                return
            }
            
            let makeLayout = nodeValue.asyncLayout()
            
            async {
                let (layout, apply) = makeLayout(self, params, itemListNeighbors(item: self, topItem: previousItem as? ItemListItem, bottomItem: nextItem as? ItemListItem))
                Queue.mainQueue().async {
                    completion(layout, { _ in
                        apply()
                    })
                }
            }
        }
    }
}
// MARK: Node Cell
class MyChatFolderScreenHeaderNode: ListViewItemNode {
    private let titleNode: TextNode
    private var animationNode: AnimatedStickerNode
    
    private var item: MyChatFolderScreenHeaderItem?
    
    init() {
        self.titleNode = TextNode()
        self.titleNode.isUserInteractionEnabled = false
        self.titleNode.contentMode = .left
        self.titleNode.contentsScale = UIScreen.main.scale
        
        self.animationNode = DefaultAnimatedStickerNodeImpl()
        
        super.init(layerBacked: false, dynamicBounce: false)
        
        self.addSubnode(self.titleNode)
        self.addSubnode(self.animationNode)
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.animationNode.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.animationTapGesture(_:))))
    }
    
    @objc private func animationTapGesture(_ recognizer: UITapGestureRecognizer) {
        if case .ended = recognizer.state {
            if !self.animationNode.isPlaying {
                self.animationNode.play(firstFrame: false, fromIndex: nil)
            }
        }
    }
    
    func asyncLayout() -> (_ item: MyChatFolderScreenHeaderItem, _ params: ListViewItemLayoutParams, _ neighbors: ItemListNeighbors) -> (ListViewItemNodeLayout, () -> Void) {
        let makeTitleLayout = TextNode.asyncLayout(self.titleNode)
        
        return { item, params, neighbors in
            let isHidden = params.width > params.availableHeight && params.availableHeight < 400.0
            
            let leftInset: CGFloat = 32.0 + params.leftInset
            
            
            let size = 192
            let insetDifference = 100
            let additionalBottomInset: CGFloat = 0.0
            let playbackMode: AnimatedStickerPlaybackMode = .once
            let animationName: String = "ChatListFolders"
            
            
            let topInset: CGFloat = CGFloat(size - insetDifference)
            
            let attributedText = NSAttributedString(string: item.text, font: Font.regular(13.0), textColor: .lightGray)
            let (titleLayout, titleApply) = makeTitleLayout(TextNodeLayoutArguments(attributedString: attributedText, backgroundColor: nil, maximumNumberOfLines: 0, truncationType: .end, constrainedSize: CGSize(width: params.width - params.rightInset - leftInset * 2.0, height: CGFloat.greatestFiniteMagnitude), alignment: .center, cutout: nil, insets: UIEdgeInsets()))
            
            let contentSize = CGSize(width: params.width, height: topInset + titleLayout.size.height)
            var insets = itemListNeighborsGroupedInsets(neighbors, params)
            
            if isHidden {
                insets = UIEdgeInsets()
            }
            insets.bottom += additionalBottomInset
            
            let layout = ListViewItemNodeLayout(contentSize: isHidden ? CGSize(width: params.width, height: 0.0) : contentSize, insets: insets)
            
            return (layout, { [weak self] in
                if let strongSelf = self {
                    if strongSelf.item == nil {
                        strongSelf.animationNode.setup(source: AnimatedStickerNodeLocalFileSource(name: animationName), width: size, height: size, playbackMode: playbackMode, mode: .direct(cachePathPrefix: nil))
                        strongSelf.animationNode.visibility = true
                    }
                    
                    strongSelf.item = item
                    strongSelf.accessibilityLabel = attributedText.string
                                        
                    let iconSize = CGSize(width: CGFloat(size) / 2.0, height: CGFloat(size) / 2.0)
                    strongSelf.animationNode.frame = CGRect(origin: CGPoint(x: floor((layout.size.width - iconSize.width) / 2.0), y: -10.0), size: iconSize)
                    strongSelf.animationNode.updateLayout(size: iconSize)
                    
                    let _ = titleApply()
                    strongSelf.titleNode.frame = CGRect(origin: CGPoint(x: floor((layout.size.width - titleLayout.size.width) / 2.0), y: topInset + 8.0), size: titleLayout.size)
                    
                    strongSelf.animationNode.alpha = isHidden ? 0.0 : 1.0
                    strongSelf.titleNode.alpha = isHidden ? 0.0 : 1.0
                }
            })
        }
    }
    
    override func animateInsertion(_ currentTimestamp: Double, duration: Double, short: Bool) {
        self.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.4)
    }
    
    override func animateRemoved(_ currentTimestamp: Double, duration: Double) {
        self.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.15, removeOnCompletion: false)
    }
}
// MARK: - UIModel + ListHeader
class MyChatFolderListHeaderItem: ListViewItem, ItemListItem {
    let text: String
    // sectionId是实现ItemListItem的必须的内容
    public let sectionId: ItemListSectionId
    public let isAlwaysPlain: Bool = true // 不作为列表的Item栏目，相当于tabled的section，不当成indexPath.row
    public init(text: String, sectionId: ItemListSectionId) {
        self.text = text
        self.sectionId = sectionId
    }
    // MARK: ListViewItem
    public func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        async {
            let node = MyChatFolderListHeaderNode()
            let (layout, apply) = node.asyncLayout()(self, params, itemListNeighbors(item: self, topItem: previousItem as? ItemListItem, bottomItem: nextItem as? ItemListItem))
            
            node.contentSize = layout.contentSize
            node.insets = layout.insets
            
            Queue.mainQueue().async {
                completion(node, {
                    return (nil, { _ in apply() })
                })
            }
        }
    }
    
    public func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: @escaping () -> ListViewItemNode, params: ListViewItemLayoutParams, previousItem: ListViewItem?, nextItem: ListViewItem?, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping (ListViewItemApply) -> Void) -> Void) {
        Queue.mainQueue().async {
            guard let nodeValue = node() as? MyChatFolderListHeaderNode else {
                assertionFailure()
                return
            }
            
            let makeLayout = nodeValue.asyncLayout()
            
            async {
                let (layout, apply) = makeLayout(self, params, itemListNeighbors(item: self, topItem: previousItem as? ItemListItem, bottomItem: nextItem as? ItemListItem))
                Queue.mainQueue().async {
                    completion(layout, { _ in
                        apply()
                    })
                }
            }
        }
    }
}
// MARK: Node Cell
class MyChatFolderListHeaderNode: ListViewItemNode {
    private var item: MyChatFolderListHeaderItem?
    private let titleNode: TextNode
    private var actionNode: TextNode?
    private var actionButtonNode: HighlightableButtonNode?
    
    public init() {
        self.titleNode = TextNode()
        self.titleNode.isUserInteractionEnabled = false
        
        super.init(layerBacked: false, dynamicBounce: false)
        self.addSubnode(titleNode)
    }
    
    public func asyncLayout() -> (_ item: MyChatFolderListHeaderItem, _ params: ListViewItemLayoutParams, _ neighbors: ItemListNeighbors) -> (ListViewItemNodeLayout, () -> Void) {
        let makeTitleLayout = TextNode.asyncLayout(self.titleNode)
        
        return {item, params, neighbors in
            
            // 计算layout
            let leftInset: CGFloat = 15 + params.leftInset
            let titleFont = Font.regular(14)
            let titleAttribute = NSAttributedString(string: item.text, font: titleFont, textColor: .gray)
            let (titleLayout, titleApply) = makeTitleLayout(TextNodeLayoutArguments(attributedString: titleAttribute, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: params.width - params.leftInset - params.rightInset, height: CGFloat.greatestFiniteMagnitude), alignment: .natural, cutout: nil, insets: .zero))
            
            let contentSize = CGSize(width: params.width, height: titleLayout.size.height + 13.0)
            var insets = UIEdgeInsets()
            // 如果前面还有其他内容，会添加空白内容
            switch neighbors.top {
                case .none:
                    insets.top += 24.0
                case .otherSection:
                    insets.top += 28.0
                default:
                    break
            }
            
            let layout = ListViewItemNodeLayout(contentSize: contentSize, insets: insets)
            
            // 返回layout
            return (layout, {[weak self] in
                guard let self = self else {
                    return
                }
                
                // 赋值
                self.item = item
                let _ = titleApply()
                
                self.titleNode.frame = CGRect(origin: CGPoint(x: leftInset, y: 7), size: titleLayout.size)
            })
        }
    }
}


// MARK: - UIModel + AddLtem
class MyChatFolderListAddItem: ListViewItem, ItemListItem {
    let text: String
    // sectionId是实现ItemListItem的必须的内容
    public let sectionId: ItemListSectionId
    var action: CommnoEmptyAction?
    
    public init(text: String, sectionId: ItemListSectionId, action: CommnoEmptyAction? = nil) {
        self.text = text
        self.sectionId = sectionId
        self.action = action
    }
    
    // MARK: 点击
    // 是否可以选择
    public var selectable: Bool {
        // 有回调时可以选择
        return self.action != nil
    }
    // 点击回调
    public func selected(listView: ListView) {
        listView.clearHighlightAnimated(true)
        self.action?()
    }
    
    
    // MARK: ListViewItem
    public func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        async {
            let node = MyChatFolderListAddNode()
            let neighbors = itemListNeighbors(item: self, topItem: previousItem as? ItemListItem, bottomItem: nextItem as? ItemListItem)
            let (layout, apply) = node.asyncLayout()(self, params, neighbors)
            
            node.contentSize = layout.contentSize
            node.insets = layout.insets
            
            Queue.mainQueue().async {
                completion(node, {
                    return (nil, { _ in apply(false) })
                })
            }
        }
    }
    
    public func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: @escaping () -> ListViewItemNode, params: ListViewItemLayoutParams, previousItem: ListViewItem?, nextItem: ListViewItem?, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping (ListViewItemApply) -> Void) -> Void) {
        Queue.mainQueue().async {
            guard let nodeValue = node() as? MyChatFolderListAddNode else {
                assertionFailure()
                return
            }
            
            let makeLayout = nodeValue.asyncLayout()
            
            var animated = true
            if case .None = animation {
                animated = false
            }
            
            async {
                let (layout, apply) = makeLayout(self, params, itemListNeighbors(item: self, topItem: previousItem as? ItemListItem, bottomItem: nextItem as? ItemListItem))
                Queue.mainQueue().async {
                    completion(layout, { _ in
                        apply(animated)
                    })
                }
            }
        }
    }
}
// MARK: Node Cell

class MyChatFolderListAddNode: ListViewItemNode {
    private var item: MyChatFolderListAddItem?
    
    private let backgroundNode: ASDisplayNode // 背景
    private let highlightedBackgroundNode: ASDisplayNode // 点击高亮时的背景
    private let topStripeNode: ASDisplayNode // 顶部分隔线
    
    private let maskNode: ASImageNode //
    
    private let titleNode: TextNode
    
    
    public init() {
        
        self.backgroundNode = ASDisplayNode(isLayerBacked: true, backgroundColor: .white)
        self.highlightedBackgroundNode = ASDisplayNode(isLayerBacked: true, backgroundColor: UIColor(red: 232.0/255, green: 232.0/255, blue: 231.0/255, alpha: 1))
        
        self.topStripeNode = ASDisplayNode(isLayerBacked: true, backgroundColor: .gray)
        
        self.maskNode = ASImageNode()
        
        self.titleNode = TextNode()
        self.titleNode.isUserInteractionEnabled = false
        
        super.init(layerBacked: false, dynamicBounce: false)
        self.addSubnode(titleNode)
    }
    
    public func asyncLayout() -> (_ item: MyChatFolderListAddItem, _ params: ListViewItemLayoutParams, _ neighbors: ItemListNeighbors) -> (ListViewItemNodeLayout, (Bool) -> Void) {
        let makeTitleLayout = TextNode.asyncLayout(self.titleNode)
        
        return {item, params, neighbors in
            
            // 计算layout
            let titleFont = Font.regular(14)
            // 上下的间距
            let verticalInset = 11.0
            // 文本距离左侧的距离
            let leftInset = 16.0 + params.leftInset
            
            
            let titleAttribute = NSAttributedString(string: item.text, font: titleFont, textColor: .blue)
            let (titleLayout, titleApply) = makeTitleLayout(TextNodeLayoutArguments(attributedString: titleAttribute, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: params.width - params.leftInset - params.rightInset, height: CGFloat.greatestFiniteMagnitude), alignment: .natural, cutout: nil, insets: .zero))
            
            let separatorHeight = UIScreenPixel
            
            let insets = itemListNeighborsGroupedInsets(neighbors, params)
            let contentSize = CGSize(width: params.width, height: titleLayout.size.height + verticalInset * 2)
            
            let layout = ListViewItemNodeLayout(contentSize: contentSize, insets: insets)
            
            // 返回layout
            return (layout, { [weak self] animated in
                guard let self = self else {
                    return
                }
                
                // 赋值
                self.item = item
                let _ = titleApply()
                // 动画方式
                let transition: ContainedViewLayoutTransition
                if animated {
                    transition = ContainedViewLayoutTransition.animated(duration: 0.4, curve: .spring)
                } else {
                    transition = .immediate
                }
                // 背景
                self.backgroundNode.insertIfNeed(superNode: self, at: 0)
                self.topStripeNode.insertIfNeed(superNode: self, at: 1)
                self.maskNode.insertIfNeed(superNode: self, at: 2)
                
                let hasCorners = itemListHasRoundedBlockLayout(params)
                var hasTopCorners = false
                var hasBottomCorners = false
                switch neighbors.top {
                    case .sameSection(false):
                        // 当前组的非第一条，相当于indexPath.row > 0
                        self.topStripeNode.isHidden = false
                        hasTopCorners = false
                    default:
                        // 当前组组效果的第一条 ，相当于indexPath.row == 0
                        self.topStripeNode.isHidden = true
                        hasTopCorners = true
                }
                switch neighbors.bottom {
                    case .sameSection(false):
                        // 同一组不是最后一条，相当于 indexPath.row < (count - 1)
                        hasBottomCorners = false
                    default:
                        // 同一组最后一条，相当于 indexPath.row == (count - 1)
                        hasBottomCorners = true
                }
                self.maskNode.image = hasCorners ? PresentationResourcesItemList.cornersImage(defaultItemTheme().theme, top: hasTopCorners, bottom: hasBottomCorners) : nil
                
                self.backgroundNode.frame = CGRect(x: 0, y: -min(insets.top, separatorHeight), width: params.width, height: layout.contentSize.height + min(insets.top, separatorHeight) + min(insets.bottom, separatorHeight))
                self.maskNode.frame = self.backgroundNode.frame.insetBy(dx: params.leftInset, dy: 0)
                self.topStripeNode.frame = CGRect(x: 0, y: -min(insets.top, separatorHeight), width: layout.contentSize.width, height: separatorHeight)
                
                transition.updateFrame(node: self.titleNode, frame: CGRect(origin: CGPoint(x: leftInset, y: verticalInset), size: titleLayout.size))
                self.highlightedBackgroundNode.frame = CGRect(x: 0, y: -UIScreenPixel, width: params.width, height: layout.contentSize.height + UIScreenPixel * 2)
                
            })
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, at point: CGPoint, animated: Bool) {
        super.setHighlighted(highlighted, at: point, animated: animated)
        
        if highlighted {
            // 高亮时的展示
            self.highlightedBackgroundNode.alpha = 1.0
            self.insertSubnode(self.highlightedBackgroundNode, aboveSubnode: self.backgroundNode)
        } else {
            if self.highlightedBackgroundNode.isInSuperNode {
                // 如果存在高亮背景
                if animated {
                    self.highlightedBackgroundNode.layer.animateAlpha(from: self.highlightedBackgroundNode.alpha, to: 0, duration: 0.4) { [weak self] completed in
                        if let self = self, completed {
                            self.highlightedBackgroundNode.removeFromSupernode()
                        }
                    }
                } else {
                    self.highlightedBackgroundNode.removeFromSupernode()
                }
            }
        }
    }
}

// MARK: - UIModel + ListLtem
class MyChatFolderListItem: ListViewItem, ItemListItem {
    let text: String
    let isAllChats: Bool
    // sectionId是实现ItemListItem的必须的内容
    public let sectionId: ItemListSectionId
    var action: CommnoEmptyAction?
    
    public init(text: String, sectionId: ItemListSectionId, isAllChats: Bool, action: CommnoEmptyAction? = nil) {
        self.text = text
        self.sectionId = sectionId
        self.isAllChats = isAllChats
        self.action = action
    }
    
    // MARK: 点击
    // 是否可以选择
    public var selectable: Bool {
        // 除了AllChats外都可以点击
        return self.isAllChats == false
    }
    // 点击回调
    public func selected(listView: ListView) {
        listView.clearHighlightAnimated(true)
        self.action?()
    }
    
    
    // MARK: ListViewItem
    public func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        async {
            let node = MyChatFolderListItemNode()
            let neighbors = itemListNeighbors(item: self, topItem: previousItem as? ItemListItem, bottomItem: nextItem as? ItemListItem)
            let (layout, apply) = node.asyncLayout()(self, params, neighbors)
            
            node.contentSize = layout.contentSize
            node.insets = layout.insets
            
            Queue.mainQueue().async {
                completion(node, {
                    return (nil, { _ in apply(false) })
                })
            }
        }
    }
    
    public func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: @escaping () -> ListViewItemNode, params: ListViewItemLayoutParams, previousItem: ListViewItem?, nextItem: ListViewItem?, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping (ListViewItemApply) -> Void) -> Void) {
        Queue.mainQueue().async {
            guard let nodeValue = node() as? MyChatFolderListItemNode else {
                assertionFailure()
                return
            }
            
            let makeLayout = nodeValue.asyncLayout()
            
            var animated = true
            if case .None = animation {
                animated = false
            }
            
            async {
                let (layout, apply) = makeLayout(self, params, itemListNeighbors(item: self, topItem: previousItem as? ItemListItem, bottomItem: nextItem as? ItemListItem))
                Queue.mainQueue().async {
                    completion(layout, { _ in
                        apply(animated)
                    })
                }
            }
        }
    }
}
// MARK: Node Cell

class MyChatFolderListItemNode: ListViewItemNode {
    private var item: MyChatFolderListItem?
    
    private let backgroundNode: ASDisplayNode // 背景
    private let highlightedBackgroundNode: ASDisplayNode // 点击高亮时的背景
    private let containerNode: ASDisplayNode // 容器
    private let topStripeNode: ASDisplayNode // 顶部分隔线
    
    private let maskNode: ASImageNode //
    
    private let titleNode: TextNode
    private let arrowNode: ASImageNode
    
    
    public init() {
        
        self.backgroundNode = ASDisplayNode(isLayerBacked: true, backgroundColor: .white)
        self.highlightedBackgroundNode = ASDisplayNode(isLayerBacked: true, backgroundColor: UIColor(red: 232.0/255, green: 232.0/255, blue: 231.0/255, alpha: 1))
        self.containerNode = ASDisplayNode()
        self.topStripeNode = ASDisplayNode(isLayerBacked: true, backgroundColor: .gray)
        
        self.maskNode = ASImageNode()
        
        self.titleNode = TextNode()
        self.titleNode.isUserInteractionEnabled = false
        
        self.arrowNode = ASImageNode()
        self.arrowNode.displayWithoutProcessing = true
        self.arrowNode.displaysAsynchronously = false
        self.arrowNode.isLayerBacked = true
        
        super.init(layerBacked: false, dynamicBounce: false)
        
        self.addSubnode(self.containerNode)
        self.containerNode.addSubnode(self.titleNode)
        self.containerNode.addSubnode(self.arrowNode)
  
    }
    
    public func asyncLayout() -> (_ item: MyChatFolderListItem, _ params: ListViewItemLayoutParams, _ neighbors: ItemListNeighbors) -> (ListViewItemNodeLayout, (Bool) -> Void) {
        let makeTitleLayout = TextNode.asyncLayout(self.titleNode)
        
        return {item, params, neighbors in
            
            // 计算layout
            let titleFont = Font.regular(14)
            // 上下的间距
            let verticalInset = 11.0
            // 文本距离左侧的距离
            let leftInset = 16.0 + params.leftInset
            
            
            let titleAttribute = NSAttributedString(string: item.text, font: titleFont, textColor: .black)
            let (titleLayout, titleApply) = makeTitleLayout(TextNodeLayoutArguments(attributedString: titleAttribute, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: params.width - params.leftInset - params.rightInset, height: CGFloat.greatestFiniteMagnitude), alignment: .natural, cutout: nil, insets: .zero))
            
            let separatorHeight = UIScreenPixel
            
            let insets = itemListNeighborsGroupedInsets(neighbors, params)
            let contentSize = CGSize(width: params.width, height: titleLayout.size.height + verticalInset * 2)
            
            let layout = ListViewItemNodeLayout(contentSize: contentSize, insets: insets)
            
            // 返回layout
            return (layout, { [weak self] animated in
                guard let self = self else {
                    return
                }
                
                // 赋值
                self.item = item
                let _ = titleApply()
                // 动画方式
                let transition: ContainedViewLayoutTransition
                if animated {
                    transition = ContainedViewLayoutTransition.animated(duration: 0.4, curve: .spring)
                } else {
                    transition = .immediate
                }
                // 背景
                self.backgroundNode.insertIfNeed(superNode: self, at: 0)
                self.topStripeNode.insertIfNeed(superNode: self, at: 1)
                self.maskNode.insertIfNeed(superNode: self)
                
                let hasCorners = itemListHasRoundedBlockLayout(params)
                var hasTopCorners = false
                var hasBottomCorners = false
                switch neighbors.top {
                    case .sameSection(false):
                        // 当前组的非第一条，相当于indexPath.row > 0
                        self.topStripeNode.isHidden = false
                        hasTopCorners = false
                    default:
                        // 当前组组效果的第一条 ，相当于indexPath.row == 0
                        self.topStripeNode.isHidden = true
                        hasTopCorners = true
                }
                switch neighbors.bottom {
                    case .sameSection(false):
                        // 同一组不是最后一条，相当于 indexPath.row < (count - 1)
                        hasBottomCorners = false
                    default:
                        // 同一组最后一条，相当于 indexPath.row == (count - 1)
                        hasBottomCorners = true
                }
                self.maskNode.image = hasCorners ? PresentationResourcesItemList.cornersImage(defaultItemTheme().theme, top: hasTopCorners, bottom: hasBottomCorners) : nil
                
                self.backgroundNode.frame = CGRect(x: 0, y: -min(insets.top, separatorHeight), width: params.width, height: layout.contentSize.height + min(insets.top, separatorHeight) + min(insets.bottom, separatorHeight))
                self.containerNode.frame = self.backgroundNode.bounds
                self.maskNode.frame = self.backgroundNode.frame.insetBy(dx: params.leftInset, dy: 0)
                self.topStripeNode.frame = CGRect(x: 0, y: -min(insets.top, separatorHeight), width: layout.contentSize.width, height: separatorHeight)
                
                transition.updateFrame(node: self.titleNode, frame: CGRect(origin: CGPoint(x: leftInset, y: verticalInset), size: titleLayout.size))
                self.highlightedBackgroundNode.frame = CGRect(x: 0, y: -UIScreenPixel, width: params.width, height: layout.contentSize.height + UIScreenPixel * 2)
                // All Chats不展示箭头
                let arrowImage = PresentationResourcesItemList.disclosureArrowImage(defaultItemTheme().theme)
                let arrowSize = arrowImage?.size ?? CGSize(width: 20, height: 20)
                self.arrowNode.image = arrowImage
                self.arrowNode.isHidden = item.isAllChats
                self.arrowNode.frame = CGRect(x: params.width - params.rightInset - 7 - arrowSize.width , y: layout.contentSize.height.center(otherHeight: arrowSize.height), size: arrowSize)
                
            })
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, at point: CGPoint, animated: Bool) {
        super.setHighlighted(highlighted, at: point, animated: animated)
        
        if highlighted {
            // 高亮时的展示
            self.highlightedBackgroundNode.alpha = 1.0
            self.insertSubnode(self.highlightedBackgroundNode, aboveSubnode: self.backgroundNode)
        } else {
            if self.highlightedBackgroundNode.isInSuperNode {
                // 如果存在高亮背景
                if animated {
                    self.highlightedBackgroundNode.layer.animateAlpha(from: self.highlightedBackgroundNode.alpha, to: 0, duration: 0.4) { [weak self] completed in
                        if let self = self, completed {
                            self.highlightedBackgroundNode.removeFromSupernode()
                        }
                    }
                } else {
                    self.highlightedBackgroundNode.removeFromSupernode()
                }
            }
        }
    }
}

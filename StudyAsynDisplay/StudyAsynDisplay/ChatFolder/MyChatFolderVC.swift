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
    typealias SuggestBlock = (String) -> Void
    var addNew: CommnoEmptyAction? = nil
    var addSuggest: SuggestBlock? = nil
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
//        let originDataSignal = Atomic(value: ["All Chats"])
//        let originDataSignal = ValuePromise(["All Chats"], ignoreRepeated: true)
//        let state2 = Signal<String, NoError> { subscriber in
//            subscriber.putNext("")
//            return EmptyDisposable
//        }
        let statePromise = ValuePromise(["All Chats"], ignoreRepeated: true)
        
               
        
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
            // 获取原始数据
            statePromise.set(statePromise.rawValue + ["test"])
            
        }
        arguments.addSuggest = { title in
            // 获取原始数据
            print("arguments -- suggest -- Add")
            statePromise.set(statePromise.rawValue + ["test"])
        }
        // 数据配置信号
        let sugguestList = ValuePromise([
            SuggestedOriginData(title:"Unread", desc:"New messages frmo all chats."),
            SuggestedOriginData(title:"Personal", desc:"Only messages from personal chats.")], ignoreRepeated: true)
        let stateSignal = combineLatest(queue: .mainQueue(), statePromise.get(), sugguestList.get())
        |> map { dataList, suggestDataList -> (ItemListControllerState, (ItemListNodeState, MyChatFolderArguments)) in
            // controller配置
            let controllerState = ItemListControllerState(presentationData: defaultItemTheme(), title: .text("MyTitle"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: "MyBack"), animateChanges: false)
            // 数据配置
            let enties = MyChatFolderVC.createEnties(dataList: dataList, suggestList: suggestDataList)
            let listState = ItemListNodeState(presentationData: defaultItemTheme(), entries: enties, style: .blocks, animateChanges: true)
            
            return (controllerState, (listState, arguments))
        }
        |> afterDisposed {
        }
        
        // 主题+主题变更+数据
        let vc = MyChatFolderVC(presentationData: defaultItemTheme(), updatedPresentationData: updateDateSignal, state: stateSignal, tabBarItem: nil)
        
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
    static func createEnties(dataList: [String], suggestList: [SuggestedOriginData]) -> [MyCreateFolderListEntry] {
        var entryList: [MyCreateFolderListEntry] = []
        entryList.append(.screenHeader("Create folders for different groups of chats and quickly switch between them."))
        entryList.append(.listHeader("FOLDERS"))
        entryList.append(.addItem(text: "Create a Folder"))
        for (index, item) in dataList.enumerated() {
            entryList.append(.listItem(index: index, title: item, isAllChats: item == "All Chats", originData: item))
        }
        entryList.append(.listFooter("Tap 'Edit' to change the order or delete folders."))
        let sugestFilterList = suggestList.filter({ dataList.contains($0.title) == false })
        if sugestFilterList.count > 0 {
            entryList.append(.suggestedListHeader("RECOMMENDED FOLDERS"))
            for (index, item) in sugestFilterList.enumerated() {
                entryList.append(.suggestedListItem(index: index, title: item.title, desc: item.desc, originData: item.title))
            }
        }
        return entryList
    }
}

struct SuggestedOriginData: Equatable {
    var title: String
    var desc: String
    
    init(title: String, desc: String) {
        self.title = title
        self.desc = desc
    }
}

// MARK: - UIDataModel
enum MyCreateFolderListEntry: ItemListNodeEntry {
    case screenHeader(String)   // 动画+标题
    case listHeader(String) // 列表标题
    case addItem(text: String) // 添加
    case listItem(index: Int, title: String, isAllChats: Bool, originData: String) // 条目, originData要遵循Codable, Equatable
    case listFooter(String) // 列表底部内容
    case suggestedListHeader(String) // 列表标题
    case suggestedListItem(index: Int, title: String, desc: String, originData: String) // 条目, originData要遵循Codable, Equatable
    
    // 分组section排序
    var section: ItemListSectionId {
        switch self {
        case .screenHeader:
            return 0
        case .listHeader, .addItem, .listItem, .listFooter:
            return 1
        case .suggestedListHeader, .suggestedListItem:
            return 2
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
        case .suggestedListHeader:
            return 1002
        case let .suggestedListItem(index, _, _, _):
            return 1003 + index
        }
    }
    enum MyChatFolderEntryStableId: Hashable {
        case screenHeader
        case listHeader
        case addItem
        case listItem(Int,String)
        case listFooter
        case suggestedListHeader
        case suggestedListItem(String)
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
        case let .listItem(index, _,_, originData):
            return .listItem(index,originData)
        case .listFooter:
            return .listFooter
        case .suggestedListHeader:
            return .suggestedListHeader
        case let .suggestedListItem(_, _,_, originData):
            return .suggestedListItem(originData)
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
        case let .suggestedListHeader(text):
            return MyChatFolderListHeaderItem(text: text, sectionId: self.section)
        case let .suggestedListItem(_, title, desc, _):
            return MyChatFolderSuggestedListItem(text: title, sectionId: self.section, desc: desc) {
                if let arguments = arguments as? MyChatFolderArguments {
                    arguments.addSuggest?(title)
                }
            }
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
            
            let separatorHeight: CGFloat = 1//UIScreenPixel
            
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
        self.topStripeNode = ASDisplayNode(isLayerBacked: true, backgroundColor: UIColor(red: 236.0/255, green: 236.0/255, blue: 238.0/255, alpha: 1))
        
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
            
            let separatorHeight: CGFloat = 1//UIScreenPixel
            
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
                self.arrowNode.frame = CGRect(x: params.width - params.rightInset - 7 - arrowSize.width , y: layout.height.halfDis(other: arrowSize.height), size: arrowSize)
                
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

// MARK: - UIModel + SuggestedListLtem
class MyChatFolderSuggestedListItem: ListViewItem, ItemListItem {
    let text: String
    let desc: String
    // sectionId是实现ItemListItem的必须的内容
    public let sectionId: ItemListSectionId
    var action: CommnoEmptyAction?
    
    public init(text: String, sectionId: ItemListSectionId, desc: String, action: CommnoEmptyAction? = nil) {
        self.text = text
        self.sectionId = sectionId
        self.desc = desc
        self.action = action
    }
    

    // MARK: ListViewItem
    public func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        async {
            let node = MyChatFolderSuggestedListItemNode()
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
            guard let nodeValue = node() as? MyChatFolderSuggestedListItemNode else {
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

class MyChatFolderSuggestedListItemNode: ListViewItemNode {
    private var item: MyChatFolderSuggestedListItem?
    
    private let backgroundNode: ASDisplayNode // 背景
    private let topStripeNode: ASDisplayNode // 顶部分隔线
    
    private let maskNode: ASImageNode //
    
    private let titleNode: TextNode
    private let descNode: TextNode
    
    private let buttonBackgroundNode: ASImageNode
    private let buttonTitleNode: TextNode
    private let buttonNode: HighlightTrackingButtonNode
    
    public init() {
        
        self.backgroundNode = ASDisplayNode(isLayerBacked: true, backgroundColor: .white)
        self.topStripeNode = ASDisplayNode(isLayerBacked: true, backgroundColor: UIColor(red: 236.0/255, green: 236.0/255, blue: 238.0/255, alpha: 1))
        
        self.maskNode = ASImageNode()
        
        self.titleNode = TextNode()
        self.titleNode.isUserInteractionEnabled = false
        
        self.descNode = TextNode()
        self.descNode.isUserInteractionEnabled = false
        
        self.buttonBackgroundNode = ASImageNode()
        self.buttonBackgroundNode.isUserInteractionEnabled = false
        self.buttonTitleNode = TextNode()
        self.buttonTitleNode.isUserInteractionEnabled = false
        self.buttonNode = HighlightTrackingButtonNode()
        
        
       
        super.init(layerBacked: false, dynamicBounce: false)
        
        self.addSubnode(self.titleNode)
        self.addSubnode(self.descNode)
        self.addSubnode(self.buttonBackgroundNode)
        self.addSubnode(self.buttonTitleNode)
        self.addSubnode(self.buttonNode)
        
        self.buttonNode.addTarget(self, action: #selector(self.buttonPressed), forControlEvents: .touchUpInside)
        self.buttonNode.highligthedChanged = {[weak self] highlighted in
            guard let self = self else {
                return
            }
            if highlighted {
                // 点击按钮时
                self.buttonBackgroundNode.layer.removeAnimation(forKey: "opacity")
                self.buttonBackgroundNode.alpha = 0.7
            } else {
                self.buttonBackgroundNode.alpha = 1.0
                self.buttonBackgroundNode.layer.animateAlpha(from: 0.7, to: 1.0, duration: 0.3)
            }
        }
  
    }
    
    @objc func buttonPressed() {
        self.item?.action?()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.buttonNode.slopFrame.contains(point) {
            return self.buttonNode.view
        } else {
            return super.hitTest(point, with: event)
        }
    }
    
    override public var canBeSelected: Bool {
        return false
    }
    
    public func asyncLayout() -> (_ item: MyChatFolderSuggestedListItem, _ params: ListViewItemLayoutParams, _ neighbors: ItemListNeighbors) -> (ListViewItemNodeLayout, (Bool) -> Void) {
        let makeTitleLayout = TextNode.asyncLayout(self.titleNode)
        let makeDescLayout = TextNode.asyncLayout(self.descNode)
        let makeButtonTitleLayout = TextNode.asyncLayout(self.buttonTitleNode)
        
        return {item, params, neighbors in
            let leftInset = 16.0 + params.leftInset
            let rightInset = 16.0 + params.rightInset
            let buttonHeight: CGFloat = 28.0
            let maxWidth: CGFloat = params.width - params.rightInset - 20 - leftInset - rightInset
            
            // button
            let buttonFont = Font.semibold(14)
            let buttonAttribute = NSAttributedString(string: "ADD", font: buttonFont, textColor: .white)
            let (buttonTitleLayout, buttonTitleApply) = makeButtonTitleLayout(TextNodeLayoutArguments(attributedString: buttonAttribute, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), alignment: .natural, cutout: nil, insets: .zero))
            
            
            
            // 计算layout
            let titleFont = Font.regular(14)
            // 上下的间距
            let verticalInset = 11.0
            // button所占的位置
            let additionalTextRightInset: CGFloat = buttonTitleLayout.size.width + 14.0 * 2.0
            
            let titleAttribute = NSAttributedString(string: item.text, font: titleFont, textColor: .black)
            let (titleLayout, titleApply) = makeTitleLayout(TextNodeLayoutArguments(attributedString: titleAttribute, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: maxWidth - additionalTextRightInset, height: CGFloat.greatestFiniteMagnitude), alignment: .natural, cutout: nil, insets: .zero))
            
            // 描述
            let descFont = Font.regular(12)
            let descAttribute = NSAttributedString(string: item.desc, font: descFont, textColor: .lightGray)
            let (descLayout, descApply) = makeDescLayout(TextNodeLayoutArguments(attributedString: descAttribute, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: params.width - params.rightInset - 40.0 - leftInset, height: CGFloat.greatestFiniteMagnitude), alignment: .natural, cutout: nil, insets: .zero))
            
            let separatorHeight: CGFloat = 1//UIScreenPixel
            let titleSpacing: CGFloat = 3.0
            let height = verticalInset * 2.0 + titleLayout.size.height + titleSpacing + descLayout.size.height
            let contentSize = CGSize(width: params.width, height: height)
            let insets = itemListNeighborsGroupedInsets(neighbors, params)
            
            let layout = ListViewItemNodeLayout(contentSize: contentSize, insets: insets)
            
            // 返回layout
            return (layout, { [weak self] animated in
                guard let self = self else {
                    return
                }
                
                // 赋值
                self.item = item
                let _ = titleApply()
                let _ = descApply()
                let _ = buttonTitleApply()
                
                // 背景
                self.backgroundNode.insertIfNeed(superNode: self, at: 0)
                self.topStripeNode.insertIfNeed(superNode: self, at: 1)
                self.maskNode.insertIfNeed(superNode: self)
                
                let hasCorners = itemListHasRoundedBlockLayout(params)
                let (hasTopCorners, hasBottomCorners) = neighbors.isFirstOrLastRow
                self.topStripeNode.isHidden = hasTopCorners
                
                self.maskNode.image = hasCorners ? PresentationResourcesItemList.cornersImage(defaultItemTheme().theme, top: hasTopCorners, bottom: hasBottomCorners) : nil
                
                self.backgroundNode.frame = CGRect(x: 0, y: -min(insets.top, separatorHeight), width: params.width, height: layout.height + min(insets.top, separatorHeight) + min(insets.bottom, separatorHeight))
                self.maskNode.frame = self.backgroundNode.frame.insetBy(dx: params.leftInset, dy: 0)
                self.topStripeNode.frame = CGRect(x: leftInset, y: -min(insets.top, separatorHeight), width: layout.width-leftInset, height: separatorHeight)
                
                let titleFrame = CGRect(x: leftInset, y: 11, size: titleLayout.size)
                self.titleNode.frame = titleFrame
                
                let descFrame = CGRect(x: leftInset, y: titleFrame.maxY + titleSpacing, size: descLayout.size)
                self.descNode.frame = descFrame
                
                let buttonSize = CGSize(width: buttonTitleLayout.width + 14*2, height: buttonHeight)
                let buttonFrame = CGRect(x: params.width - rightInset - buttonSize.width, y: layout.height.halfDis(other: buttonSize.height), size: buttonSize)
                self.buttonNode.frame = buttonFrame
                self.buttonBackgroundNode.frame = buttonFrame
                self.buttonBackgroundNode.image = generateStretchableFilledCircleImage(diameter: buttonHeight, color: UIColor.systemBlue)
                
                self.buttonTitleNode.frame = CGRect(x: buttonFrame.minX + buttonFrame.width.halfDis(other: buttonTitleLayout.width), y: buttonFrame.minY + buttonFrame.height.halfDis(other: buttonTitleLayout.height), size: buttonTitleLayout.size)
                
            })
        }
    }
    
}

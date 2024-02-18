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
import AnimatedStickerNode
import TelegramAnimatedStickerNode

private final class MyChatFolderArguments {
}
class MyChatFolderVC: ItemListController {
    
    static func create() -> MyChatFolderVC {

        let theme = defaultPresentationTheme
        let corners = PresentationChatBubbleCorners(mainRadius: 0, auxiliaryRadius: 0, mergeBubbleCorners: false)
        let dateFormat = PresentationDateTimeFormat.init(timeFormat: .regular, dateFormat: .dayFirst, dateSeparator: "", dateSuffix: "", requiresFullYear: false, decimalSeparator: "", groupingSeparator: "")
        let presentationData = PresentationData(strings: defaultPresentationStrings, theme: theme, autoNightModeTriggered: false, chatWallpaper: theme.chat.defaultWallpaper, chatFontSize: .regular, chatBubbleCorners: corners, listsFontSize: .regular, dateTimeFormat: dateFormat, nameDisplayOrder: .firstLast, nameSortOrder: .firstLast, reduceMotion: false, largeEmoji: false)
        let updateDateSignal: Signal<ItemListPresentationData, NoError> = Signal { subscriber in
            let disposable = MetaDisposable()
            return disposable
        }

        // 数据信息号
        let statePromise = ValuePromise("test", ignoreRepeated: true)
        let statePromise2 = ValuePromise("aaa", ignoreRepeated: true)
        let stateSignal2 = combineLatest(queue: .mainQueue(), statePromise.get(),statePromise2.get())
        |> map { state, state2 -> (ItemListControllerState, (ItemListNodeState, MyChatFolderArguments)) in
            // controller配置
            let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("MyTitle"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: "MyBack"), animateChanges: false)
            // 数据配置
            let enties = MyChatFolderVC.createEnties()
            let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: enties, style: .blocks, animateChanges: true)
            
            return (controllerState, (listState, MyChatFolderArguments()))
        }
        |> afterDisposed {
        }
        
        let vc = MyChatFolderVC(presentationData: ItemListPresentationData(presentationData), updatedPresentationData: updateDateSignal, state: stateSignal2, tabBarItem: nil)
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
        vc.containerLayoutUpdated(layout, transition: .immediate)
        return vc
    }
    
    static func createEnties() -> [MyCreateFolderListEntry] {
        return [.screenHeader("Create folders for different groups of chats and quickly switch between them.")]
    }
}

// MARK: - DataModel
enum MyCreateFolderListEntry: ItemListNodeEntry {
    case screenHeader(String)
    
    // 分组section排序
    var section: ItemListSectionId {
        switch self {
        case .screenHeader:
            return 0
        }
    }
    // 排序id
    var sortId: Int {
        switch self {
        case .screenHeader:
            return 0
        }
    }
    // 固定id
    var stableId: Int32 {
        switch self {
        case .screenHeader:
            return 0
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
            return MyChatFolderSettingsHeaderItem(text: text, sectionId: self.section)
        }
    }
}
// MARK: - UIModel
class MyChatFolderSettingsHeaderItem: ListViewItem, ItemListItem {
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
            let node = MyChatFolderSettingsHeaderNode()
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
            guard let nodeValue = node() as? MyChatFolderSettingsHeaderNode else {
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
// MARK: - Node Cell
class MyChatFolderSettingsHeaderNode: ListViewItemNode {
    private let titleNode: TextNode
    private var animationNode: AnimatedStickerNode
    
    private var item: MyChatFolderSettingsHeaderItem?
    
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
    
    func asyncLayout() -> (_ item: MyChatFolderSettingsHeaderItem, _ params: ListViewItemLayoutParams, _ neighbors: ItemListNeighbors) -> (ListViewItemNodeLayout, () -> Void) {
        let makeTitleLayout = TextNode.asyncLayout(self.titleNode)
        
        return { item, params, neighbors in
            let isHidden = params.width > params.availableHeight && params.availableHeight < 400.0
            
            let leftInset: CGFloat = 32.0 + params.leftInset
            
            
            var size = 192
            var insetDifference = 100
            var additionalBottomInset: CGFloat = 0.0
            var playbackMode: AnimatedStickerPlaybackMode = .once
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

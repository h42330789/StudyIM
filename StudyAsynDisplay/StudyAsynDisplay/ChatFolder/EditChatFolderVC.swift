//
//  EditChatFolderVC.swift
//  StudyAsynDisplay
//
//  Created by flow on 2/28/24.
//

import ItemListUI
import SwiftSignalKit
import AsyncDisplayKit
import Display
import AnimatedStickerNode
import TelegramAnimatedStickerNode
import TelegramPresentationData

class EditChatFolderVCArguments {
    var updateState: ((((EditChatFolderStateModel) -> EditChatFolderStateModel)) -> Void)? // 更新数据
    var clearFocus: (() -> Void)? // 关闭键盘
    var focusOnName: (() -> Void)? // 然后焦点还要再name输入框里
}

struct EditChatFolderStateModel: Equatable {
    var name: String?
    
    var isComplete: Bool {
        if (self.name ?? "").isEmpty {
            return false
        }
        return true
    }
}


class EditChatFolderVC: ItemListController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    static func create(inName: String? = nil) -> EditChatFolderVC {

        // 主题更新信息
        let updateDateSignal: Signal<ItemListPresentationData, NoError> = Signal { subscriber in
            let disposable = MetaDisposable()
            return disposable
        }
        var getCurrentVCBlock: (() -> UIViewController?)?
        // 交互回调
        
        // 用于传递和记录本页面生成的值
        let initState = EditChatFolderStateModel(name: inName)
        let promise = ValuePromise(initState, ignoreRepeated: true)
        
        // 参数及交互回调
        let arguments = EditChatFolderVCArguments()
        arguments.updateState = { f in
            let oldState = promise.rawValue
            let newState = f(oldState)
            promise.set(newState)
        }
        arguments.clearFocus = {
            // 关闭输入键盘
            let currentVC = getCurrentVCBlock?()
            currentVC?.view.endEditing(true)
        }
        arguments.focusOnName = {
            guard let currentVC = getCurrentVCBlock?() as? ItemListController else {
                return
            }
            currentVC.forEachItemNode { itemNode in
                // 遍历所有node，如果是name输入的node，让focus
                if let itemNode = itemNode as? MyEditFolerNameInputItemNode {
                    itemNode.focus()
                }
            }
        }
        // 数据配置信号
        let stateSignal = promise.get()
        |> deliverOnMainQueue
        |> map { state -> (ItemListControllerState, (ItemListNodeState, EditChatFolderVCArguments)) in
            print("stateSignal--> map")
            // controller配置
            // 左侧按钮
            let leftNavigationButton = ItemListNavigationButton(content: .text("取消"), style: .regular, enabled: true, action: {
//                if let attemptNavigationImpl {
//                    attemptNavigationImpl({ value in
//                        if value {
//                            dismissImpl?()
//                        }
//                    })
//                } else {
//                    dismissImpl?()
//                }
                getCurrentVCBlock?()?.navigationController?.popViewController(animated: true)
            })
            // 右侧按钮
            let rightNavigationButton = ItemListNavigationButton(content: .text( (inName != nil) ? "完成" : "创建"), style: .bold, enabled: state.isComplete, action: {
//                applyImpl?(false, {
//                    dismissImpl?()
//                })
                // 将state里的值放到信号里去
                
                if let name = promise.rawValue.name, name.isNotEmpty {
                    var list = MyChatFolderVC.statePromise.rawValue
                    if inName != nil {
                        // 修改
                        list = list.map {
                            if $0 == inName {
                                return name
                            } else {
                                return $0
                            }
                        }
                    } else {
                        // 添加
                        list.append(name)
                    }
                    
                    MyChatFolderVC.statePromise.set(list)
                }
                
                getCurrentVCBlock?()?.navigationController?.popViewController(animated: true)
            })
            // 有了leftNavBtn, backNavBtn就不会生效了
            let controllerState = ItemListControllerState(presentationData: defaultItemTheme(), title: .text("MyCreateTitle"), leftNavigationButton: leftNavigationButton, rightNavigationButton: rightNavigationButton, backNavigationButton: ItemListBackButton(title: "MyBack"), animateChanges: false)
            // 数据配置
            let enties = EditChatFolderVC.createEnties(state: state)
            let listState = ItemListNodeState(presentationData: defaultItemTheme(), entries: enties, style: .blocks, animateChanges: true)
            
            return (controllerState, (listState, arguments))
        }
        |> afterDisposed {
        }
        
        // 主题+主题变更+数据
        let vc = EditChatFolderVC(presentationData: defaultItemTheme(), updatedPresentationData: updateDateSignal, state: stateSignal, tabBarItem: nil)
        
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
        getCurrentVCBlock = { [weak vc] in
            return vc
        }
        return vc
    }
    
    // MARK: - 创建数据
    // Data -> UIDataModel -> UIModel -> Node
    // hello -> MyEditFolderListEntry -> MyEditFolerScreenItem -> MyEditFolerScreenHeaderNode
    static func createEnties(state: EditChatFolderStateModel) -> [MyEditFolderListEntry] {
        print("EditChatFolderVC-createEnties")
        return [.screenHeader, .nameHeader("FOLDER NAME"), .name(placeholder: "Folder Name", value: state.name ?? "")]
    }
}
 enum MyEditFolderSection: Int32 {
    case screenHeader
    case name
}

 enum MyEditFolderStableId: Hashable {
    case index(Int)
}

 enum MyEditFolderListEntry: ItemListNodeEntry {
    case screenHeader // 动画
    case nameHeader(String)
    case name(placeholder: String, value: String)
    
    var section: ItemListSectionId {
        switch self {
        case .screenHeader:
            return MyEditFolderSection.screenHeader.rawValue
        case .nameHeader, .name:
            return MyEditFolderSection.name.rawValue
        }
    }
    
    var stableId: MyEditFolderStableId {
        switch self {
        case .screenHeader:
            return .index(0)
        case .nameHeader:
            return .index(1)
        case .name:
            return .index(2)
        }
    }
        
    var sortIndex: Int {
        switch self {
        case .screenHeader:
            return 0
        case .nameHeader:
            return 1
        case .name:
            return 2
        }
    }
        
    static func <(lhs: MyEditFolderListEntry, rhs: MyEditFolderListEntry) -> Bool {
        return lhs.sortIndex < rhs.sortIndex
    }
    
    // MARK: 配置Item
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        switch self {
        case .screenHeader:
            return MyEditFolerScreenItem(sectionId: self.section)
        case let .nameHeader(title):
            return MyEditFolderSectionHeaderItem(text: title, sectionId: self.section)
        case let .name(placeholder, value):
            return MyEditFolerNameInputItem(text: value, placeholder: placeholder, sectionId: self.section, textUpdated: { text in
                guard let arguments = arguments as? EditChatFolderVCArguments else {
                    return
                }
                arguments.updateState?({ oldState in
                    var newState = oldState
                    newState.name = text
                    return newState
                })
            }, action: {
                guard let arguments = arguments as? EditChatFolderVCArguments else {
                    return
                }
                // 让焦点保留在名称输入框里
                arguments.clearFocus?()
            }, cleared: {
                guard let arguments = arguments as? EditChatFolderVCArguments else {
                    return
                }
                // 让焦点保留在名称输入框里
                arguments.focusOnName?()
            })
        }
    }
        
  }

// MARK: - 动画ScreenHeader
class MyEditFolerScreenItem: ListViewItem, ItemListItem {
    let sectionId: ItemListSectionId
    var text: String
    
    init(sectionId: ItemListSectionId, text: String = "") {
        self.sectionId = sectionId
        self.text = text
    }
    
    public func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        print("MyEditFolerScreenItem-nodeConfiguredForParams")
        async {
            let node = MyEditFolerScreenHeaderNode()
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
        print("MyEditFolerScreenItem-updateNode")
        Queue.mainQueue().async {
            guard let nodeValue = node() as? MyEditFolerScreenHeaderNode else {
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
class MyEditFolerScreenHeaderNode: ListViewItemNode {
    private let titleNode: TextNode
    private var animationNode: AnimatedStickerNode
    
    private var item: MyEditFolerScreenItem?
    
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
    
    func asyncLayout() -> (_ item: MyEditFolerScreenItem, _ params: ListViewItemLayoutParams, _ neighbors: ItemListNeighbors) -> (ListViewItemNodeLayout, () -> Void) {
        // 为布局做准备
        let makeTitleLayout = TextNode.asyncLayout(self.titleNode)
        
        return { item, params, neighbors in
            // 计算布局
            let isHidden = params.width > params.availableHeight && params.availableHeight < 400.0
            
            let leftInset: CGFloat = 32.0 + params.leftInset
            
            let animationName: String = "ChatListNewFolder"
            let size = 192
            var insetDifference = 100
            var additionalBottomInset: CGFloat = 0
            var playbackMode: AnimatedStickerPlaybackMode = .once
            let topInset: CGFloat = CGFloat(size - insetDifference)
            
            let titleFont = Font.regular(13.0)
            let attributedText = NSAttributedString(string: item.text, font: titleFont, textColor: .black)
            let (titleLayout, titleApply) = makeTitleLayout(TextNodeLayoutArguments(attributedString: attributedText, backgroundColor: nil, maximumNumberOfLines: 0, truncationType: .end, constrainedSize: CGSize(width: params.width - params.rightInset - leftInset * 2.0, height: CGFloat.greatestFiniteMagnitude), alignment: .center, cutout: nil, insets: UIEdgeInsets()))
            
            let contentSize = CGSize(width: params.width, height: topInset + titleLayout.height)
            var insets = itemListNeighborsGroupedInsets(neighbors, params)
            insets.bottom += additionalBottomInset
            
            let layout = ListViewItemNodeLayout(contentSize: isHidden ? CGSize(width: params.width, height: 0.0) : contentSize, insets: insets)
            
            return (layout, {[weak self] in
                // 赋值，设置frame
                guard let self = self else {
                    return
                }
                if self.item == nil {
                    // 旧数据为空，则设置展示动画
                    self.animationNode.setup(source: AnimatedStickerNodeLocalFileSource(name: animationName), width: size, height: size, playbackMode: playbackMode, mode: .direct(cachePathPrefix: nil))
                    self.animationNode.visibility = true
                }
                
                self.item = item
                // 设置动画的fram、size
                let iconSize = CGSize(width: CGFloat(size) / 2.0, height: CGFloat(size) / 2.0)
                self.animationNode.frame = CGRect(x: layout.width.halfDis(other: iconSize.width) , y: -10.0, size: iconSize)
                self.animationNode.updateLayout(size: iconSize)
                
                // 设置title
                let _ = titleApply()
                // 展示title的内容
                self.titleNode.frame = CGRect(x: layout.width.halfDis(other: titleLayout.size.width), y: topInset + 8.0, size: titleLayout.size)
                
                self.animationNode.alpha = isHidden ? 0.0 : 1.0
                self.titleNode.alpha = isHidden ? 0.0 : 1.0
            })
        }
    }
}
// MARK: - 名称标题
public class MyEditFolderSectionHeaderItem: ListViewItem, ItemListItem {
    let text: String
    public let sectionId: ItemListSectionId
    // 只有isAlwaysPlain才不会在计算是否为组里的第一行影响
    public let isAlwaysPlain: Bool = true
    
    public init(text: String, sectionId: ItemListSectionId) {
        self.text = text
        self.sectionId = sectionId
    }
    
    public func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        print("MyEditFolderSectionHeaderItem-nodeConfiguredForParams")
        async {
            let node = MyEditFolerSectionHeaderItemNode()
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
        print("MyEditFolderSectionHeaderItem-updateNode")
        Queue.mainQueue().async {
            guard let nodeValue = node() as? MyEditFolerSectionHeaderItemNode else {
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

public class MyEditFolerSectionHeaderItemNode: ListViewItemNode {
    private var item: MyEditFolderSectionHeaderItem?
    
    private let titleNode: TextNode
   
    
    public init() {
        self.titleNode = TextNode()
        self.titleNode.isUserInteractionEnabled = false
        self.titleNode.contentMode = .left
        self.titleNode.contentsScale = UIScreen.main.scale
        
        
        super.init(layerBacked: false, dynamicBounce: false)
        
        self.addSubnode(self.titleNode)
        
    }
    
    public func asyncLayout() -> (_ item: MyEditFolderSectionHeaderItem, _ params: ListViewItemLayoutParams, _ neighbors: ItemListNeighbors) -> (ListViewItemNodeLayout, () -> Void) {
        let makeTitleLayout = TextNode.asyncLayout(self.titleNode)
        
        let previousItem = self.item
        
        return { item, params, neighbors in
            let leftInset: CGFloat = 15.0 + params.leftInset
            var textRightInset: CGFloat = 0
            // 计算大小
            let titleFont = Font.regular(13)
            let (titleLayout, titleApply) = makeTitleLayout(TextNodeLayoutArguments(attributedString: NSAttributedString(string: item.text, font: titleFont, textColor: .lightGray), backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: params.width - params.leftInset - params.rightInset - textRightInset, height: CGFloat.greatestFiniteMagnitude), alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
            
            let contentSize: CGSize
            var insets = UIEdgeInsets()
            
            contentSize = CGSize(width: params.width, height: titleLayout.size.height + 13.0)
            switch neighbors.top {
                case .none:
                    // 顶部没有数据
                    insets.top += 24.0
                case .otherSection:
                    // 顶部是其他组的数据
                    insets.top += 28.0
                default:
                    break
            }
            
            let layout = ListViewItemNodeLayout(contentSize: contentSize, insets: insets)
            
            return (layout, { [weak self] in
                // 展示内容及设置frame
                guard let self = self else {
                    return
                }
                self.item = item
                let _ = titleApply()
                self.titleNode.frame = CGRect(x: leftInset, y: 7.0, size: titleLayout.size)
            })
        }
    }
    
    override public func animateInsertion(_ currentTimestamp: Double, duration: Double, short: Bool) {
        self.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.4)
    }
    
    override public func animateRemoved(_ currentTimestamp: Double, duration: Double) {
        self.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.15, removeOnCompletion: false)
    }
}

// MARK: - name输入框
public class MyEditFolerNameInputItem: ListViewItem, ItemListItem {
    let text: String
    let placeholder: String
    let maxLength: NSInteger = 10
    let textUpdated: (String) -> Void
    var cleared: (() -> Void)? = nil
    var action:(() -> Void)
    public let sectionId: ItemListSectionId
    
    public init(text: String, placeholder: String, sectionId: ItemListSectionId,
                textUpdated: @escaping (String) -> Void,
                action: @escaping () -> Void,
                cleared: (() -> Void)? = nil) {
        self.text = text
        self.placeholder = placeholder
        self.sectionId = sectionId
        self.textUpdated = textUpdated
        self.cleared = cleared
        self.action = action
    }
    
    public func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        print("MyEditFolerNameInputItem-nodeConfiguredForParams")
        async {
            let node = MyEditFolerNameInputItemNode()
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
        print("MyEditFolerNameInputItem-updateNode")
        Queue.mainQueue().async {
            if let nodeValue = node() as? MyEditFolerNameInputItemNode {
            
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
}

public class MyEditFolerNameInputItemNode: ListViewItemNode, UITextFieldDelegate, ItemListItemNode, ItemListItemFocusableNode {
    private let backgroundNode: ASDisplayNode
    private let topStripeNode: ASDisplayNode
    private let maskNode: ASImageNode
    
    private let titleNode: TextNode
    private let measureTitleSizeNode: TextNode
    private let textNode: TextFieldNode
    private let clearIconNode: ASImageNode
    private let clearButtonNode: HighlightableButtonNode
    
    private var item: MyEditFolerNameInputItem?
    
    public var tag: ItemListItemTag? {
        return self.item?.tag
    }
    
    public init() {
        self.backgroundNode = ASDisplayNode()
        self.backgroundNode.isLayerBacked = true
        // 分隔线
        self.topStripeNode = ASDisplayNode()
        self.topStripeNode.isLayerBacked = true
        
        self.maskNode = ASImageNode()
        
        self.titleNode = TextNode()
        self.measureTitleSizeNode = TextNode()
        
        self.textNode = TextFieldNode()
        // 清空图标
        self.clearIconNode = ASImageNode()
        self.clearIconNode.isLayerBacked = true
        self.clearIconNode.displayWithoutProcessing = true
        self.clearIconNode.displaysAsynchronously = false
        // 清空按钮
        self.clearButtonNode = HighlightableButtonNode()
        
        super.init(layerBacked: false, dynamicBounce: false)
        
        self.addSubnode(self.titleNode)
        self.addSubnode(self.textNode)
        self.addSubnode(self.clearIconNode)
        self.addSubnode(self.clearButtonNode)
        
        self.clearButtonNode.addTarget(self, action: #selector(self.clearButtonPressed), forControlEvents: .touchUpInside)
        self.clearButtonNode.highligthedChanged = { [weak self] highlighted in
            if let strongSelf = self {
                if highlighted {
                    strongSelf.clearIconNode.layer.removeAnimation(forKey: "opacity")
                    strongSelf.clearIconNode.alpha = 0.4
                } else {
                    strongSelf.clearIconNode.alpha = 1.0
                    strongSelf.clearIconNode.layer.animateAlpha(from: 0.4, to: 1.0, duration: 0.2)
                }
            }
        }
    }
    
    public override func didLoad() {
        super.didLoad()
        // 只有设置了代理和添加了事件方法才会有回调
        self.textNode.clipsToBounds = true
        self.textNode.textField.delegate = self
        self.textNode.textField.addTarget(self, action: #selector(self.textFieldTextChanged(_:)), for: .editingChanged)
    }
    
    
    public func asyncLayout() -> (_ item: MyEditFolerNameInputItem, _ params: ListViewItemLayoutParams, _ neighbors: ItemListNeighbors) -> (ListViewItemNodeLayout, () -> Void) {
        let makeTitleLayout = self.titleNode.makeLayout
        let makeMeasureTitleSizeLayout = self.measureTitleSizeNode.makeLayout
        
        let currentItem = self.item
        
        return { item, params, neighbors in
            // 布局计算
            let clearIcon = PresentationResourcesItemList.itemListClearInputIcon(defaultItemTheme().theme)
            // 左的间距
            let leftInset: CGFloat = 16.0 + params.leftInset
            // 左侧额外加了clearBtn的间距
            var rightInset: CGFloat = 16.0 + params.rightInset + 32
            
            let titleString = NSMutableAttributedString(string: "文件名")
            titleString.addAttributes([NSAttributedString.Key.font: Font.regular(12)], range: NSMakeRange(0, titleString.length))
            
            let (titleLayout, titleApply) = makeTitleLayout(TextNodeLayoutArguments(attrStr: titleString, maxWidth: params.width - 32 - leftInset - rightInset))
            
            let (measureTitleLayout, measureTitleSizeApply) = makeMeasureTitleSizeLayout(TextNodeLayoutArguments(attrStr: NSAttributedString(string: "A", font: Font.regular(11)), maxWidth: params.width - 32 - leftInset - rightInset))
            
            let separatorHeight = UIScreenPixel
            let contentSize = CGSize(width: params.width, height: max(titleLayout.height, measureTitleLayout.height) + 22.0)
            let insets = itemListNeighborsGroupedInsets(neighbors, params)
            
            let layout = ListViewItemNodeLayout(contentSize: contentSize, insets: insets)
            
            let placehoderAttr = NSAttributedString(string: item.placeholder, font: Font.regular(13), textColor: .lightGray)
            
            return (layout, { [weak self] in
                guard let self = self else {
                    return
                }
                self.item = item
                
                self.topStripeNode.backgroundColor = .lightGray
                self.backgroundNode.backgroundColor = .white
                
                self.textNode.textField.textColor = .black
                // 键盘颜色风格
                self.textNode.textField.keyboardAppearance = .default
                self.textNode.textField.tintColor = .blue
                
                // 展示
                let _ = titleApply()
                self.titleNode.frame = CGRect(x: leftInset, y: layout.height => titleLayout.height, size: titleLayout.size)
                let _ = measureTitleSizeApply()
                
                let capitalizationType: UITextAutocapitalizationType = .sentences
                let autocorrectionType: UITextAutocorrectionType = .default
                let keyboardType: UIKeyboardType = .default
                
                self.textNode.textField.keyboardType = keyboardType
                self.textNode.textField.autocapitalizationType = capitalizationType
                self.textNode.textField.autocorrectionType = autocorrectionType
                self.textNode.textField.returnKeyType = .done
                self.textNode.textField.textAlignment = .natural
                
                if self.textNode.textField.text != item.text {
                    self.textNode.textField.text = item.text
                }
                
                self.textNode.frame = CGRect(x: leftInset + titleLayout.width, y: 0, size: CGSize(width: params.width - leftInset - rightInset - titleLayout.width, height: layout.height))
                
                // 清除按钮
                self.clearIconNode.image = clearIcon
                let clearIconSize = clearIcon?.size ?? .zero
                let buttonSize = CGSize(width: 38, height: layout.height)
                self.clearButtonNode.frame = CGRect(x: params.width - params.rightInset - buttonSize.width + (buttonSize.width => clearIconSize.width), y: 0, size: buttonSize)
                self.clearIconNode.frame = CGRect(x: params.width - params.rightInset - buttonSize.width + (buttonSize.width => clearIconSize.width), y: layout.height => clearIconSize.height, size: clearIconSize)
                
                //
                self.updateClearButtonVisibility()
                self.backgroundNode.insertIfNeed(superNode: self, at: 0)
                self.topStripeNode.insertIfNeed(superNode: self, at: 1)
                self.maskNode.insertIfNeed(superNode: self, at: 2)
                
                self.maskNode.image = PresentationResourcesItemList.cornersImage(defaultItemTheme().theme, top: true, bottom: true)
                self.backgroundNode.frame = CGRect(x: 0, y: -min(insets.top, separatorHeight), size: CGSize(width: params.width, height: layout.height + min(insets.top, separatorHeight) + min(insets.bottom, separatorHeight)))
                self.maskNode.frame = self.backgroundNode.frame.insetBy(dx: params.leftInset, dy: 0)
                
                self.textNode.textField.attributedPlaceholder = placehoderAttr
                
            })
        }
        
        
    }
    // MARK: clear按钮的显示控制
    func updateClearButtonVisibility() {
        guard let item = self.item else {
            return
        }
        let isHidden = item.text.isEmpty
        self.clearIconNode.isHidden = isHidden
        self.clearButtonNode.isHidden = isHidden
    }
    
    
    // MARK: - UITextFieldDelegate
    // MARK: 复制粘贴等非正常输入的场景会回调，正常输入也会回调
    @objc private func textFieldTextChanged(_ textField: UITextField) {
        self.textUpdated(self.textNode.textField.text ?? "")
    }
    
    @objc public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let item = self.item {
            let newText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
            
            // 超过最大长度后不允许再输入
            if item.maxLength != 0 && newText.count > item.maxLength {
                self.textNode.layer.addShakeAnimation()
                let hapticFeedback = HapticFeedback()
                hapticFeedback.error()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                    let _ = hapticFeedback
                })
                return false
            }
        }
        
        return true
    }
    
    @objc public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.item?.action()
        return false
    }
    
    @objc public func textFieldDidBeginEditing(_ textField: UITextField) {
        //self.item?.updatedFocus?(true)
//        if self.item?.selectAllOnFocus == true {
//            DispatchQueue.main.async {
//                let startPosition = self.textNode.textField.beginningOfDocument
//                let endPosition = self.textNode.textField.endOfDocument
//                self.textNode.textField.selectedTextRange = self.textNode.textField.textRange(from: startPosition, to: endPosition)
//            }
//        }
        self.updateClearButtonVisibility()
    }
    
    @objc public func textFieldDidEndEditing(_ textField: UITextField) {
//        self.item?.updatedFocus?(false)
        self.updateClearButtonVisibility()
    }
    // MARK: - 文字内容变化
    private func textUpdated(_ text: String) {
        self.item?.textUpdated(text)
    }
    // MARK: 清空按钮
    @objc func clearButtonPressed() {
        self.textNode.textField.text = ""
        self.textUpdated("")
        self.item?.cleared?()
    }
    
    // MARK: - ItemListItemFocusableNode
    public func focus() {
        if !self.textNode.textField.isFirstResponder {
            self.textNode.textField.becomeFirstResponder()
        }
    }
    
    public func selectAll() {
        self.textNode.textField.selectAll(nil)
    }
}

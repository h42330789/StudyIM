//
//  EditChatFolderVC.swift
//  StudyAsynDisplay
//
//  Created by flow on 2/28/24.
//

import ItemListUI
import SwiftSignalKit
import Display

class EditChatFolderVCArguments {
    
}


class EditChatFolderVC: ItemListController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    static func create() -> EditChatFolderVC {

        // 主题更新信息
        let updateDateSignal: Signal<ItemListPresentationData, NoError> = Signal { subscriber in
            let disposable = MetaDisposable()
            return disposable
        }
        var getCurrentVCBlock: (() -> UIViewController?)?
        // 交互回调
        let arguments = EditChatFolderVCArguments()
       
        // 数据配置信号
        let stateSignal = Signal<String, NoError>.single("")
        |> deliverOnMainQueue
        |> map { val -> (ItemListControllerState, (ItemListNodeState, EditChatFolderVCArguments)) in
            // controller配置
            let controllerState = ItemListControllerState(presentationData: defaultItemTheme(), title: .text("MyCreateTitle"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: "MyBack"), animateChanges: false)
            // 数据配置
            let enties = EditChatFolderVC.createEnties()
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
    // hello -> MyCreateFolderListEntry -> MyChatFolderSettingsHeaderItem -> MyChatFolderSettingsHeaderNode
    static func createEnties() -> [MyCreateFolderListEntry] {
        return []
    }
}

struct MyEditFolderListEntry: ItemListNodeEntry {
    case screenHeader // 动画
    case nameHeader(String)
    case name(placeholder: String, value: String)
    case includePeersHeader(String)
    case addIncludePeer(title: String)
    case includeCategory(index: Int, category: ChatListFilterIncludeCategory, title: String)
    case includePeer(index: Int, peer: EngineRenderedPeer, isRevealed: Bool)
    case includePeerInfo(String)
    case excludePeersHeader(String)
    case addExcludePeer(title: String)
    case excludeCategory(index: Int, category: ChatListFilterExcludeCategory, title: String)
    case excludePeer(index: Int, peer: EngineRenderedPeer, isRevealed: Bool)
    case excludePeerInfo(String)
    case includeExpand(String)
    case excludeExpand(String)
    case inviteLinkHeader(hasLinks: Bool)
    case inviteLinkCreate(hasLinks: Bool)
    case inviteLink(Int, ExportedChatFolderLink)
    case inviteLinkInfo(text: String)
}

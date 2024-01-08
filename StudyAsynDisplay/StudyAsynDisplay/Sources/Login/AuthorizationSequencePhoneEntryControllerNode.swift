//
//  AuthorizationSequencePhoneEntryControllerNode.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/26/23.
//

import Foundation
import AsyncDisplayKit
import Display
import AuthorizationUtils
import PhoneInputNode

// 区号和手机号Node
private final class PhoneAndCountryNode: ASDisplayNode {
    let countryButton: ASButtonNode
    let phoneBackground: ASImageNode
    let phoneInputNode: PhoneInputNode
    var selectCountryCode: (() -> Void)?
    
    init(strings: String){
        let inset: CGFloat = 24.0
        // 区号
        let countryButtonBackground = generateImage(CGSize(width: 136.0, height: 67.0), rotatedContext: { size, context in
            let arrowSize: CGFloat = 10.0
            let lineWidth = UIScreenPixel
            context.clear(CGRect(origin: CGPoint(), size: size))
            context.setStrokeColor(UIColor.red.cgColor)
            context.setLineWidth(lineWidth)
            context.move(to: CGPoint(x: inset, y: lineWidth / 2.0))
            context.addLine(to: CGPoint(x: size.width - inset, y: lineWidth / 2.0))
            context.strokePath()
            
            context.move(to: CGPoint(x: size.width - inset, y: size.height - arrowSize - lineWidth / 2.0))
            context.addLine(to: CGPoint(x: 69.0, y: size.height - arrowSize - lineWidth / 2.0))
            context.addLine(to: CGPoint(x: 69.0 - arrowSize, y: size.height - lineWidth / 2.0))
            context.addLine(to: CGPoint(x: 69.0 - arrowSize - arrowSize, y: size.height - arrowSize - lineWidth / 2.0))
            context.addLine(to: CGPoint(x: inset, y: size.height - arrowSize - lineWidth / 2.0))
            context.strokePath()
        })?.stretchableImage(withLeftCapWidth: 69, topCapHeight: 1)
        
        let countryButtonHighlightedBackground = generateImage(CGSize(width: 70.0, height: 67.0), rotatedContext: { size, context in
            let arrowSize: CGFloat = 10.0
            context.clear(CGRect(origin: CGPoint(), size: size))
            context.setFillColor(UIColor.green.cgColor)
            context.fill(CGRect(origin: CGPoint(), size: CGSize(width: size.width, height: size.height - arrowSize)))
            context.move(to: CGPoint(x: size.width, y: size.height - arrowSize))
            context.addLine(to: CGPoint(x: size.width - 1.0, y: size.height - arrowSize))
            context.addLine(to: CGPoint(x: size.width - 1.0 - arrowSize, y: size.height))
            context.addLine(to: CGPoint(x: size.width - 1.0 - arrowSize - arrowSize, y: size.height - arrowSize))
            context.closePath()
            context.fillPath()
        })?.stretchableImage(withLeftCapWidth: 69, topCapHeight: 2)
        
        let phoneInputBackground = generateImage(CGSize(width: 96.0, height: 57.0), rotatedContext: { size, context in
            let lineWidth = UIScreenPixel
            context.clear(CGRect(origin: CGPoint(), size: size))
            context.setStrokeColor(UIColor.blue.cgColor)
            context.setLineWidth(lineWidth)
            context.move(to: CGPoint(x: inset, y: size.height - lineWidth / 2.0))
            context.addLine(to: CGPoint(x: size.width, y: size.height - lineWidth / 2.0))
            context.strokePath()
            context.move(to: CGPoint(x: size.width - 2.0 + lineWidth / 2.0, y: size.height - 9.0))
            context.addLine(to: CGPoint(x: size.width - 2.0 + lineWidth / 2.0, y: 8.0))
            context.strokePath()
        })?.stretchableImage(withLeftCapWidth: 95, topCapHeight: 2)
        
        self.countryButton = ASButtonNode()
        self.countryButton.displaysAsynchronously = false
        self.countryButton.setBackgroundImage(countryButtonBackground, for: [])
        self.countryButton.titleNode.maximumNumberOfLines = 1
        self.countryButton.titleNode.truncationMode = .byTruncatingTail
        self.countryButton.setBackgroundImage(countryButtonHighlightedBackground, for: .highlighted)
        
        self.phoneBackground = ASImageNode()
        self.phoneBackground.image = phoneInputBackground
        self.phoneBackground.displaysAsynchronously = false
        self.phoneBackground.displayWithoutProcessing = true
        self.phoneBackground.isLayerBacked = true
        
        self.phoneInputNode = PhoneInputNode()
        
        
        super.init()
        
        self.countryButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 24.0 + 16.0, bottom: 10.0, right: 0.0)
        self.countryButton.contentHorizontalAlignment = .left
        
        self.countryButton.addTarget(self, action: #selector(self.countryPressed), forControlEvents: .touchUpInside)
        
        // 输入框地址变化响应
        self.phoneInputNode.countryCodeUpdated = {[weak self] code, id in
            let countryId = id ?? "US"
            let flagString = emojiFlagForISOCountryCode(countryId)
            let countryName = Locale(identifier: "en_US").localizedString(forRegionCode: countryId) ?? ""
            self?.countryButton.setTitle("\(flagString) \(countryName)", with: Font.regular(20), with: .black, for: [])
        }
        
        self.addSubnode(self.phoneBackground)
        self.addSubnode(self.countryButton)
        self.addSubnode(self.phoneInputNode)
        self.phoneInputNode.codeAndNumber = (1, nil, "")
    }
    
    @objc func countryPressed() {
        print("countryPressed")
        self.selectCountryCode?()
    }
    
    override func layout() {
        super.layout()
        
        let size = self.bounds.size
        let inset: CGFloat = 24.0
        
        self.countryButton.frame = CGRect(origin: CGPoint(), size: CGSize(width: size.width, height: 67.0))
        self.phoneBackground.frame = CGRect(origin: CGPoint(x: 0.0, y: size.height - 57.0), size: CGSize(width: size.width - inset, height: 57.0))
        
        let countryCodeFrame = CGRect(origin: CGPoint(x: 18.0, y: size.height - 58.0), size: CGSize(width: 71.0, height: 57.0))
        let numberFrame = CGRect(origin: CGPoint(x: 107.0, y: size.height - 58.0), size: CGSize(width: size.width - 96.0 - 8.0 - 24.0, height: 57.0))
        let placeholderFrame = numberFrame.offsetBy(dx: 0.0, dy: 17.0 - UIScreenPixel)
        
        let phoneInputFrame = countryCodeFrame.union(numberFrame)
        
        self.phoneInputNode.frame = phoneInputFrame
        self.phoneInputNode.countryCodeField.frame = countryCodeFrame.offsetBy(dx: -phoneInputFrame.minX, dy: -phoneInputFrame.minY)
        self.phoneInputNode.numberField.frame = numberFrame.offsetBy(dx: -phoneInputFrame.minX, dy: -phoneInputFrame.minY)
        self.phoneInputNode.placeholderNode.frame = placeholderFrame.offsetBy(dx: -phoneInputFrame.minX, dy: -phoneInputFrame.minY)
    }
}

class ContactSyncNode: ASDisplayNode {
    func updateLayout(width: CGFloat) -> CGSize {
//        let switchSize = CGSize(width: 51.0, height: 31.0)
//        let inset: CGFloat = 24.0
//        let titleSize = self.titleNode.updateLayout(CGSize(width: width - switchSize.width - inset * 2.0 - 8.0, height: .greatestFiniteMagnitude))
//        let height: CGFloat = 40.0
//        self.titleNode.frame = CGRect(origin: CGPoint(x: inset, y: floor((height - titleSize.height) / 2.0)), size: titleSize)
//        self.switchNode.frame = CGRect(origin: CGPoint(x: width - inset - switchSize.width, y: floor((height - switchSize.height) / 2.0)), size: switchSize)
        return CGSize(width: 100, height: 50)
    }
}

class AuthorizationSequencePhoneEntryControllerNode: ASDisplayNode {
    
    private let animationNode: ASImageNode
    private let titleNode: ASTextNode
    private let titleActivateAreaNode: AccessibilityAreaNode
    private let noticeNode: ASTextNode
    private let noticeActivateAreaNode: AccessibilityAreaNode
    private let phoneAndCountryNode: PhoneAndCountryNode
    private let loginNode: ASButtonNode
    private let contactSyncNode: ContactSyncNode
    private let proceedNode: ASButtonNode
    var selectCountryCode: (() -> Void)?
    var loginSuccess: (() -> Void)?
    
    init(strings: String) {
        self.animationNode = ASImageNode()
        self.animationNode.image = UIImage(named: "IntroPhone")
        
        self.titleNode = ASTextNode()
        self.titleNode.isUserInteractionEnabled = true
        self.titleNode.displaysAsynchronously = false
        self.titleNode.attributedText = NSAttributedString(string: "Your Phone", font: Font.light(30.0), textColor: .black)
        
        self.titleActivateAreaNode = AccessibilityAreaNode()
        self.titleActivateAreaNode.accessibilityTraits = .staticText
        
        self.noticeNode = ASTextNode()
        self.noticeNode.maximumNumberOfLines = 0
        self.noticeNode.displaysAsynchronously = false
        self.noticeNode.lineSpacing = 0.1
        self.noticeNode.attributedText = NSAttributedString(string: "Please confirm your country code and enter your phone number.", font: Font.regular(17.0), textColor: .black, paragraphAlignment: .center)
        
        self.noticeActivateAreaNode = AccessibilityAreaNode()
        self.noticeActivateAreaNode.accessibilityTraits = .staticText
        
        self.contactSyncNode = ContactSyncNode()
        
        self.phoneAndCountryNode = PhoneAndCountryNode(strings: "")
        
        self.proceedNode = ASButtonNode()
        self.proceedNode.setTitle("Continue", with: Font.regular(20), with: .black, for: .normal)
        
        self.loginNode = ASButtonNode()
        self.loginNode.setTitle("Login", with: Font.regular(20), with: .black, for: .normal)
        
        super.init()
        self.setViewBlock {
            return UITracingLayerView()
        }
        
        self.addSubnode(self.animationNode)
        self.addSubnode(self.titleNode)
        self.addSubnode(self.noticeNode)
        self.addSubnode(self.titleActivateAreaNode)
        self.addSubnode(self.noticeActivateAreaNode)
        self.addSubnode(self.phoneAndCountryNode)
        self.addSubnode(self.contactSyncNode)
        self.addSubnode(self.proceedNode)
        self.addSubnode(self.loginNode)
        
        self.phoneAndCountryNode.selectCountryCode = { [weak self] in
            self?.selectCountryCode?()
        }
        self.loginNode.addTarget(self, action: #selector(loginClick), forControlEvents: .touchUpInside)
    }
    
    @objc func loginClick() {
        self.loginSuccess?()
    }
    
    override func didLoad() {
        super.didLoad()
    }
    
    func containerLayoutUpdated(_ layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        var insets = layout.insets(options: [])
        insets.top = layout.statusBarHeight ?? 20.0
        if let inputHeight = layout.inputHeight, inputHeight.isZero == false {
            insets.bottom = max(inputHeight, insets.bottom)
        }
        let titleInset: CGFloat = layout.size.width > 320.0 ? 18.0 : 0
        let additionalBottomInset: CGFloat = layout.size.width > 320.0 ? 80.0 : 10.0
        self.titleNode.attributedText = NSAttributedString(string: "Your Phone", font: Font.bold(28.0), textColor: .black)
        let inset: CGFloat = 24.0
        let maximumWidth: CGFloat = min(430.0, layout.size.width)
        
        let animationSize = CGSize(width: 100, height: 100)
        let titleSize = self.titleNode.measure(CGSize(width: maximumWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let noticeInset: CGFloat = 0
        let minNoticeWidth: CGFloat = min(274.0 + noticeInset, maximumWidth - 28.0)
        let noticeSize = self.noticeNode.measure(CGSize(width: minNoticeWidth, height: CGFloat.greatestFiniteMagnitude))
        let proceedHeight: CGFloat = 40//self.proceedNode.updatelaywith
        let proceedSize = CGSize(width: maximumWidth - inset * 2.0, height: proceedHeight)
        let contactSyncSize = self.contactSyncNode.updateLayout(width: maximumWidth)
        let items: [AuthorizationLayoutItem] = [
            AuthorizationLayoutItem(node: self.animationNode, size: animationSize, spacingBefore: AuthorizationLayoutItemSpacing(weight: 10.0, maxValue: 10.0), spacingAfter: AuthorizationLayoutItemSpacing(weight: 0.0, maxValue: 0.0)),
            AuthorizationLayoutItem(node: self.titleNode, size: titleSize, spacingBefore: AuthorizationLayoutItemSpacing(weight: titleInset, maxValue: titleInset), spacingAfter: AuthorizationLayoutItemSpacing(weight: 0, maxValue: 0)),
            AuthorizationLayoutItem(node: self.noticeNode, size: noticeSize, spacingBefore: AuthorizationLayoutItemSpacing(weight: noticeInset, maxValue: noticeInset), spacingAfter: AuthorizationLayoutItemSpacing(weight: 0, maxValue: 0)),
            AuthorizationLayoutItem(node: self.phoneAndCountryNode, size: CGSize(width: maximumWidth, height: 115.0), spacingBefore: AuthorizationLayoutItemSpacing(weight: 30.0, maxValue: 30.0), spacingAfter: AuthorizationLayoutItemSpacing(weight: 0.0, maxValue: 0.0)),
            AuthorizationLayoutItem(node: self.loginNode, size: contactSyncSize, spacingBefore: AuthorizationLayoutItemSpacing(weight: 14.0, maxValue: 14.0), spacingAfter: AuthorizationLayoutItemSpacing(weight: 0.0, maxValue: 0.0))
        ]
        
        let _ = layoutAuthorizationItems(bounds: CGRect(origin: CGPoint(x: 0.0, y: insets.top), size: CGSize(width: layout.size.width, height: layout.size.height - insets.top - insets.bottom - additionalBottomInset)), items: items, transition: transition, failIfDoesNotFit: false)
    }
    
    var codeAndCountryId: (Int32?, String?, String) {
        get {
            return self.phoneAndCountryNode.phoneInputNode.codeAndNumber
        } set(value) {
            self.phoneAndCountryNode.phoneInputNode.codeAndNumber = value
        }
    }
}

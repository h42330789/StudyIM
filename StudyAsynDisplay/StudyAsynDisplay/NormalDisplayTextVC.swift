//
//  NormalDisplayTextVC.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 2/13/24.
//

import UIKit
import Display

class NormalDisplayTextVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let left: CGFloat = 10
        let maxWidth = view.bounds.width - left*2
        // 普通设置文本，手动设置宽高
        let label1 = UILabel()
        label1.numberOfLines = 0
        label1.attributedText = NSAttributedString(string: "UILabel: \n整个过程其实和 UIView 的初始化并且 addSubview 没有太大的区别。 现在，你可以把 Demo Run 起来看看效果了。", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        label1.frame = CGRect(x: left, y: 120, width: maxWidth, height: 100)
        self.view.addSubview(label1)
        
        // 设置内容，使用子线程计算宽高
        let label2 = TextNode()
        DispatchQueue.global().async {
            let titleAttributedString = NSAttributedString(string: "TextNode -> ASDisplayNode：\n整个过程其实和 UIView 的初始化并且 addSubview 没有太大的区别。 现在，你可以把 Demo Run 起来看看效果了。", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.green,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
            let makeTitleLayout = TextNode.asyncLayout(label2)
            let (titleLayout, titleApply) = makeTitleLayout(TextNodeLayoutArguments(attributedString: titleAttributedString, backgroundColor: nil, maximumNumberOfLines: 0, truncationType: .end, constrainedSize: CGSize(width: maxWidth, height: CGFloat.infinity), alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
            let transition: ContainedViewLayoutTransition = .immediate
            // 设置内容
            let _ = titleApply()
            
            DispatchQueue.main.async {
                let titleFrame = CGRect(origin: CGPoint(x: left, y: label1.frame.maxY+10), size: titleLayout.size)
                transition.updateFrameAdditive(node: label2, frame: titleFrame)
            }
            
        }
        self.view.addSubnode(label2)
        
        // 设置内容，使用子线程计算宽高
        let label22 = ImmediateTextNode()
        label22.maximumNumberOfLines = 0
        
        DispatchQueue.global().async {
            let titleAttributedString22 = NSAttributedString(string: "ImmediateTextNode -> TextNode -> ASDisplayNode：\n整个过程其实和 UIView 的初始化并且 addSubview 没有太大的区别。 现在，你可以把 Demo Run 起来看看效果了。", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.purple,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
            label22.attributedText = titleAttributedString22
            let size = label22.updateLayout(CGSize(width: maxWidth, height: CGFloat.infinity))
            let transition: ContainedViewLayoutTransition = .immediate
            DispatchQueue.main.async {
                let titleFrame = CGRect(origin: CGPoint(x: left, y: label1.frame.maxY+100), size: size)
                transition.updateFrameAdditive(node: label22, frame: titleFrame)
            }
            
        }
        self.view.addSubnode(label22)
        
        // 设置内容，使用子线程计算宽高
        let label3 = ASTextNode()
        label3.attributedText = NSAttributedString(string: "ASTextNode -> ImmediateTextNode -> TextNode -> ASDisplayNode：\n 整个过程其实和 UIView 的初始化并且 addSubview 没有太大的区别。 现在，你可以把 Demo Run 起来看看效果了。", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.red,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        DispatchQueue.global().async {
            
            // 子线程计算
            label3.measure(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
            DispatchQueue.main.async {
            // 回到主线程赋值
                label3.frame = CGRect(x: left, y: label1.frame.maxY+200, width: label3.calculatedSize.width, height: label3.calculatedSize.height)
            }
        }
        self.view.addSubnode(label3)
    }
}

//
//  ASDisplayNodeExts.swift
//  StudyAsynDisplay
//
//  Created by flow on 2/21/24.
//


import AsyncDisplayKit
import Display
import ItemListUI


typealias CommnoEmptyAction = () -> Void
extension ASDisplayNode {
    convenience init(isLayerBacked: Bool, backgroundColor: UIColor? = nil) {
        self.init()
        self.isLayerBacked = isLayerBacked
        if let bgColor = backgroundColor {
            self.backgroundColor = bgColor
        }
    }
    func insertIfNeed(superNode: ASDisplayNode, at: Int? = nil) {
        if self.supernode == nil {
            if let at = at {
                superNode.insertSubnode(self, at: at)
            } else {
                superNode.addSubnode(self)
            }
        }
    }
    var isInSuperNode: Bool {
        return self.supernode != nil
    }
    var slopFrame: CGRect {
        let slopInsets = self.hitTestSlop
        let slopFrame = self.frame.changeOffset(dx: slopInsets.left, dy: slopInsets.top, dw: -slopInsets.left-slopInsets.right, dh: -slopInsets.top-slopInsets.bottom)
        return slopFrame
    }
}

extension CGRect {
    func changeOffset(dx: CGFloat = 0, dy: CGFloat = 0, dw: CGFloat = 0, dh: CGFloat) -> CGRect {
        return CGRect(x: self.origin.x + dx, y: self.origin.y + dy, width: self.size.width + dw, height: self.size.height + dh)
    }
    
    init(x: CGFloat, y: CGFloat, size: CGSize) {
        self.init(origin: CGPoint(x: x , y: y), size: size)
    }
}

extension CGSize {
    func changeHeight(height: CGFloat) -> CGSize {
        return CGSize(width: self.width, height: height)
    }
    func changeWidth(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: self.height)
    }
}


extension CGFloat {
    func halfDis(other: CGFloat) -> CGFloat {
       return (self - other)/2
    }
}

extension ItemListNeighbors {
    var isFirstRow: Bool {
        switch self.top {
            case .sameSection(false):
                // 当前组的非第一条，相当于indexPath.row > 0
                return false
            default:
                // 当前组组效果的第一条 ，相当于indexPath.row == 0
                return true
        }
    }
    var isLastRow: Bool {
        switch self.bottom {
            case .sameSection(false):
                // 同一组不是最后一条，相当于 indexPath.row < (count - 1)
                return false
            default:
                // 同一组最后一条，相当于 indexPath.row == (count - 1)
                return true
        }
    }
    var isFirstOrLastRow: (isFirst: Bool, isLast: Bool) {
        return (self.isFirstRow, self.isLastRow)
    }
}

extension TextNodeLayout {
    var width: CGFloat {
        return self.size.width
    }
    var height: CGFloat {
        return self.size.height
    }
}

extension ListViewItemNodeLayout {
    var width: CGFloat {
        return self.contentSize.width
    }
    var height: CGFloat {
        return self.contentSize.height
    }
    init(width: CGFloat, height: CGFloat, insets: UIEdgeInsets? = nil) {
        self.init(contentSize: CGSize(width: width, height: height), insets: insets ?? .zero)
    }
}

extension TextNodeLayoutArguments {
    convenience init(attrStr: NSAttributedString, lines: Int = 0, maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude, maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude, alignment: NSTextAlignment = .natural, insets: UIEdgeInsets = .zero) {
        self.init(attributedString: attrStr, backgroundColor: nil, maximumNumberOfLines: lines, truncationType: .end, constrainedSize: CGSize(width: max(0, maxWidth), height: max(0, maxHeight)), alignment: alignment, cutout: nil, insets: insets)
    }
}

extension TextNode {
    var makeLayout: ((TextNodeLayoutArguments) -> (TextNodeLayout, () -> TextNode)) {
        return TextNode.asyncLayout(self)
    }
}

precedencegroup PipeRight {
    associativity: left
    higherThan: DefaultPrecedence
}
infix operator => : PipeRight
public func => <T>(value: T, otherVal: T) -> T {
    var result: Any
    if T.self is Int.Type {
        result = ((value as! Int) - (otherVal as! Int))/2
    } else if T.self is Float.Type {
        result = ((value as! Float) - (otherVal as! Float))/2
    } else if T.self is CGFloat.Type {
        result = ((value as! CGFloat) - (otherVal as! CGFloat))/2
    } else {
        result = value
    }
    return result as! T
}

extension String {
    var isNotEmpty: Bool {
        return self.isEmpty == false
    }
}

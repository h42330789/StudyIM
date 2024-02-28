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
}

extension TextNodeLayoutArguments {

}

//
//  ASDisplayNodeExts.swift
//  StudyAsynDisplay
//
//  Created by flow on 2/21/24.
//


import AsyncDisplayKit
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
    func center(otherHeight: CGFloat) -> CGFloat {
       return (self - otherHeight)/2
    }
}

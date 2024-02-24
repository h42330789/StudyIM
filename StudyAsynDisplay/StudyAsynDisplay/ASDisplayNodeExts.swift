//
//  ASDisplayNodeExts.swift
//  StudyAsynDisplay
//
//  Created by flow on 2/21/24.
//


import AsyncDisplayKit
import Display
import ItemListUI
import SwiftSignalKit


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

extension ValuePromise {
    var rawValue: T {
        // 通过get获取signal，调用start()获取最新的值并添加subscriber
        var valueObj: T!
        let valueDispose = self.get().start { value in
            valueObj = value
            
        }
        // 销毁了dispose，将valueDispose对应的subscriber也会被销毁
        valueDispose.dispose()
        // 返回获取的值
        return valueObj
    }
    
}

extension Promise {
    var rawValue: T? {
        get {
            // 通过get获取signal，调用start()获取最新的值并添加subscriber
            var valueObj: T? = nil
            let valueDispose = self.get().start { value in
                // 如果当前值为空时不会走这个回调，如果值不为空时会走这个回调
                valueObj = value
            }
            // 销毁了dispose，后续value值变化也不会触发上面的赋值操作
            valueDispose.dispose()
            // 返回获取的值
            return valueObj
        } set {
            if let val = newValue {
                self.set(Signal {subscriber in
                    subscriber.putNext(val)
                    return EmptyDisposable
                })
            }
        }
    }
}

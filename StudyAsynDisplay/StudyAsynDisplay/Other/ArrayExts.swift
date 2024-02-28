//
//  ArrayExts.swift
//  StudyAsynDisplay
//
//  Created by flow on 2/27/24.
//

import Foundation
extension Array {
    // 将元素进行分组
    func toGroupedList<E: Equatable>(closure: (Element) -> E?) -> [E: [Element]] {
        return reduce(into: [E: [Element]]()) { (result, e) in
            // 分组的key, 这里支持optional是为了调用时减少判断代码
            if let groupKey = closure(e) {
                // 之前的列表
                let preList = result[groupKey] ?? []
                result[groupKey] = preList + [e]
            }
        }
    }
    
    // 将数据转换为字典
    func toDict<E: Equatable>(closure: (Element) -> E?) -> [E: Element] {
        return reduce(into: [E: Element]()) { (result, e) in
            // 转换为dict的key，这里支持optional是为了调用时减少判断代码
            if let dictKey = closure(e) {
                result[dictKey] = e
            }
        }
    }
    
    // 对内容进行过滤
    func toDeduplicationList<E: Equatable>(closure: (Element) -> E?) -> [Element] {
        return reduce(into: [Element]()) { (result, e) in
            // 元素的唯一性key，这里支持optional是为了调用时减少判断代码
            let uniqueKey = closure(e)
            // 查询之前的列表里是否存在于当前key一样的元素
            let contains = result.contains { closure($0) == uniqueKey }
            // 如果已经存在该元素，不加入，如果不存在该元素，添加该元素
            result = result + (contains ? [] : [e])
        }
    }
    
    // 数组截取
    func subArray(from: Int, size: Int) -> Array<Element> {
        return self.subArray(from: from, to: from+size-1)
    }
    
    func subArray(from: Int) -> Array<Element> {
        return self.subArray(from: from, to: self.count-1)
    }
    
    func subArray(to: Int) -> Array<Element> {
        return self.subArray(from: 0, to: self.count-1)
    }
    
    func subArray(from: Int, to: Int) -> Array<Element> {
        // 可截取的最大值
        let maxTo: Int = self.count - 1
        var fromIndex = from
        if fromIndex < 0 {
            fromIndex = 0
        }
        if fromIndex >= maxTo {
            return []
        }
        var toIndex = to
        if toIndex < 0 {
            toIndex = 0
        }
        if toIndex > maxTo {
            toIndex = maxTo
        }
        if toIndex <= fromIndex {
            return []
        }
        return Array(self[from...toIndex])
    }
}

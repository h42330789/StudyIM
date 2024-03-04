//
//  SignalExts.swift
//  StudyAsynDisplay
//
//  Created by flow on 2/28/24.
//

import Foundation
import SwiftSignalKit

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

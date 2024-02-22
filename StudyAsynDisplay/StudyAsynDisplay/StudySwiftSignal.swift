//
//  StudySwiftSignal.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 2/23/24.
//

import UIKit
import SwiftSignalKit

// 参考
// https://itnext.io/source-code-walkthrough-of-telegram-ios-part-2-ssignalkit-afdf35ff60ba

class StudySwiftSignalVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
//        let signal = Signal<String, Error>({ subscriber in
//            subscriber.putNext("aa")
//            subscriber.putCompletion()
//            subscriber.putNext("bb")
//            return EmptyDisposable
//        })
//        let disposeBag = signal.start(next: { data in
//            print("start: \(data)")
//        }, error: { error in
//            print("start: \(error)")
//        }, completed: {
//            print("start: completed")
//        })
//        disposeBag.dispose()
//        let disposeBag2 = signal.start(next: { data in
//            print("start2: \(data)")
//        }, error: { error in
//            print("start2: \(error)")
//        }, completed: {
//            print("start2: completed")
//        })
//        disposeBag2.dispose()
        
        testValuePromise1()
        testValuePromise2()
        testValuePromise3()
    }
    
    func testValuePromise1() {
        print("======testValuePromise1======")
        let promise1 = ValuePromise("testA", ignoreRepeated: true)
        var promise1Value: String = "nil"
        print("promise1Value: \(promise1Value)")
        let promise1Dispose1 = promise1.get().start { value in
            print("promise1Dispose1-next:\(value)")
            promise1Value = value
        }
        // promise1Dispose1没在start时，会获取最新的值，所以promise1Value会变成最新的 testA
        print("promise1Value: \(promise1Value)")
        // 设置新值,这里由于promise1Dispose1还没有销毁，这里的set也会触发收到值
        promise1.set(promise1Value + "---" + "testB")
        
        // 重新获取，在start时会获取最新的值 testA---testB
        let promise1Dispose2 = promise1.get().start { value in
            print("promise1Dispose2-next: \(value)")
        }
        // promise1Dispose1没有销毁，会最新的设置也会生效，所以promise1Value会变成最新的 testA---testB
        print("promise1Value: \(promise1Value)")
        promise1Dispose1.dispose()
        promise1Dispose2.dispose()
        /**
         ======testValuePromise1======
         promise1Value: nil
         promise1Dispose1-next:testA
         promise1Value: testA
         promise1Dispose1-next:testA---testB
         promise1Dispose2-next: testA---testB
         promise1Value: testA---testB
         */
    }
    
    func testValuePromise2() {
        print("======testValuePromise2======")
        let promise2 = ValuePromise("testX", ignoreRepeated: true)
        var promise2Value: String = "nil"
        print("promise2Value: \(promise2Value)")
        let promise2Dispose1 = promise2.get().start { value in
            print("promise2Dispose1-next:\(value)")
            promise2Value = value
            
        }
        // 销毁了dispose，promise2Dispose1对应的subscriber也会被销毁，后续再给promise2设置时，promise2Dispose1再也不会处理了
        promise2Dispose1.dispose()
        // promise2Dispose1没在start时，会获取最新的值，所以promise2Value会变成最新的 testX
        print("promise2Value: \(promise2Value)")
        
        // 设置新值,这里由于promise1Dispose1还没有销毁，这里的set不会触发被销毁的subscriber
        promise2.set(promise2Value + "---" + "testY")
        
        // 重新获取，在start时会获取最新的值 test1---testB
        let promise2Dispose2 = promise2.get().start { value in
            print("promise2Dispose2-next: \(value)")
        }
        // 所以promise2Value会变成最新的 testX
        print("promise2Value: \(promise2Value)")
        promise2Dispose2.dispose()
        /**
         ======testValuePromise2======
         promise2Value: nil
         promise2Dispose1-next:testX
         promise2Value: testX
         promise2Dispose2-next: testX---testY
         promise2Value: testX
         */
    }
    
    func testValuePromise3() {
        print("======testValuePromise3======")
        let promise3 = ValuePromise("aaa", ignoreRepeated: true)
        let promise3Value = promise3.rawValue
        print("promise3Value: \(promise3Value)")
        
        promise3.set(promise3Value + "---" + "bbb")
        
        // 重新获取，在start时会获取最新的值 test1---testB
        let promise3Dispose2 = promise3.get().start { value in
            print("promise3Dispose2-next: \(value)")
        }
        // 所以promise2Value会变成最新的 testX
        print("promise3Value: \(promise3Value)")
        promise3Dispose2.dispose()
        /**
         ======testValuePromise3======
         promise3Value: aaa
         promise3Dispose2-next: aaa---bbb
         promise3Value: aaa
         */
    }
}

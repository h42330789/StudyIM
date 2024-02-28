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
        
//        testSignal()
//        testPromise1()
        testPromise2()
//        testValuePromise1()
//        testValuePromise2()
//        testValuePromise3()
    }
    
    func testSignal() {
        print("======testSignal======")
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
    }
    
    func testPromise1() {
        print("======testPromise1======")
        
        let promise1 = Promise<String>()
        // 由于第一次获取时，没有值，不会触发回调
        var promise1Value: String? = nil
        let dispose0 = promise1.get().start(next: { list in
            print("\(Date()) dispose0 get1--\(list)")
            promise1Value = list
        })
        dispose0.dispose()
        let promise1Value2 = promise1.rawValue
        print("\(Date()) promise1Value--\(promise1Value ?? "nil") promise1Value2:\(promise1Value2 ?? "nil")")
        // 由于第一次获取时，没有值，不会触发回调
        let dispose1 = promise1.get().start(next: { list in
            print("\(Date()) dispose1 get1--\(list)")
        })
        // 设置Signal后，会立即执行signal的generator, 通过next拿到generatoer里设置的putNext()的值
        // 获取到值后，会回调执行所有get()创建的subscriber
        promise1.set(Signal<String, NoError> { subscriber in
            // 会触发此刻已经存在的所有get()创建的所有监听者
            print("\(Date()) 设置值--aaa")
            subscriber.putNext("aaaa")
            DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
                // 会触发此刻已经存在的所有get()创建的所有监听者
                print("\(Date()) 设置值--bbb")
                subscriber.putNext("bbb")
            })
            return MetaDisposable()
        })
        // 由于promise里已经有值了，直接获取存在的值
        let dispose2 = promise1.get().start(next: { list in
            print("\(Date()) dispose2 get2--\(list)")
        })
        let promise1Value3 = promise1.rawValue
        print("\(Date()) promise1Value3:\(promise1Value3 ?? "nil")")
        /**
         ======testPromise1======
         2024-02-24 08:23:38 +0000 promise1Value--nil promise1Value2:nil
         2024-02-24 08:23:38 +0000 设置值--aaa
         2024-02-24 08:23:38 +0000 dispose1 get1--aaaa
         2024-02-24 08:23:38 +0000 dispose2 get2--aaaa
         2024-02-24 08:23:38 +0000 promise1Value3:aaaa
         2024-02-24 08:23:40 +0000 设置值--bbb
         2024-02-24 08:23:40 +0000 dispose1 get1--bbb
         2024-02-24 08:23:40 +0000 dispose2 get2--bbb
         */
    }

    func testPromise2() {
        print("======testPromise2======")
        // 这里可以设置默认值，如果有的话
        let networkPromise = Promise<String>()
        networkPromise.rawValue = UserDefaults.standard.string(forKey: "net1")
       
        // 设置Signal后，会立即执行signal的generator, 通过next拿到generatoer里设置的putNext()的值
        // 获取到值后，会回调执行所有get()创建的subscriber
        networkPromise.set(Signal<String, NoError> { subscriber in
            guard let url = URL(string: "https://reqres.in/api/users/2") else {
                subscriber.putCompletion()
                return EmptyDisposable
            }
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                if let data = data {
                    // 数据请求成功
                    var respStr = String(data: data, encoding: .utf8) ?? "--"
                    respStr = "response--Data"
                    UserDefaults.standard.setValue(respStr, forKey: "net1")
                    print("网络请求成功----")
                    subscriber.putNext(respStr)
                } else {
                    // 如果有错误
                    subscriber.putCompletion()
                }
            })
            // 开始请求
            task.resume()
            // 发起网络请求
            return ActionDisposable {
                // 如果销毁了，可以将网络请求取消
                task.cancel()
            }
        })
        // 监听数据，有数据变化才刷新
        let uiDispose = (networkPromise.get() |> distinctUntilChanged
        ).start(next: { str in
            // 网络请求后有数据变化，更新UI
            print("更新UI: \(str)")
        }, completed: {
            print("更新UI: completed")
        })
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

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
//        testPromise2()
//        testValuePromise1()
//        testValuePromise2()
//        testValuePromise3()
        testSignalCombineLatest()
    }
    
    func testSignalCombineLatest() {
        print("======testSignalCombineLatest======")
        /**
         combineLatest(queue:xxx, s1,s2,...): 第一个参数是queue，可以为空，信号，最少2个，最多可以有19个信号组合在一起
         combineLatest(queue:xxx, s1,t1,s2,t2): 第一个参数是queue，将2个信息组合在一起，还可以额外增加v1，v2
         combineLatest(queue:xxx, [s1,s2]]), 组合任何信号的数组
         内部会有一个Atomic，atomic里是一个[index:value]的字典，，用来存放signal里存值
         每次signal有值有都会存放在这里，这个state的数量与signal的数量一致时，没产生一个新的值都会触发
         */
        // 本质上都是调用的内部方法：combineLatestAny([xx,xx], combine:xxx,initialValues:[xx:xx],queue:xxx)，同时将signal转换为signalOfAny
        // signalOfAny本质是个中间信号，调用signalOfAny生成信号的start，就会触发原始信号的start，然后将原始信号的next，error，completed转发出来
        
        // ---- combineLatest(queue:xx, s1,v1,s2,v2)
        let s1 = Signal<String, NoError> { subcriber in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2, execute: {
                print("======s1-send======")
                subcriber.putNext("A")
            })
            return MetaDisposable()
        }
        let s2 = Signal<Int, NoError> { subcriber in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: {
                print("======s2-send======")
                subcriber.putNext(99)
            })
            return MetaDisposable()
        }
        // 有初始化值时，初始值会触发一次，任何一次修改都会触发一次
        let _ = combineLatest(s1, "B", s2, 100).start(next: { val1, val2 in
            print("======combineLatest--s1-s2--======")
            print(val1, val2)
        })
        // ---- combineLatest(queue:xx, s1,s2...), 最多可以传19个signal
        let s3 = Signal<String, NoError> { subcriber in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.4, execute: {
                print("======s3-send======")
                subcriber.putNext("X")
            })
            return MetaDisposable()
        }
        let s4 = Signal<Int, NoError> { subcriber in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3, execute: {
                print("======s4-send======")
                subcriber.putNext(88)
            })
            return MetaDisposable()
        }
        // 没有初始值时，需要所有的signal都产生了值才会再combine里触发
        let _ = combineLatest(s3, s4).start(next: { val1, val2 in
            print("======combineLatest--s3-s4======")
            print(val1, val2)
        })
        // ---- combineLatest(queue:xx, [s1,s2...])
        // 需要signal里的类型值是一样的，要是不一样，只能设置类型为Any
        let s5 = Signal<Any, NoError> { subcriber in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.4, execute: {
                print("======s5-send======")
                subcriber.putNext("aaa")
            })
            return MetaDisposable()
        }
        let s6 = Signal<Any, NoError> { subcriber in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3, execute: {
                print("======s6-send======")
                subcriber.putNext(111)
            })
            return MetaDisposable()
        }
        // 没有初始值时，需要所有的signal都产生了值才会再combine里触发
        let _ = combineLatest([s5, s6]).start(next: { valueList in
            print("======combineLatest--s5-s6======")
            print(valueList)
        })
        /**
        ======testSignalCombineLatest======
        ======combineLatest--s1-s2--======
        B 100
        ======s2-send======
        ======combineLatest--s1-s2--======
        B 99
        ======s1-send======
        ======combineLatest--s1-s2--======
        A 99
        ======s6-send======
        ======s4-send======
        ======s3-send======
        ======s5-send======
        ======combineLatest--s3-s4======
        X 88
        ======combineLatest--s5-s6======
        ["aaa", 111]
        */
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

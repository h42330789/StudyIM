//
//  ArrayTestVC.swift
//  StudyAsynDisplay
//
//  Created by flow on 2/27/24.
//

import Foundation

class ArrayTestVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let list = [1,2,2,3,3,6]
        // 去重
        let depList = list.toDeduplicationList { $0 }
        // 将数字转换为字符串的字符串
        let listDict = list.toDict{ "\($0)" }
        // 按奇偶数数据进行分组
        let groupDict = list.toGroupedList { $0 % 2 }
        let subList = list.subArray(from: 2)
        let mapList = list.map { $0 + 1 }
        let fileterList = list.filter{ $0 > 2}
        print(list, depList, listDict, groupDict, subList, mapList, fileterList)
    }
}

//
//  CountrySelectionControllerNode.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 1/8/24.
//

import Foundation
import AsyncDisplayKit
import Display
import TelegramCore
import AppBundle

// MARK: - 加载所有国家区号
 func loadCountryCodes() -> [Country] {
    guard let filePath = getAppBundle().path(forResource: "PhoneCountries", ofType: "txt") else {
        return []
    }
    guard let stringData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
        return []
    }
    guard let data = String(data: stringData, encoding: .utf8) else {
        return []
    }
    // 每一行两个元素之间的分割付
    let delimiter = ";"
    // 换行符，每一行代表一个国家
    let endOfLine = "\n"
    var result: [Country] = []
    var countriesByPrefix: [String: (Country, Country.CountryCode)] = [:]
    
    let locale = Locale(identifier: "en-US")
    let list = data.replacingOccurrences(of: "\r", with: "").components(separatedBy: "\n")
    for line in list {
         let currentLocation = line.startIndex
         // 1、获取第一个分隔符的range
         guard let codeRange = line.range(of: delimiter, options: [], range: currentLocation ..< line.endIndex) else {
             break
         }
         // 读取从开始位置到第一个分隔符的内容：国家区号
         let countryCode = String(line[currentLocation ..< codeRange.lowerBound])
         // 2、读取第二个分隔符后的一个分隔符
         guard let idRange = line.range(of: delimiter, options: [], range: codeRange.upperBound ..< line.endIndex) else {
             break
         }
         // 读取第二个分隔符到第三个分隔符之间的内容：国家id
         let countryId = String(line[codeRange.upperBound ..< idRange.lowerBound])
         // 3、读取第三个分隔符的位置
         guard let patternRange = line.range(of: delimiter, options: [], range: idRange.upperBound ..< line.endIndex) else {
             break
         }
         // 手机号模式
         let pattern = String(line[idRange.upperBound ..< patternRange.lowerBound])
         let countryName = locale.localizedString(forIdentifier: countryId) ?? ""
         if let _ = Int(countryCode) {
             let code = Country.CountryCode(code: countryCode, prefixes: [], patterns: !pattern.isEmpty ? [pattern] : [])
             let country = Country(id: countryId, name: countryName, localizedName: nil, countryCodes: [code], hidden: false)
             result.append(country)
             countriesByPrefix["\(code.code)"] = (country, code)
         }
    }
//     var currentLocation = data.startIndex
//    while true {
//        // 1、获取第一个分隔符的range
//        guard let codeRange = data.range(of: delimiter, options: [], range: currentLocation ..< data.endIndex) else {
//            break
//        }
//        // 读取从开始位置到第一个分隔符的内容：国家区号
//        let countryCode = String(data[currentLocation ..< codeRange.lowerBound])
//        // 2、读取第二个分隔符后的一个分隔符
//        guard let idRange = data.range(of: delimiter, options: [], range: codeRange.upperBound ..< data.endIndex) else {
//            break
//        }
//        // 读取第二个分隔符到第三个分隔符之间的内容：国家id
//        let countryId = String(data[codeRange.upperBound ..< idRange.lowerBound])
//        // 3、读取第三个分隔符的位置
//        guard let patternRange = data.range(of: delimiter, options: [], range: idRange.upperBound ..< data.endIndex) else {
//            break
//        }
//        // 手机号模式
//        let pattern = String(data[idRange.upperBound ..< patternRange.lowerBound])
//        // 4、读取第四个分隔符的位置
//        // 读取换行符
//        let maybeNameRange = data.range(of: endOfLine, options: [], range: patternRange.upperBound ..< data.endIndex)
//        let countryName = locale.localizedString(forIdentifier: countryId) ?? ""
//        if let _ = Int(countryCode) {
//            let code = Country.CountryCode(code: countryCode, prefixes: [], patterns: !pattern.isEmpty ? [pattern] : [])
//            let country = Country(id: countryId, name: countryName, localizedName: nil, countryCodes: [code], hidden: false)
//            result.append(country)
//            countriesByPrefix["\(code.code)"] = (country, code)
//        }
//        // 如果存在换行符
//        if let maybeNameRange = maybeNameRange {
//            // 如果存在换行符，将起始位置换到下一行重新开始
//            currentLocation = maybeNameRange.upperBound
//        } else {
//            break
//        }
//    }
    countryCodesByPrefix = countriesByPrefix
    
    return result
}
public func emojiFlagForISOCountryCode(_ countryCode: String) -> String {
    if countryCode.count != 2 {
        return ""
    }
    
    if countryCode == "FT" {
        return "🏴‍☠️"
    } else if countryCode == "XG" {
        return "🛰️"
    } else if countryCode == "XV" {
        return "🌍"
    }
    
    if ["YL"].contains(countryCode) {
        return ""
    }
    
    return flagEmoji(countryCode: countryCode)
}
public func flagEmoji(countryCode: String) -> String {
    if countryCode.uppercased() == "FT" {
        return "🏴‍☠️"
    }
    let base : UInt32 = 127397
    var flagString = ""
    for v in countryCode.uppercased().unicodeScalars {
        flagString.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return flagString
}
class CountrySectionModel {
    var englishCountryName: String = ""
    var countryName: String = ""
    var id: String = ""
    var code: Int = 0
    
    init(id: String, code: String?) {
        self.englishCountryName =  Locale(identifier: "en_US").localizedString(forRegionCode: id) ?? ""
        self.countryName = Locale(identifier: "en").localizedString(forRegionCode: id) ?? ""
        // 国家简称
        self.id = id
        // 区号
        self.code = Int(code ?? "") ?? 0
    }
}

class CountrySelectionControllerNode: ASDisplayNode, UITableViewDelegate, UITableViewDataSource {
    let itemSelected: (CountrySectionModel) -> Void
    
    private let tableView: UITableView
    private let searchTableView: UITableView
    
    private let sections: [String: [CountrySectionModel]]
    private let sectionTitles: [String]
    
    private var searchResults: [CountrySectionModel] = []
    
    init(itemSelected: @escaping (CountrySectionModel) -> Void) {
        self.itemSelected = itemSelected
        self.tableView = UITableView(frame: .zero, style: .plain)
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0.0
        }
        self.searchTableView = UITableView(frame: CGRect(), style: .plain)
        self.searchTableView.isHidden = true
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
            self.searchTableView.contentInsetAdjustmentBehavior = .never
        }
        var countryNamesAndCodes: [CountrySectionModel] = []
        var sections: [String: [CountrySectionModel]] = [:]
        for country in CountrySelectionController.countries() {
            // 海盗不展示
            if country.hidden || country.id == "FT" {
                continue
            }
            let model = CountrySectionModel(id: country.id, code: country.countryCodes.first?.code)
            countryNamesAndCodes.append(model)
            // 获取名称的第一个字母作为分组的字母
            let r = model.englishCountryName.startIndex..<model.englishCountryName.index(model.englishCountryName.startIndex, offsetBy: 1)
            let title = String(model.englishCountryName[r]).uppercased()
            if var list = sections[title] {
                sections[title] = list + [model]
            } else {
                sections[title] = [model]
            }
        }
        self.sections = sections
        self.sectionTitles = sections.keys.sorted()
        
        super.init()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.searchTableView)
    }
    
    func containerLayoutUpdated(_ layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: layout.intrinsicInsets.bottom, right: 0.0)
        self.searchTableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: layout.intrinsicInsets.bottom, right: 0.0)
        transition.updateFrame(view: self.tableView, frame: CGRect(origin: CGPoint(x: 0.0, y: navigationBarHeight), size: CGSize(width: layout.size.width, height: layout.size.height - navigationBarHeight)))
        transition.updateFrame(view: self.searchTableView, frame: CGRect(origin: CGPoint(x: 0.0, y: navigationBarHeight), size: CGSize(width: layout.size.width, height: layout.size.height - navigationBarHeight)))
    }
    // MARK: - TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView === self.tableView {
            return self.sectionTitles.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.tableView {
            let title = self.sectionTitles[section]
            let list = self.sections[title] ?? []
            return list.count
        } else {
            return self.searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView === self.tableView {
            let title = self.sectionTitles[section]
            return title
        } else {
            return nil
        }
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if tableView === self.tableView {
            return self.sectionTitles
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if tableView === self.tableView {
            if index == 0 {
                return 0
            } else {
                return max(0, index - 1)
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let currentCell = tableView.dequeueReusableCell(withIdentifier: "CountryCell") {
            cell = currentCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "CountryCell")
            let label = UILabel()
            label.font = Font.regular(17.0)
            cell.accessoryView = label
            cell.selectedBackgroundView = UIView()
        }
        
        var countryName: String
//        var cleanCountryName: String
//        let originalCountryName: String
        let code: String
        if tableView === self.tableView {
            let title = self.sectionTitles[indexPath.section]
            let list = self.sections[title] ?? []
            let model = list[indexPath.row]
            countryName = "\(emojiFlagForISOCountryCode(model.id)) \(model.countryName)"
            
            code = "+\(model.code)"
        } else {
            let model = self.searchResults[indexPath.row]
            countryName = "\(emojiFlagForISOCountryCode(model.id)) \(model.countryName)"
            code = "+\(model.code)"
        }
                
//        cell.accessibilityLabel = cleanCountryName
//        cell.accessibilityValue = code
        
        cell.textLabel?.text = countryName
//        cell.detailTextLabel?.text = originalCountryName
        if let label = cell.accessoryView as? UILabel {
            label.text = code
            label.sizeToFit()
//            label.textColor = self.theme.list.itemSecondaryTextColor
        }
//        cell.textLabel?.textColor = self.theme.list.itemPrimaryTextColor
//        cell.detailTextLabel?.textColor = self.theme.list.itemPrimaryTextColor
//        cell.backgroundColor = self.theme.list.plainBackgroundColor
//        cell.selectedBackgroundView?.backgroundColor = self.theme.list.itemHighlightedBackgroundColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === self.tableView {
            let title = self.sectionTitles[indexPath.section]
            let list = self.sections[title] ?? []
            self.itemSelected(list[indexPath.row])
        } else {
            self.itemSelected(self.searchResults[indexPath.row])
        }
    }
}

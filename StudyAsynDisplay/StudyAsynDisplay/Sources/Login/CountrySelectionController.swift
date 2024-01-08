//
//  CountrySelectionController.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 1/8/24.
//

import Foundation
import AsyncDisplayKit
import Display
import TelegramCore
//import SearchBarNode

private func removePlus(_ text: String?) -> String {
    var result = ""
    if let text = text {
        for c in text {
            if c != "+" {
                result += String(c)
            }
        }
    }
    return result
}
var countryCodes: [Country] = loadCountryCodes()
var countryCodesByPrefix: [String: (Country, Country.CountryCode)] = [:]

class CountrySelectionController: ViewController {
    static func countries() -> [Country] {
        return countryCodes
    }
    public var completeWithCountryCode: ((Int, String) -> Void)?
    public static func setupCountryCodes(countries: [Country], codesByPrefix: [String: (Country, Country.CountryCode)]) {
        countryCodes = countries
        countryCodesByPrefix = codesByPrefix
    }
    
//    public static func lookupCountryNameById(_ id: String, strings: PresentationStrings) -> String? {
//        for country in countryCodes {
//            if id == country.id {
//                let locale = localeWithStrings(strings)
//                if let countryName = locale.localizedString(forRegionCode: id) {
//                    return countryName
//                } else {
//                    return nil
//                }
//            }
//        }
//        return nil
//    }
        
    static func lookupCountryById(_ id: String) -> Country? {
        return countryCodes.first { $0.id == id }
    }
    
    public static func lookupCountryIdByNumber(_ number: String, preferredCountries: [String: String]) -> (Country, Country.CountryCode)? {
        let number = removePlus(number)
        var results: [(Country, Country.CountryCode)]? = nil
        if number.count == 1, let preferredCountryId = preferredCountries[number], let country = lookupCountryById(preferredCountryId), let code = country.countryCodes.first {
            return (country, code)
        }
        
        for i in 0..<number.count {
            let prefix = String(number.prefix(number.count - i))
            if let country = countryCodesByPrefix[prefix] {
                if var currentResults = results {
                    if let result = currentResults.first, result.1.code.count > country.1.code.count {
                        break
                    } else {
                        currentResults.append(country)
                    }
                } else {
                    results = [country]
                }
            }
        }
        if let results = results {
            if !preferredCountries.isEmpty, let (_, code) = results.first {
                if let preferredCountry = preferredCountries[code.code] {
                    for (country, code) in results {
                        if country.id == preferredCountry {
                            return (country, code)
                        }
                    }
                }
            }
            return results.first
        } else {
            return nil
        }
    }
    
    public static func lookupCountryIdByCode(_ code: Int) -> String? {
        for country in countryCodes {
            for countryCode in country.countryCodes {
                if countryCode.code == "\(code)" {
                    return country.id
                }
            }
        }
        return nil
    }
    
    public static func lookupPatternByNumber(_ number: String, preferredCountries: [String: String]) -> String? {
        let number = removePlus(number)
        if let (_, code) = lookupCountryIdByNumber(number, preferredCountries: preferredCountries), !code.patterns.isEmpty {
            var prefixes: [String: String] = [:]
            for pattern in code.patterns {
                let cleanPattern = pattern.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "X", with: "")
                let cleanPrefix = "\(code.code)\(cleanPattern)"
                prefixes[cleanPrefix] = pattern
            }
            for i in 0..<number.count {
                let prefix = String(number.prefix(number.count - i))
                if let pattern = prefixes[prefix] {
                    return pattern
                }
            }
            return code.patterns.first
        }
        return nil
    }
    override public func loadDisplayNode() {
        self.displayNode = CountrySelectionControllerNode(itemSelected: { [weak self] args in
            self?.completeWithCountryCode?(args.code, args.id)
            self?.dismiss()
        })
        self.displayNodeDidLoad()
    }
    private var controllerNode: CountrySelectionControllerNode {
        return self.displayNode as! CountrySelectionControllerNode
    }
    override public func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        self.controllerNode.containerLayoutUpdated(layout, navigationBarHeight: self.navigationLayout(layout: layout).navigationFrame.maxY, transition: transition)
    }
}

//class CountrySelectionNavigationContentNode: NavigationBarContentNode {
//    private let cancel: () -> Void
//    private let searchBar: SearchBarNode
//}

//
//  TestStringVC.swift
//  StudyAsynDisplay
//
//  Created by flow on 2/19/24.
//

import UIKit
extension String {
    enum TrimType {
        case leading
        case trailing
        case leadingAndTrailing
        case all
    }
    func trimWhitespace(type: TrimType) -> String {
        return self.trimWhitespace(type: type, characterSet: .whitespaces)
    }
    func trimWhitespaceAndNewline(type: TrimType) -> String {
        return self.trimWhitespace(type: type, characterSet: .whitespacesAndNewlines)
    }
    func trimWhitespace(type: TrimType, characterSet: CharacterSet) -> String {
        switch type {
        case .leading:
            return self.stringByTrimLeading(characterSet: characterSet)
        case .trailing:
            return self.stringByTrimTrailing(characterSet: characterSet)
        case .leadingAndTrailing:
            return self.trimmingCharacters(in: characterSet)
        case .all:
            return self.replacingOccurrences(of: " ", with: "")
        }
    }
    func stringByTrimLeading(characterSet: CharacterSet) -> String {
        var location: Int = 0
        let length: Int = self.count
        for scalar in self.unicodeScalars {
            if characterSet.contains(scalar) == false {
                break
            }
            location = location + 1
        }
        let startIndex = self.index(self.startIndex, offsetBy: location)
        let endIndex = self.index(self.startIndex, offsetBy: length)
        return String(self[startIndex..<endIndex])
    }
    
    func stringByTrimTrailing(characterSet: CharacterSet) -> String {
        let location: Int = 0
        var length: Int = self.count
        for scalar in self.unicodeScalars.reversed() {
            if characterSet.contains(scalar) == false {
                break
            }
            length = length - 1
        }
        let startIndex = self.index(self.startIndex, offsetBy: location)
        let endIndex = self.index(self.startIndex, offsetBy: length)
        return String(self[startIndex..<endIndex])
    }

    func replaceTrailingSpace(withText: String = "1") -> String {
        let list = self.components(separatedBy: "\n")
        var listNew: [String] = []
        for str in list {
            let strNew = str.trimWhitespace(type: .trailing)
            let cutCount = str.count - strNew.count
            if cutCount > 0 {
                // 如果右侧有空白内容
                let replaceStr = strNew + Array(0..<cutCount).map{ _ in withText }.joined()
                listNew.append(replaceStr)
            } else {
                listNew.append(str)
            }
        }
        
        let text2 = listNew.joined(separator: "\n")
        return text2
    }
}

class TestStringVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let text = " ab c "
        // 只去掉空格
        let trimLeftText = text.trimWhitespace(type: .leading)
        let trimRightText = text.trimWhitespace(type: .trailing)
        let trimBothText = text.trimWhitespace(type: .leadingAndTrailing)
        let trimAllText = text.trimWhitespace(type: .all)
        print("text:\(text)") // " ab c "
        print("trimLeftText:\(trimLeftText)") // "ab c "
        print("trimRightText:\(trimRightText)") // " ab c"
        print("trimBothText:\(trimBothText)") // "ab c"
        print("trimAllText:\(trimAllText)") // "abc"
        
        // ------------------
        let labelA = UILabel()
        labelA.textColor = .lightGray
        labelA.text = "--label.sizeThatFits-------------"
        labelA.font = UIFont.systemFont(ofSize: 10)
        labelA.frame = CGRect(origin: CGPoint(x: 10, y: 100 + 10), size: CGSize(width: 400, height: 30))
        self.view.addSubview(labelA)
        
        
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .lightGray
        let font = UIFont.systemFont(ofSize: 16, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
      let str = "古今中午   1233211   \n上下左右 1234567   \n其乐融融 1231231   "
        label.attributedText = NSAttributedString(string: str, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor : UIColor.red]
        )
        let maxWidth: CGFloat = 277
        let maxSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let size = label.sizeThatFits(maxSize)
        label.frame = CGRect(origin: CGPoint(x: 10, y: labelA.frame.maxY + 10), size: size)
        self.view.addSubview(label)
        
        // ------------------
        let label2 = UILabel()
        label2.numberOfLines = 0
        label2.backgroundColor = .lightGray
        // 将换行符前面的结尾部分的空格使用1来代替方便计算宽高
        let str2 = str.replaceTrailingSpace()
        label2.attributedText = NSAttributedString(string: str2, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor : UIColor.green]
        )
        let size2 = label2.sizeThatFits(maxSize)
        label2.frame = CGRect(origin: CGPoint(x: 10, y: label.frame.maxY + 10), size: size2)
        // 计算完高度后，再填充原始的数据
        label2.attributedText = NSAttributedString(string: str, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor : UIColor.green]
        )
        self.view.addSubview(label2)
        
        // -----------------
        let labelX = UILabel()
        labelX.textColor = .lightGray
        labelX.text = "---CTFramesetterSuggestFrameSizeWithConstraints-------------"
        labelX.font = UIFont.systemFont(ofSize: 10)
        labelX.frame = CGRect(origin: CGPoint(x: 10, y: label2.frame.maxY + 10), size: CGSize(width: 400, height: 30))
        self.view.addSubview(labelX)
        
        let label3 = UILabel()
        label3.numberOfLines = 0
        label3.backgroundColor = .lightGray
        label3.attributedText = NSAttributedString(string: str, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor : UIColor.red]
        )
        let size3 = label3.calculate(maxSize)
        label3.frame = CGRect(origin: CGPoint(x: 10, y: labelX.frame.maxY + 10), size: size3)
        label3.attributedText = NSAttributedString(string: str, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor : UIColor.red]
        )
        self.view.addSubview(label3)
        
        // -----------------
        
        let label4 = UILabel()
        label4.numberOfLines = 0
        label4.backgroundColor = .lightGray
        label4.attributedText = NSAttributedString(string: str, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor : UIColor.red]
        )
        let size4 = label4.calculate(maxSize)
        label4.frame = CGRect(origin: CGPoint(x: 10, y: label3.frame.maxY + 10), size: size4)
        label4.attributedText = NSAttributedString(string: str, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor : UIColor.red]
        )
        self.view.addSubview(label4)
        
        // ------------------
        let label5 = UILabel()
        label5.numberOfLines = 0
        label5.backgroundColor = .lightGray
        // 将换行符前面的结尾部分的空格使用1来代替方便计算宽高
        label5.attributedText = NSAttributedString(string: str2, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor : UIColor.green]
        )
        let size5 = label5.sizeThatFits(maxSize)
        label5.frame = CGRect(origin: CGPoint(x: 10, y: label4.frame.maxY + 10), size: size5)
        // 计算完高度后，再填充原始的数据
        
        label5.attributedText = NSAttributedString(string: str, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor : UIColor.green]
        )
        // 142x61
        // 142x58
        self.view.addSubview(label5)
        
        // ------------------
        let label6 = UILabel()
        label6.numberOfLines = 0
        label6.backgroundColor = .lightGray
        // 将换行符前面的结尾部分的空格使用1来代替方便计算宽高
        label6.attributedText = NSAttributedString(string: str2, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor : UIColor.green]
        )
        let size6 = label5.sizeThatFits(maxSize)
        label6.frame = CGRect(origin: CGPoint(x: 10, y: label5.frame.maxY + 10), size: size6)
        // 计算完高度后，再填充原始的数据
        
        label6.attributedText = NSAttributedString(string: str, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor : UIColor.green]
        )
        // 142x61
        // 142x58
        self.view.addSubview(label6)
    }
    
    
}

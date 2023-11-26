//
//  RMIntroViewController.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/22/23.
//

import UIKit

class RMIntroViewController: UIViewController {
    var skipBlcok: (() -> Void)?
//    var englishStrings: [String: String] = [:]
//    var loadedView: Bool = false
//    lazy var wrapperView = UIScrollView(frame: self.view.bounds)
//    lazy var pageScrollView: UIScrollView =  {
//        let scrollView = UIScrollView(frame: self.view.bounds)
//        scrollView.contentInsetAdjustmentBehavior = .never
//        scrollView.clipsToBounds = true
//        scrollView.isOpaque = true
//        scrollView.clearsContextBeforeDrawing = false
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.isPagingEnabled = true
//        scrollView.contentSize = CGSize(width: 6*self.view.bounds.size.width, height: self.view.bounds.size.height)
////        scrollView.delegate = self
//        return scrollView
//    }()
//    
//    lazy var pageControl: UIPageControl = {
//        let control = UIPageControl()
//        control.autoresizingMask = .flexibleBottomMargin
//        control.isUserInteractionEnabled = false
//        control.numberOfPages = 6
//        control.pageIndicatorTintColor = .red
//        control.currentPageIndicatorTintColor = .green
//        return control
//    }()
//    
//    lazy var altrnativeLanguageButton = UIButton()
//    
//    convenience init(backgroundColor: UIColor) {
//        self.init()
//        // 多语言
//        let stringKeys = [
//            "Tour.Title1",
//            "Tour.Title2",
//            "Tour.Title3",
//            "Tour.Title4",
//            "Tour.Title5",
//            "Tour.Title6",
//            "Tour.Text1",
//            "Tour.Text2",
//            "Tour.Text3",
//            "Tour.Text4",
//            "Tour.Text5",
//            "Tour.Text6",
//            "Tour.StartButton"
//        ]
//        if let bundlePath = Bundle.main.path(forResource: "en", ofType: "lproj"),
//           let bundle = Bundle(path: bundlePath) {
//            for key in stringKeys {
//                let value = bundle.localizedString(forKey: key, value: key, table: nil)
//                englishStrings[key] = value
//            }
//        }
//    }
//    override func loadView() {
//        let introView = RMIntroView(frame:  UIScreen.main.bounds)
//        introView.onLayout = {[weak self] in
//            self?.updateLayout()
//        }
//        self.view = introView
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        let btn = UIButton()
        btn.setTitle("skip", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.frame = CGRect(x: 100, y: 100, width: 60, height: 40)
        btn.addTarget(self, action: #selector(skipClick), for: .touchUpInside)
        btn.backgroundColor = .cyan
        self.view.addSubview(btn)
//        if self.loadedView {
//            return
//        }
//        self.loadedView = true
//        self.loadGL()
//        self.view.addSubview(self.wrapperView)
//        self.wrapperView.addSubview(self.pageScrollView)
//        self.wrapperView.addSubview(self.pageControl)
//        
//        self.view.addSubview(self.altrnativeLanguageButton)
        
    }
    
    @objc func skipClick() {
        print("skipClick")
        self.skipBlcok?()
    }
    
//    func loadGL() {
//        
//    }
//    
//    func updateLayout() {
//        
//    }
}

class RMIntroView: UIView {
    var onLayout: (() -> Void)?
    override func layoutSubviews() {
        super.layoutSubviews()
        self.onLayout?()
    }
}

class RMIntroPageView: UIView {
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 35)
        label.textColor = .black
        label.textAlignment = .center
        label.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
        return label
    }()
    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.numberOfLines = 0
        label.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
        return label
    }()
    convenience init(frame: CGRect, title: String, desc: String) {
        self.init(frame: frame)
        // 标题
        headerLabel.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 64+8)
        headerLabel.text = title
        
        self.descLabel.frame = CGRect(x: 0, y: 25, width: frame.size.width, height: 17)
        
        // 找出**之间的内容，进行加粗展示
        // "The world's **fastest** messaging app.\nIt is **free** and **secure**.";
        var boldRanges: [NSRange] = []
        let cleanText = NSMutableString(string: desc)
        while true {
            let startRange = cleanText.range(of: "**")
            if startRange.location == NSNotFound {
                break
            }
            cleanText.deleteCharacters(in: startRange)
            let endRange = cleanText.range(of: "**")
            if endRange.location == NSNotFound {
                break
            }
            cleanText.deleteCharacters(in: endRange)
            boldRanges.append(NSMakeRange(startRange.location, endRange.location - startRange.location))
        }
        let descAttrStr = NSMutableAttributedString(string: cleanText as String)
        var boldAttrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
        for range in boldRanges {
            descAttrStr.addAttributes(boldAttrs, range: range)
        }
        // 格式
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        style.lineBreakMode = .byWordWrapping
        style.alignment = .center
        descAttrStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSMakeRange(0, descAttrStr.length))
        self.descLabel.attributedText = descAttrStr
        
        self.addSubview(headerLabel)
        self.addSubview(descLabel)
        
    }
}

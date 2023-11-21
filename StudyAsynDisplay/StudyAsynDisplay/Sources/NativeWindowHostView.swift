//
//  NativeWindowHostView.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 11/22/23.
//

import UIKit

 final class NativeWindow: UIWindow {
    
 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if let gestureRecognizers = self.gestureRecognizers {
            for recognizer in gestureRecognizers {
                recognizer.delaysTouchesBegan = false
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
}

final class WindowRootViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
    }
}

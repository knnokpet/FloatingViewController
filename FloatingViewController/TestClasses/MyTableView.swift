//
//  MyTableView.swift
//  FloatingViewController
//
//  Created by Masayuki Ikeda on 2019/12/06.
//  Copyright © 2019 Masayuki Ikeda. All rights reserved.
//

import UIKit

class MyTableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        self.backgroundColor = UIColor.white
    }
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        var hittedView = super.hitTest(point, with: event)
//        debugPrint(hittedView.self)
//        if hittedView == self {
//            return nil
//        }
//        return hittedView
//    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        debugPrint("touchesbegun")
//        //self.next?.touchesBegan(touches, with: event)
//        superview?.touchesBegan(touches, with: event)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        debugPrint("touches moved")
//        superview?.touchesMoved(touches, with: event)
//        self.isScrollEnabled = false
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        superview?.touchesEnded(touches, with: event)
//        self.isScrollEnabled = true
//    }
    
}

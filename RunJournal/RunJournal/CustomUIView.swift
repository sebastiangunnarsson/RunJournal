//
//  CustomUIView.swift
//  RunJournal
//
//  Created by David Karlsson on 2015-02-26.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit

class CustomUIView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.endEditing(true)
    }
    
}

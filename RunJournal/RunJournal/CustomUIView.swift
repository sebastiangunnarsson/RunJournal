//
//  CustomUIView.swift
//  RunJournal
//
//  Created by David Karlsson on 2015-02-26.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit

class CustomUIView: UIView {

    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.endEditing(true)
    }
    
}

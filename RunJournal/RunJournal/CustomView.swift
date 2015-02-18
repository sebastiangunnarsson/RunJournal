//
//  CustomView.swift
//  RunJournal
//
//  Created by David Karlsson on 2015-02-18.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit

class CustomView: UIView {

    /*
        Custom class lagt på viewn i Scrollviewn för att fånga touch began (när man trycker utanför
            en textruta och då stänger ned tagentbordet)
    */

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.endEditing(true)
    }
    
}

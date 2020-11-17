//
//  CustomTextField.swift
//  CountdownTimer
//
//  Created by Duncan Champney on 11/17/20.
//  Copyright © 2020 Duncan Champney. All rights reserved.
//

import Cocoa

class CustomTextField: NSTextField {
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.selectText(self)
    }
}

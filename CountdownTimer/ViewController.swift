//
//  ViewController.swift
//  CountdownTimer
//
//  Created by Duncan Champney on 11/16/20.
//  Created by Duncan Champney on 11/16/20.
//  Copyright © 2020 Duncan Champney.
//  Licensed under the MIT Open source license:
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    static var viewController: ViewController? = nil
    @IBOutlet weak var totalTimeField: NSTextField!

    @IBOutlet weak var hoursField: NSTextField!
    @IBOutlet weak var minutesField: NSTextField!
    @IBOutlet weak var secondsField: NSTextField!

    @IBOutlet weak var hoursStepper: NSStepper!
    @IBOutlet weak var minutesStepper: NSStepper!
    @IBOutlet weak var secondsStepper: NSStepper!
    @IBOutlet weak var floatCheckbox: NSButton!

    @IBOutlet weak var startButton: NSButton!

    var floatWindow: Bool = false {
        didSet {
            setFloatingWindow(floatWindow)
            UserDefaults.standard.set(floatWindow, forKey: "floatWindow")
        }
    }

    weak var timer: Timer? = nil {
        didSet {
            if timer == nil {
                startButton.title = "Start"
            } else {
                startButton.title = "Pause"
            }
        }
    }
    var timeRemaining: TimeInterval = 0 {
        didSet {
            totalTimeField.stringValue = timeFormatter.string(from: timeRemaining) ?? ""
        }
    }

    lazy var bellSoundPlayer:AVAudioPlayer =  {
        guard let url = Bundle.main.url(forResource: "bell_small_001", withExtension: "mp3"),
            let player = try? AVAudioPlayer(contentsOf: url)
            else { fatalError () }
        return player
    }()

    lazy var timeFormatter:DateComponentsFormatter = {
        let temp = DateComponentsFormatter()
        temp.allowedUnits = [.hour, .minute, .second]
        temp.unitsStyle = .positional
        temp.zeroFormattingBehavior = .pad
        return temp
    }()

    var hours: Int = 0 {
        didSet {
            hoursStepper.integerValue = hours
            hoursField.stringValue = String(format: "%02d", hoursStepper.integerValue)
        }
    }

    var minutes: Int = 0 {
        didSet {
            minutesStepper.integerValue = minutes
            minutesField.stringValue = String(format: "%02d", minutesStepper.integerValue)
        }
    }

    var seconds: Int = 0 {
        didSet {
            secondsStepper.integerValue = seconds
            secondsField.stringValue = String(format: "%02d", secondsStepper.integerValue)
        }
    }

    public func toggleFloatWindow() {
        floatWindow = !floatWindow
    }

    func saveHMS() {
        let defaults = UserDefaults.standard
        defaults.set(hours, forKey: "hours")
        defaults.set(minutes, forKey: "minutes")
        defaults.set(seconds, forKey: "seconds")
    }

    func loadHMS() {
        let defaults = UserDefaults.standard
        hours = defaults.integer(forKey: "hours")
        minutes = defaults.integer(forKey: "minutes")
        seconds = defaults.integer(forKey: "seconds")
    }

    func calcTime() {
        timeRemaining = Double(hours * 3600 + minutes * 60 + seconds)
        saveHMS()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.register(defaults: ["hours": 0,
                                                  "minutes": 2,
                                                  "seconds": 0,
                                                  "floatWindow": false])
        loadHMS()
        ViewController.viewController = self
        view.wantsLayer = true
        calcTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.floatWindow = UserDefaults.standard.bool(forKey: "floatWindow")
            self.view.window?.makeFirstResponder(self.minutesField)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard let panel = view.window as? NSPanel else {
            print("Not a panel")
            return
        }
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }

    func resignFirstResponders() {
        view.window?.makeFirstResponder(startButton)
        hours = Int(hoursField.stringValue) ?? 0
        minutes = Int(minutesField.stringValue) ?? 0
        seconds = Int(secondsField.stringValue) ?? 0
    }

    @IBAction func handleStartPauseButton(_ sender: Any) {
        if timer == nil {
            resignFirstResponders()
            if timeRemaining == 0 {
                calcTime()
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.bellSoundPlayer.play()
                    for index in 0...3 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(index)  * 0.2) {
                            let color = (index % 2 ==  0) ? NSColor.cyan.cgColor : NSColor.clear.cgColor
                            self.view.layer?.backgroundColor = color
                        }
                    }
                    timer.invalidate()
                    self.timer = nil
                }
            }
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
    func setFloatingWindow(_ float: Bool) {
        guard let panel = view.window as? NSPanel else {
            print("Not a panel")
            return
        }
        if float {
            floatCheckbox.state = .on
            panel.level = .mainMenu
            panel.orderFrontRegardless()
        } else {
            panel.level = .normal
            floatCheckbox.state = .off
        }
    }

    @IBAction func handleResetButton(_ sender: Any) {
        resignFirstResponders()
        calcTime()
    }

    @IBAction func handleHoursStepper(_ sender: NSStepper) {
        hours = sender.integerValue
    }
    @IBAction func handleMinuteStepper(_ sender: NSStepper) {
        minutes = sender.integerValue

    }
    @IBAction func handleSecondsStepper(_ sender: NSStepper) {
        seconds = sender.integerValue
    }
    @IBAction func handleFloatCheckbox(_ sender: NSButton) {
        switch sender.state {

        case .on:
            floatWindow = true
        case .off:
            floatWindow = false

        default:
            print("Unknown switch state")
        }
    }
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

}
extension ViewController: NSControlTextEditingDelegate {
    func controlTextDidEndEditing(_ notification: Notification) {
        guard  let textField = notification.object as? NSTextField   else {
            print("can't get text field")
            return
        }
        switch textField {
        case hoursField:
            hours = Int(textField.stringValue) ?? 0
        case minutesField:
            minutes = Int(textField.stringValue) ?? 0
        case secondsField:
            seconds = Int(textField.stringValue) ?? 0
        default:
            print("can't get text field")
        }
    }
}


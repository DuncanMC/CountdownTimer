//
//  ViewController.swift
//  CountdownTimer
//
//  Created by Duncan Champney on 11/16/20.
//  Copyright © 2020 Duncan Champney. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    @IBOutlet weak var totalTimeField: NSTextField!

    @IBOutlet weak var hoursField: NSTextField!
    @IBOutlet weak var minutesField: NSTextField!
    @IBOutlet weak var secondsField: NSTextField!

    @IBOutlet weak var hoursStepper: NSStepper!
    @IBOutlet weak var minutesStepper: NSStepper!
    @IBOutlet weak var secondsStepper: NSStepper!

    @IBOutlet weak var startButton: NSButton!

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
            calcTime()
        }
    }

    var minutes: Int = 0 {
        didSet {
            minutesStepper.integerValue = minutes
            minutesField.stringValue = String(format: "%02d", minutesStepper.integerValue)
            calcTime()
        }
    }

    var seconds: Int = 0 {
        didSet {
            secondsStepper.integerValue = seconds
            secondsField.stringValue = String(format: "%02d", secondsStepper.integerValue)
            calcTime()
        }
    }
    func calcTime() {
        timeRemaining = Double(hours * 3600 + minutes * 60 + seconds)
    }

    override func viewDidLoad() {
        view.wantsLayer = true
        super.viewDidLoad()
        hours = 0
        minutes = 2
        seconds = 0

        // Do any additional setup after loading the view.
    }

    func resignFirstResponders() {
        hoursField.resignFirstResponder()
        minutesField.resignFirstResponder()
        secondsField.resignFirstResponder()
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


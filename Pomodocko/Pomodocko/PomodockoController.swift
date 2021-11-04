//
//  PomodockoController.swift
//  Pomodocko
//
//  Created by Elijah Sawyers on 11/3/21.
//

import Cocoa

class PomodockoController: NSObject {

    @objc dynamic var timer: PomodoroTimer
    var observer: NSKeyValueObservation?

    override init() {
        timer = PomodoroTimer()
        super.init()
        setAppIcon(minutes: 25, seconds: 0)
        observer = observe(\.timer.iterations) { [unowned self] _, _ in
            self.setAppIcon(minutes: self.timer.minutes, seconds: self.timer.seconds)
        }
    }

    private func setAppIcon(minutes: Int, seconds: Int) {
        NSApplication.shared.applicationIconImage = AppIconFactory.createIcon(withImagesNamed: [
            "clock",
            "\(minutes)_minutes",
            "\(seconds)_seconds",
            "lines_through_digits"
        ])
    }

    // MARK: - User Intent[s]

    @objc func resumeOrPauseTimer() {
        if timer.isPaused {
            timer.start()
        } else {
            timer.stop()
        }
    }

}

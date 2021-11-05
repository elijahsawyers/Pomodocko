//
//  PomodockoController.swift
//  Pomodocko
//
//  Created by Elijah Sawyers on 11/3/21.
//

import Cocoa

/// Controls setting the app icon, handling user intents, badging the app icon, and posting notifictations. The "brains" of the app.
class PomodockoController: NSObject {

    // MARK: - Private Instance Var[s]

    /// Stores the observer of changes to the pomodoro timer's iterations and completed pomodoros.
    private var observers: Set<NSKeyValueObservation>

    // MARK: - Public Instance Var[s]

    /// Pomodoro timer.
    @objc dynamic private(set) var timer: PomodoroTimer

    // MARK: - Initializer[s] and Deinitializer

    override init() {
        observers = []
        timer = PomodoroTimer()
        super.init()
        setAppIcon(minutes: timer.minutes, seconds: timer.seconds)
        setAppBadge(to: timer.completedPomodoros)

        // Respond to changes to the number of iterations left in the cycle (break or focus).
        observers.insert(observe(\.timer.iterations) { [unowned self] _, _ in
            self.setAppIcon(minutes: self.timer.minutes, seconds: self.timer.seconds)
        })

        // Respond to changes to the number of completed pomodoro cycles.
        observers.insert(observe(\.timer.completedPomodoros) { [unowned self] _, _ in
            self.setAppBadge(to: self.timer.completedPomodoros)
        })
    }

    deinit {
        for observer in observers {
            observer.invalidate()
        }
    }

    // MARK: - Private Instance Method[s]

    /// Change the app's icon to display the minutes and seconds remaining in the pomodoro cycle (focus or break).
    private func setAppIcon(minutes: Int, seconds: Int) {
        NSApplication.shared.applicationIconImage = AppIconFactory.createIcon(withImagesNamed: [
            "clock",
            "\(minutes)_minutes",
            "\(seconds)_seconds",
            "lines_through_digits",
            timer.state == .inFocus ? "focus" : "break"
        ])
    }

    /// Change the app's badge number.
    private func setAppBadge(to value: Int) {
        NSApplication.shared.dockTile.badgeLabel = "\(value)"
    }

    // MARK: - User Intent[s] (Target-Actions)

    /// If the timer is running, pause it; if the timer is paused, start it.
    @objc func startOrPauseTimer() {
        if timer.isPaused {
            timer.start()
        } else {
            timer.stop()
        }
    }

    /// Reset the current timer, which reverts the state back to focus mode.
    @objc func resetTimer() {
        timer.reset()
    }

    /// Skip the break timer, which reverts the state back to focus mode.
    @objc func skipBreak() {
        timer.reset()
    }

    /// Update the focus interval, in minutes, based on the menu item selected in the Dock's menu.
    @objc func setFocusMinutes(sender: NSMenuItem) {
        guard let focusMinutes = PomodoroTimer.FocusMinutes(rawValue: sender.tag) else { return }
        timer.focusMinutes = focusMinutes
        timer.reset()
    }

    /// Update the break interval, in minutes, based on the menu item selected in the Dock's menu.
    @objc func setBreakMinutes(sender: NSMenuItem) {
        guard let breakMinutes = PomodoroTimer.BreakMinutes(rawValue: sender.tag) else { return }
        timer.breakMinutes = breakMinutes
        timer.reset()
    }

}

//
//  PomodockoController.swift
//  Pomodocko
//
//  Created by Elijah Sawyers on 11/3/21.
//

import Cocoa
import UserNotifications

/// Controls setting the app icon, handling user intents, badging the app icon, and posting notifictations. The "brains" of the app.
class PomodockoController: NSObject {

    // MARK: - Private Type[s]

    /// A simple data structure to hold all of the needed user default keys.
    ///
    /// There are three possible keys - focus minutes, break minutes, and completed pomodoros (for the day).
    private struct UserDefaultsKeys {
        static let focusMinutes = "POMODOCKO_FOCUS_MINUTES"
        static let breakMinutes = "POMODOCKO_BREAK_MINUTES"
        static var completedPomodoros: String {
            "POMODOCKO_COMPLETED_POMODOROS_\(Date())"
        }
    }

    // MARK: - Private Instance Var[s]

    /// Stores the observer of changes to the pomodoro timer's iterations and completed pomodoros.
    private var observers: Set<NSKeyValueObservation>

    // MARK: - Public Instance Var[s]

    /// Pomodoro timer.
    @objc dynamic private(set) var timer: PomodoroTimer

    // MARK: - Initializer[s] and Deinitializer

    override init() {
        // Grab user defaults for focus minutes, break minutes, and the completed pomodoro cycles for the day.
        let focusMinutes = (UserDefaults.standard.value(forKey: UserDefaultsKeys.focusMinutes) as? Int) ?? 0
        let breakMinutes = (UserDefaults.standard.value(forKey: UserDefaultsKeys.breakMinutes) as? Int) ?? 0
        let completedPomodoros = (UserDefaults.standard.value(forKey: UserDefaultsKeys.completedPomodoros) as? Int) ?? 0

        // Set instance var[s].
        observers = []
        timer = PomodoroTimer(
            completedPomodoros: completedPomodoros,
            focusMinutes: PomodoroTimer.FocusMinutes(rawValue: focusMinutes) ?? PomodoroTimer.defaultFocusMinutes,
            breakMinutes: PomodoroTimer.BreakMinutes(rawValue: breakMinutes) ?? PomodoroTimer.defaultBreakMinutes
        )

        // Can't forget to call super's init.
        super.init()

        // Set the initial state of the app.
        setAppIconToTimeRemainingInCycle()
        setAppBadgeToCompletedPomodoros()

        // Respond to changes to the number of iterations left in the cycle (break or focus).
        observers.insert(observe(\.timer.iterations) { [unowned self] _, _ in
            if self.timer.iterations == 0 { self.notifyUserThatStateChanged() }
            self.setAppIconToTimeRemainingInCycle()
        })

        // Respond to changes to the number of completed pomodoro cycles.
        observers.insert(observe(\.timer.completedPomodoros) { [unowned self] _, _ in
            UserDefaults.standard.set(self.timer.completedPomodoros, forKey: UserDefaultsKeys.completedPomodoros)
            self.setAppBadgeToCompletedPomodoros()
        })
    }

    deinit {
        for observer in observers {
            observer.invalidate()
        }
    }

    // MARK: - Private Instance Method[s]

    /// Change the app's icon to display the minutes and seconds remaining in the pomodoro cycle (focus or break).
    private func setAppIconToTimeRemainingInCycle() {
        NSApplication.shared.applicationIconImage = AppIconFactory.createIcon(withImagesNamed: [
            "clock",
            "\(timer.minutes)_minutes",
            "\(timer.seconds)_seconds",
            "lines_through_digits",
            timer.state == .inFocus ? "focus" : "break"
        ])
    }

    /// Change the app's badge number to the number of completed pomodoros in the day.
    private func setAppBadgeToCompletedPomodoros() {
        NSApplication.shared.dockTile.badgeLabel = "\(timer.completedPomodoros)"
    }

    // Post a notification letting the user know that the state has changed, indicating timer end.
    private func notifyUserThatStateChanged() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        if timer.state == .inFocus {
            content.title = "It's time to take a break!"
            content.body = "Rest, relax, and step away from your computer for a little bit ????"
            content.categoryIdentifier = NotificationCategory.startOfBreak.rawValue
        } else {
            content.title = "It's time to focus!"
            content.body = "Today, you've completed \(timer.completedPomodoros) focus cycle\(timer.completedPomodoros > 1 ? "s" : "")! Keep it going! ????"
            content.categoryIdentifier = NotificationCategory.startOfFocus.rawValue
        }
        content.sound = UNNotificationSound.default

        center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)) { error in
            // TODO: Handle any thrown errors.
        }
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
        timer.start()
    }

    /// Update the focus interval, in minutes, based on the menu item selected in the Dock's menu.
    @objc func setFocusMinutes(sender: NSMenuItem) {
        guard let focusMinutes = PomodoroTimer.FocusMinutes(rawValue: sender.tag) else { return }
        UserDefaults.standard.set(focusMinutes.rawValue, forKey: UserDefaultsKeys.focusMinutes)
        timer.focusMinutes = focusMinutes
        timer.reset()
    }

    /// Update the break interval, in minutes, based on the menu item selected in the Dock's menu.
    @objc func setBreakMinutes(sender: NSMenuItem) {
        guard let breakMinutes = PomodoroTimer.BreakMinutes(rawValue: sender.tag) else { return }
        UserDefaults.standard.set(breakMinutes.rawValue, forKey: UserDefaultsKeys.breakMinutes)
        timer.breakMinutes = breakMinutes
        timer.reset()
    }

}

//
//  PomodoroTimer.swift
//  Pomodocko
//
//  Created by Elijah Sawyers on 11/3/21.
//

import Foundation

/// Allows basic pomodoro timer functionality.
class PomodoroTimer: NSObject {

    // MARK: - Public Type[s]

    /// State of the pomodoro timer.
    ///
    /// There are two possible states -  on break, or in focus.
    @objc enum State: Int {
        case onBreak, inFocus
    }

    /// Pomodoro timer "focus" durations, in minutes.
    ///
    /// There are four possible durations - twenty-five, thrity, forty-five, or fifty minutes.
    @objc enum FocusMinutes: Int {
        case twentyFive = 25, thirty = 30, fortyFive = 45, fifty = 50
    }

    /// Pomodoro timer "break" durations, in minutes.
    ///
    /// There are two possible durations - five or ten minutes.
    @objc enum BreakMinutes: Int {
        case five = 5, ten = 10
    }

    // MARK: - Private Instance Var[s]

    /// Retains a reference to the active timer.
    private var timer: Timer?

    // MARK: - Public Instance Var[s]

    /// How many iterations (seconds) are left in the pomodoro cycle.
    @objc dynamic lazy private(set) var iterations  = focusMinutes.rawValue * 60

    /// The current state of the timer.
    @objc dynamic private(set) var state: State = .inFocus

    /// The number of pomodoros that have been completed during the day.
    private(set) var completedPomodoros = 0

    /// How long, in minutes, the "focus" time is.
    var focusMinutes: FocusMinutes = .twentyFive

    /// How long, in minutes, the "break" time is.
    var breakMinutes: BreakMinutes = .five

    /// Whether or not the timer is running.
    var isPaused: Bool { timer == nil }

    /// How many seconds are left in the current minute of the pomodoro cycle.
    var seconds: Int { iterations % 60 }

    /// How many minutes are left in the current minute of the pomodoro cycle.
    var minutes: Int { iterations / 60 }

    // MARK: - Private Instance Method[s]

    /// Create a new timer.
    private func createTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            // Decrement the number of seconds left in this cycle (focus or break).
            self.iterations -= 1

            // Change state if the cycle (focus or break) is over.
            if self.iterations == 0 { self.toggleState() }
        }
    }

    /// Toggle the state of the timer - if in focus, switch to break; if in break, switch to focus.
    ///
    /// - Note: This increments the number of completed pomodoro cycles when toggling to break.
    private func toggleState() {
        stop()
        if state == .inFocus {
            completedPomodoros += 1
            state = .onBreak
            iterations = breakMinutes.rawValue * 60
        } else {
            state = .inFocus
            iterations = focusMinutes.rawValue * 60
        }
    }

    // MARK: - Public Instance Method[s]

    /// Stop the current timer that's running, if it is running.
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    /// Create a new timer, if needed, and start running it.
    func start() {
        if let timer = timer, timer.isValid {
            timer.fire()
        } else {
            createTimer()
            start()
        }
    }

    /// Reset the current timer, which reverts the state back to focus mode.
    func reset() {
        stop()
        state = .inFocus
        iterations = focusMinutes.rawValue * 60
    }

}

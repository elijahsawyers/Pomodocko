//
//  PomodoroTimer.swift
//  Pomodocko
//
//  Created by Elijah Sawyers on 11/3/21.
//

import Foundation

class PomodoroTimer: NSObject {

    // MARK: - Public Type[s]

    /// State of the Pomodoro Timer.
    ///
    /// There are two possible states -  on break, or in focus.
    @objc enum State: Int {
        case onBreak, inFocus
    }

    // MARK: - Public Static Var[s]

    /// How long the default "focus" time is.
    static let focusMinutes = 25

    /// How long the defaul "break" time is.
    static let breakMinutes = 5

    // MARK: - Public Instance Var[s]

    /// The number of pomodoros that have been completed during the day.
    var completedPomodoros = 0

    /// Retains a reference to the active Pomodoro Timer.
    var timer: Timer?

    /// Whether or not the timer is running.
    var isPaused: Bool { timer == nil }

    /// The current state of the timer.
    @objc dynamic var state: State = .inFocus

    /// How many iterations (seconds) are left in the pomodoro cycle.
    @objc dynamic var iterations  = focusMinutes * 60

    /// How many seconds are left in the current minute of the pomodoro cycle.
    var seconds: Int { iterations % 60 }

    /// How many minutes are left in the current minute of the pomodoro cycle.
    var minutes: Int { iterations / 60 }

    // MARK: - Public Instance Method[s]

//    func changeState(to: State) {
//
//    }

    // MARK: - Private Instance Method[s]

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func start() {
        if let timer = timer, timer.isValid {
            timer.fire()
        } else {
            createTimer()
            start()
        }
    }

    private func createTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            // Increment the number of seconds that've been completed on this pomodoro cycle.
            self.iterations -= 1

            // Change state if the pomodoro cycle is over.
            if self.iterations == 0 {
                self.timer?.invalidate()
                self.timer = nil
                if self.state == .inFocus {
                    self.completedPomodoros += 1
                    self.state = .onBreak
                    self.iterations = PomodoroTimer.breakMinutes * 60
                } else {
                    self.state = .inFocus
                    self.iterations = PomodoroTimer.focusMinutes * 60
                }
            }
        }
    }

}

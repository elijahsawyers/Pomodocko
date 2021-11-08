//
//  PomodockoController+UNUserNotificationCenterDelegate.swift
//  Pomodocko
//
//  Created by Elijah Sawyers on 11/8/21.
//

import Cocoa
import UserNotifications

/// Extend PomodockoController to be the UNUserNotificationCenter delegate.
extension PomodockoController: UNUserNotificationCenterDelegate {

    /// Notification actions on the UNUserNotificationCenter.
    ///
    /// There are two possible actions - start timer and skip break.
    enum NotificationAction: String {
        case startTimer = "Start timer", skipBreak = "Skip break"
    }

    /// Notification categories on the UNUserNotificationCenter.
    ///
    /// There are two possible categories - start of break and start of focus.
    enum NotificationCategory: String {
        case startOfBreak, startOfFocus
    }

    /// Responds to notification actions.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        guard let pomodockoController = (NSApplication.shared.delegate as? AppDelegate)?.pomodockoController else { return }

        switch response.actionIdentifier {
        case NotificationAction.startTimer.rawValue:
            pomodockoController.startOrPauseTimer()
        case NotificationAction.skipBreak.rawValue:
            pomodockoController.skipBreak()
        default:
            break
        }
    }

}

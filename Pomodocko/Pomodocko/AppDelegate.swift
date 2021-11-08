//
//  AppDelegate.swift
//  Pomodocko
//
//  Created by Elijah Sawyers on 11/3/21.
//

import Cocoa
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {

    var pomodockoController: PomodockoController?

    // MARK: - Application Launch

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        pomodockoController = PomodockoController()

        // Grab the current notification center and set its delegate.
        let center = UNUserNotificationCenter.current()
        center.delegate = pomodockoController

        // Request permission to badge the app, play sounds, and present notifications.
        center.requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
            // TODO: Handle any thrown errors.
            // TODO: Alert user the app won't work properly w/out notifications.
        }

        // Define custom actions on the notifications.
        let startTimerAction = UNNotificationAction(
            identifier: PomodockoController.NotificationAction.startTimer.rawValue,
            title: PomodockoController.NotificationAction.startTimer.rawValue,
            options: .authenticationRequired
        )
        let skipBreakAction = UNNotificationAction(
            identifier: PomodockoController.NotificationAction.skipBreak.rawValue,
            title: PomodockoController.NotificationAction.skipBreak.rawValue,
            options: .authenticationRequired
        )

        let startOfBreakCategory = UNNotificationCategory(
            identifier: PomodockoController.NotificationCategory.startOfBreak.rawValue,
            actions: [startTimerAction, skipBreakAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        let startOfFocusCategory = UNNotificationCategory(
            identifier: PomodockoController.NotificationCategory.startOfFocus.rawValue,
            actions: [startTimerAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        center.setNotificationCategories([startOfBreakCategory, startOfFocusCategory])
    }

}

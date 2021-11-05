//
//  AppDelegate+DockMenu.swift
//  Pomodocko
//
//  Created by Elijah Sawyers on 11/5/21.
//

import Cocoa

/// Extend the AppDelegate to add dock menu functionality.
///
/// The dock menu will appear as:
///
/// ------------------------------
/// "▶️ Start timer" or "⏸ Pause timer"
/// "⏩ Skip break"
/// ------------------------------
/// "💡 Focus interval"
///    > 25 minutes
///    > 30 minutes
///    > 45 minutes
///    > 50 minutes
/// "💤 Break interval"
///    > 5 minutes
///    > 10 minutes
/// ------------------------------
/// "⚠️ Reset timer"
/// ------------------------------
///
extension AppDelegate {

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        guard let pomodockoController = pomodockoController else { return nil }
        let menu = NSMenu()

        // MARK: - Menu item to start or pause pomodoro timer

        let startOrPauseTimer = NSMenuItem(
            title: pomodockoController.timer.isPaused ? "▶️ Start timer" : "⏸ Pause timer",
            action: #selector(PomodockoController.startOrPauseTimer),
            keyEquivalent: ""
        )
        startOrPauseTimer.target = pomodockoController

        // MARK: - Menu item to skip the break the pomodoro timer

        let skipBreakTimer = NSMenuItem(
            title: "⏩ Skip break",
            action: #selector(PomodockoController.skipBreak),
            keyEquivalent: ""
        )
        skipBreakTimer.target = pomodockoController

        // MARK: -  Submenu to set the pomodoro focus timer interval

        let focusInterval = NSMenuItem()
        let focusIntervalSubmenu = NSMenu()
        let twentyFiveMinuteFocus = NSMenuItem()
        let thirtyMinuteFocus = NSMenuItem()
        let fortyFiveMinuteFocus = NSMenuItem()
        let fiftyMinuteFocus = NSMenuItem()

        func initFocusMinutes(menuItem: NSMenuItem, withMinutes minutes: PomodoroTimer.FocusMinutes) {
            menuItem.target = pomodockoController
            menuItem.action = #selector(PomodockoController.setFocusMinutes(sender:))
            menuItem.title = "\(minutes.rawValue) minutes"
            menuItem.tag = minutes.rawValue
            menuItem.state = pomodockoController.timer.focusMinutes == minutes ? .on : .off
        }

        focusInterval.title = "💡 Focus interval"
        focusInterval.submenu = focusIntervalSubmenu

        initFocusMinutes(menuItem: twentyFiveMinuteFocus, withMinutes: .twentyFive)
        initFocusMinutes(menuItem: thirtyMinuteFocus, withMinutes: .thirty)
        initFocusMinutes(menuItem: fortyFiveMinuteFocus, withMinutes: .fortyFive)
        initFocusMinutes(menuItem: fiftyMinuteFocus, withMinutes: .fifty)

        focusIntervalSubmenu.addItem(twentyFiveMinuteFocus)
        focusIntervalSubmenu.addItem(thirtyMinuteFocus)
        focusIntervalSubmenu.addItem(fortyFiveMinuteFocus)
        focusIntervalSubmenu.addItem(fiftyMinuteFocus)

        // MARK: - Submenu to set the pomodoro break timer interval

        let breakInterval = NSMenuItem()
        let breakIntervalSubmenu = NSMenu()
        let fiveMinuteBreak = NSMenuItem()
        let tenMinuteBreak = NSMenuItem()

        func initBreakMinutes(menuItem: NSMenuItem, withMinutes minutes: PomodoroTimer.BreakMinutes) {
            menuItem.target = pomodockoController
            menuItem.action = #selector(PomodockoController.setBreakMinutes(sender:))
            menuItem.title = "\(minutes.rawValue) minutes"
            menuItem.tag = minutes.rawValue
            menuItem.state = pomodockoController.timer.breakMinutes == minutes ? .on : .off
        }

        breakInterval.title = "💤 Break interval"
        breakInterval.submenu = breakIntervalSubmenu

        initBreakMinutes(menuItem: fiveMinuteBreak, withMinutes: .five)
        initBreakMinutes(menuItem: tenMinuteBreak, withMinutes: .ten)

        breakIntervalSubmenu.addItem(fiveMinuteBreak)
        breakIntervalSubmenu.addItem(tenMinuteBreak)

        // MARK: - Menu item to reset the pomodoro timer

        let resetTimer = NSMenuItem(
            title: "⚠️ Reset timer",
            action: #selector(PomodockoController.resetTimer),
            keyEquivalent: ""
        )
        resetTimer.target = pomodockoController

        // MARK: - Add the item[s] to the menu.

        menu.addItem(startOrPauseTimer)
        if pomodockoController.timer.state == .onBreak { menu.addItem(skipBreakTimer) }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(focusInterval)
        menu.addItem(breakInterval)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(resetTimer)

        return menu
    }

}

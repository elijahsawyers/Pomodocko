//
//  AppDelegate.swift
//  Pomodocko
//
//  Created by Elijah Sawyers on 11/3/21.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    var pomodockoController: PomodockoController?

    // MARK: - Application Launch

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        pomodockoController = PomodockoController()
    }

    // MARK: - Dock Menu

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        guard let pomodockoController = pomodockoController else { return nil }

        // Initialize the menu and its item[s].
        let menu = NSMenu()
        let resumeOrPause = NSMenuItem(
            title: pomodockoController.timer.isPaused ? "Start timer" : "Pause timer",
            action: #selector(PomodockoController.resumeOrPauseTimer),
            keyEquivalent: ""
        )
        resumeOrPause.target = pomodockoController

        // Add the item[s] to the menu.
        menu.addItem(resumeOrPause)

        return menu
    }

}

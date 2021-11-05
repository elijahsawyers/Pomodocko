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

}

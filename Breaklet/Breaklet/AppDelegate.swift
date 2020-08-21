//
//  AppDelegate.swift
//  Breaklet 2020
//
//  Created by Peter Luo on 2020/5/28.
//  Copyright © 2020 Peter Luo. All rights reserved.
//


import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	// quit app when last window closed
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
    func applicationDidFinishLaunching(_ notification: Notification) {
        ScoreBoard.shared.loadFromUserDefaultsIfAvailible()
    }
    @IBAction func showScoreBoard(_ sender: NSMenuItem) {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "Toggle Score Board")))
    }
}

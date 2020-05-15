//
//  AppDelegate.swift
//  MySensors
//
//  Created by An Long on 25/09/2016.
//  Copyright © 2016 An Long. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    @IBOutlet weak var window: NSWindow!
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        do {
            try SMCKit.open()
        } catch {
            let alert = NSAlert()
            alert.messageText = "initailize SMC failed!"
            alert.runModal()
            NSApplication.shared.terminate(self)
        }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        let icon = NSImage(named: "ic_memory")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = NSMenu()
        statusItem.menu?.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        let _ = SMCKit.close()
    }

    @objc func onQuitMenuItemClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

    func menuWillOpen(_ menu: NSMenu) {
        let sensorsData = getSensorsData()

        let myStyle = NSMutableParagraphStyle()
        let labelWidth =  CGFloat(250)
        myStyle.tabStops = [NSTextTab(textAlignment: .left, location: 0.0, options: [:]),
          NSTextTab(textAlignment: .right, location: labelWidth, options: [:])]
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.right

        for data in sensorsData {
            if data.items.count == 0 {
                continue
            }
            let m = NSMenuItem()
            m.title = "\(data.title):"
            menu.addItem(m)
            for item in data.items {
                let m = NSMenuItem()

                let content = "\(item.0)\t\(item.1)"
                let attributedString = NSMutableAttributedString(string: content)
                attributedString.addAttribute(.paragraphStyle, value: myStyle, range: NSRange(location: 0, length: content.count-1))


                m.attributedTitle = attributedString
                menu.addItem(m)
            }
            menu.addItem(NSMenuItem.separator())
        }

        let m = NSMenuItem()
        m.title = "Quit"
        m.action = #selector(onQuitMenuItemClicked)
        menu.addItem(m)
    }

    func getSensorsData() -> Array<SensorsData> {
        var result: Array<SensorsData> = []


        do {
            let temps = try SMCKit.allKnownTemperatureSensors()
            var items: Array<(String, String)> = []

            for temp in temps {
                items.append((temp.name, "\(try SMCKit.temperature(temp.code)) °C"))
            }
            items = items.sorted(by: {$0.1 > $1.1})
            result.append(SensorsData(title: "Temperature", items: items))
        } catch {
            // pass
        }

        do {
            let fans = try SMCKit.allFans()
            var items: Array<(String, String)> = []
            for fan in fans {
                items.append((fan.name, "\(try SMCKit.fanCurrentSpeed(fan.id)) rpm"))
            }
            result.append(SensorsData(title: "Fan Speed", items: items))
        } catch {
            // pass
        }

        return result
    }

    func menuDidClose(_ menu: NSMenu) {
        menu.removeAllItems()
    }
}

struct SensorsData {
    var title: String
    var items: Array<(String, String)>
}

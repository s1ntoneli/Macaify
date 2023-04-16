//
//  XCAChatGPTMacApp.swift
//  XCAChatGPTMac
//
//  Created by Alfian Losari on 04/02/23.
//

import SwiftUI
import AppKit

@main
struct XCAChatGPTMacApp: App {
    @Environment(\.scenePhase) private var scenePhase
//    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var vm = CommandStore.shared.menuViewModel
    @StateObject var commandStore = CommandStore.shared
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        windowView
//        menuView
    }

    private var windowView: some Scene {
        WindowGroup {
            MacContentView()
                .environmentObject(commandStore)
                .ignoresSafeArea(.all)
                .onAppear {
                    
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
        .windowStyle(.hiddenTitleBar) // Hide the title bar
        .onChange(of: scenePhase) { s in
            switch s {
            case .background:
                print("background")

            case .inactive:
                print("inactive")
            case .active:
                print("active")
                hideTitleBar()
                
            @unknown default:
                print("default")
            }
        }
    }
    
    private var menuView: some Scene {
        MenuBarExtra("XCA ChatGPT", image: "icon") {
            VStack(spacing: 0) {
                HStack {
                    Text("XCA ChatGPT")
                        .font(.title)
                    Spacer()

                    Button {
                        guard !vm.isInteractingWithChatGPT else { return }
                        vm.clearMessages()
                    } label: {
                        Image(systemName: "trash")
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 24))
                    }
                    .buttonStyle(.borderless)

                    Button {
                        exit(0)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 24))
                    }

                    .buttonStyle(.borderless)
                }
                .padding()

                ContentView(vm: vm)
            }
            .frame(width: 480, height: 576)
        }.menuBarExtraStyle(.window)
    }

    func hideTitleBar() {
        guard let window = NSApplication.shared.windows.first else {  return }
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.standardWindowButton(.documentIconButton)?.isHidden = true
        window.titleVisibility = .hidden
        window.toolbar = nil
        window.isReleasedWhenClosed = false
        
        let screenWidth: CGFloat = NSScreen.main?.frame.width ?? 0
        let screenHeight: CGFloat = NSScreen.main?.frame.height ?? 0
        let height: CGFloat = 500
        let width: CGFloat = height / 0.618
        let y: CGFloat = (screenHeight - height) / 2
        let x: CGFloat = (screenWidth - width) / 2
        print("height \(screenHeight)")
        window.setFrame(CGRect(x: x, y: y, width: width, height: height), display: true)
        window.makeKeyAndOrderFront(nil)

        window.delegate = appDelegate
    }
}

@MainActor
final class AppState: ObservableObject {
    init() {
        HotKeyManager.initHotKeys()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        print("application")
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        print("applicationShouldTerminateAfterLastWindowClosed")
        return false
    }
    func applicationDidReceiveMemoryWarning(_ application: NSApplication) {
        print("log-DidReceiveMemoryWarning")
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        print("windowShouldClose")
        sender.orderOut(self)
        return false
    }
}
//
//import Cocoa
//
//class CustomWindow: NSWindow {
//    override func keyDown(with event: NSEvent) {
//        NotificationCenter.default.post(name: .keyPressed, object: event)
//    }
//}
//
//extension Notification.Name {
//    static let keyPressed = Notification.Name("keyPressed")
//}
//
//class AppDelegate: NSObject, NSApplicationDelegate {
//    var window: NSWindow!
//
//    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        let contentView = TContentView()
//
//        window = CustomWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 300), styleMask: [], backing: .buffered, defer: false)
//        window.center()
//        window.setFrameAutosaveName("Main Window1")
//        window.setFrame(NSRect(x: 0, y: 0, width: 1000, height: 1000), display: true)
//        window.contentView = NSHostingView(rootView: contentView)
//        window.makeKeyAndOrderFront(nil)
//    }
//}
//
////import SwiftUI
//
//struct TContentView: View {
//    @State private var key: String = ""
//
//    var body: some View {
//        VStack {
//            Text("Hello, World!")
//            Text("Key pressed: \(key)")
//        }.onReceive(NotificationCenter.default.publisher(for: .keyPressed)) { event in
//            if let event = event.object as? NSEvent {
//                key = event.characters!
//            }
//        }
//        .frame(width: 1000, height: 1000)
//    }
//}

//
//  XCAChatGPTMacApp.swift
//  XCAChatGPTMac
//
//  Created by Alfian Losari on 04/02/23.
//

import SwiftUI
import AppKit
import FirebaseCore
import Sparkle

@main
struct XCAChatGPTMacApp: App {
    @Environment(\.scenePhase) private var scenePhase
//    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

//    @StateObject var vm = CommandStore.shared.menuViewModel
    @StateObject var vm = ConversationViewModel.shared
    @StateObject private var appState = AppState()
    @StateObject private var typingInPlace = TypingInPlace.shared
    @State var commandKeyDown: Bool = false
    @State var commandKeyDownTimestamp: TimeInterval = 0
    @State var commandLocalMonitor = KeyMonitor(.command)
    @State var globalMonitor = KeyMonitorManager.shared
    @StateObject private var emojiViewModel = EmojiPickerViewModel()
    @AppStorage("selectedLanguage") var userDefaultsSelectedLanguage: String?

    let globalConfig = GlobalConfig()
    
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }

    var body: some Scene {
         windowView
//        menuView
    }

    private var windowView: some Scene {
        WindowGroup {
            MacContentView()
                .environmentObject(vm)
                .environmentObject(globalConfig)
                .environmentObject(emojiViewModel)
                .environment(\.locale, .init(identifier: userDefaultsSelectedLanguage ?? "en"))
                .ignoresSafeArea(.all)
                .onAppear {
                    commandLocalMonitor.handler = {
                        print("Command key was held down for 1 second")
                        withAnimation {
                            globalConfig.showShortcutHelp = true
                        }
                    }
                    commandLocalMonitor.onKeyUp = {
                        withAnimation {
                            globalConfig.showShortcutHelp = false
                        }
                    }
                    commandLocalMonitor.start()
                    globalMonitor.start()
                    globalMonitor.updateModifier(appShortcutKey())
                }
                .onDisappear {
                    commandLocalMonitor.stop()
                    globalMonitor.stop()
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
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
    @State private var dots = ""
    @State var menuAnimateTimer: Timer? = nil

    @available(macOS 13.0, *)
    private var menuView: some Scene {
        MenuBarExtra {
            if TypingInPlace.shared.typing {
                Button {
                    TypingInPlace.shared.interupt()
                } label: {
                    Text("Stop ")
                    Image(systemName: "stop.circle")
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 24))
                }
                .buttonStyle(.borderless)
            }
            Button {
                if let url = URL(string: "https://macaify.com") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Text("Website")
            }
            .buttonStyle(.borderless)
            Button {
                if let url = URL(string: "https://twitter.com/macaify") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Text("Twitter")
            }
            .buttonStyle(.borderless)
            Button {
                if let url = URL(string: "mailto:macaify@gokoding.com") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Text("Feedback")
            }
            .buttonStyle(.borderless)
            
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Text("Quit")
            }
            .buttonStyle(.borderless)
        } label: {
            if TypingInPlace.shared.typing {
                Text("Typing\(dots)🖌️")
                    .onAppear {
                        // Start the timer when the view appears
                        self.menuAnimateTimer = Timer.scheduledTimer(withTimeInterval: 1.0/3.0, repeats: true) { timer in
                            withAnimation {
                                // Update the dots every time the timer fires
                                switch dots.count {
                                case 0:
                                    dots = "."
                                case 1:
                                    dots = ".."
                                case 2:
                                    dots = "..."
                                case 3:
                                    dots = ""
                                default:
                                    break
                                }
                            }
                        }
                    }
                    .onDisappear {
                        self.menuAnimateTimer?.invalidate()
                        self.menuAnimateTimer = nil
                    }
            }
            else {
                Image("menubar")
                    .resizable()
                    .frame(width: 8)
            }
        }
        .menuBarExtraStyle(.menu)
    }
//
//    private var menuView: some Scene {
//        MenuBarExtra("XCA ChatGPT", image: "icon") {
//            VStack(spacing: 0) {
//                HStack {
//                    Text("XCA ChatGPT")
//                        .font(.title)
//                    Spacer()
//
//                    Button {
//                        guard !vm.isInteractingWithChatGPT else { return }
//                        vm.clearMessages()
//                    } label: {
//                        Image(systemName: "trash")
//                            .symbolRenderingMode(.multicolor)
//                            .font(.system(size: 24))
//                    }
//                    .buttonStyle(.borderless)
//
//                    Button {
//                        exit(0)
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .symbolRenderingMode(.multicolor)
//                            .font(.system(size: 24))
//                    }
//
//                    .buttonStyle(.borderless)
//                }
//                .padding()
//
//                ContentView(vm: vm)
//            }
//            .frame(width: 480, height: 576)
//        }.menuBarExtraStyle(.window)
//    }

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
        DispatchQueue(label: "EmojiManager").async {
            EmojiManager.shared.emojis
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {

    func application(_ application: NSApplication, open urls: [URL]) {
        print("application")
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        print("application will finish launching")
        NSApp.appearance = NSAppearance(named: .aqua)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("application did finish launching")
        FirebaseApp.configure()
        MenuBarManager.shared.setupMenus()
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
//        sender.orderOut(self)
//        sender.miniaturize(nil)
        NSApp.hide(nil)
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

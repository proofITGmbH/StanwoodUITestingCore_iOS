//
//  UITestingCoreListener.swift
//  StanwoodCore
//
//  Created by Tal Zion on 28/02/2018.
//

import Foundation

/// UITesting listner completion block for view changes
public typealias UITestingListenerCompletion = (_ item: UITestingCoreVersion) -> Void

/// Core listner contains event items for view changes.
/// A helper class for the UITesting tool
public class UITestingCoreListener: NSObject {
    
    /// Listener on/off switch
    public var shouldListen: Bool = true
    
    /// Listener completion block
    private var listiner: UITestingListenerCompletion?
    
    /// :nodoc:
    private var items = UITestingCoreVersion(version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "", windows: [])
    
    /// :nodoc:
    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(registerEvents(_:)), name: Notification.Name(rawValue: "com.stanwood.uitesting.didRecordUIElement"), object: nil)
    }
    
    /**
     Listen function will listen for view hierarchy changes events
     */
    public func listen(_ completion: @escaping UITestingListenerCompletion) {
        listiner = completion
    }
    
    /// :nodoc:
    @objc public func registerEvents(_ notification: Notification) {
        
        // Checking for event
        guard let dictionary = notification.object as? [String: String],
            let key = dictionary["key"],
            let windowString = dictionary["window"],
            let elementString = dictionary["element"],
            let text = dictionary["text"] else { return }
        
        // Creating a new element
        let element = UITestingCoreElement(key: key, text: text, element: elementString)
        
        // Checking for a current window
        if let index = items.index(forWindow: windowString) {
            var window = items.windows[index]
            window.elements.append(element)
            items.append(window)
        } else {
            let window = UITestingCoreWindow(window: windowString, elements: [element])
            items.append(window)
        }
        
        // Checking if listener should listen to events
        guard shouldListen else { return }
        
        // Listening
        listiner?(items)
    }
}

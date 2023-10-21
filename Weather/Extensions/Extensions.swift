//
//  Extensions.swift
//  Weather
//
//  Created by Dhruv on 10/2/23.
//

import UIKit
import Foundation

extension Double {
    func roundDouble() -> String {
        return String(format: "%.0f", self)
    }
    
    func roundFahrenheitDouble() -> String {
        let fahrenheit = (self * 9.0) / 5.0 + 32.0
        return String(format: "%.0f", fahrenheit)
    }
}

extension UIWindow {
    static var isLandscape: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isLandscape ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
}

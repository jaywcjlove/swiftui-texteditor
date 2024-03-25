//
//  SwiftUIView.swift
//  
//
//  Created by 王楚江 on 2024/3/25.
//

import SwiftUI

#if os(OSX)
import AppKit
public typealias FontHelper = NSFont
#elseif os(iOS)
import UIKit
public typealias FontHelper = UIFont
#endif

@propertyWrapper
struct Font {
    var value: FontHelper

    init(wrappedValue: FontHelper) {
        self.value = wrappedValue
    }

    var wrappedValue: FontHelper {
        get { value }
        set { value = newValue }
    }
}


extension TextEditorPlus {
    /// Set font size
    /// 
    /// ```swift
    /// TextEditorPlus(text: $text)
    ///    .font(.systemFont(ofSize: 24, weight: .regular))
    /// ```
    public func font(_ value: FontHelper) -> Self {
        var view = self
        view.font = value
        return view
    }
}

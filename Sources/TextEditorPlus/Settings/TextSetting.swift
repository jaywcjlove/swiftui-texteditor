//
//  SwiftUIView.swift
//  
//
//  Created by 王楚江 on 2024/3/25.
//

import SwiftUI


#if os(OSX)
    import AppKit
    public typealias ViewColor = NSColor
#elseif os(iOS)
    import UIKit
    public typealias ViewColor = UIColor
#endif

fileprivate struct TextViewIsEditable: EnvironmentKey {
    static var defaultValue: Bool = true
}
fileprivate struct TextViewInsetPadding: EnvironmentKey {
    static var defaultValue: CGFloat = 18
}
fileprivate struct TextViewBackgroundColor: EnvironmentKey {
    static var defaultValue: ViewColor?
}

fileprivate struct TextViewAttributedString: EnvironmentKey {
    static var defaultValue: (NSMutableAttributedString) -> NSMutableAttributedString? = { _ in nil }
}

extension EnvironmentValues {
    /// Set whether it is editable.
    var textViewIsEditable: Bool {
        get { self[TextViewIsEditable.self] }
        set { self[TextViewIsEditable.self] = newValue }
    }
    /// Set padding insets.
    var textViewInsetPadding: CGFloat {
        get { self[TextViewInsetPadding.self] }
        set { self[TextViewInsetPadding.self] = newValue }
    }
    var textViewBackgroundColor: ViewColor? {
        get { self[TextViewBackgroundColor.self] }
        set { self[TextViewBackgroundColor.self] = newValue }
    }
    var textViewAttributedString: (NSMutableAttributedString) -> NSMutableAttributedString? {
        get { self[TextViewAttributedString.self] }
        set { self[TextViewAttributedString.self] = newValue }
    }
}

public enum TextViewComponent {
    /// Is the editor editable?
    case isEditable
    /// Set editor padding
    case insetPadding
    /// Set the editor background color.
    case backgroundColor
}

@available(iOS 13.0, macOS 10.15, *)
public extension View {
    /// Manipulate attributed strings with attributes such as visual styles, hyperlinks, or accessibility data for portions of the text.
    ///
    /// ```swift
    /// TextEditorPlus(text: $text)
    ///     .textSetting(isEditable, for: .isEditable)
    ///     .textViewAttributedString(action: { val in
    ///             let style = NSMutableParagraphStyle()
    ///             style.lineSpacing = 5
    ///             style.lineHeightMultiple = 1.2
    ///             val.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: val.length))
    ///             return val
    ///     })
    /// ````
    @ViewBuilder func textViewAttributedString(action: @escaping (NSMutableAttributedString) -> NSMutableAttributedString?) -> some View {
        environment(\.textViewAttributedString, action)
    }
    /// Sets the tint color for specific MarkdownView component.
    ///
    /// ```swift
    /// TextEditorPlus(text: $text)
    ///    .textSetting(isEditable, for: .isEditable)
    ///    .textSetting(25, for: .insetPadding)
    /// ```
    ///
    /// - Parameters:
    ///   - tint: The tint color to apply.
    ///   - component: The tintable component to apply the tint color.
    @ViewBuilder func textSetting<T>(_ value: T, for component: TextViewComponent) -> some View {
        switch component {
            case .isEditable:
                environment(\.textViewIsEditable, value as! Bool)
            case .insetPadding:
                environment(\.textViewInsetPadding, value as! CGFloat)
            case .backgroundColor:
                environment(\.textViewBackgroundColor, value as! ViewColor?)
        }
    }
}

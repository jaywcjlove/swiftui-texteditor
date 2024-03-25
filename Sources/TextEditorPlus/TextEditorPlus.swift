// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

#if os(OSX)
import AppKit
private typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
import UIKit
private typealias ViewRepresentable = UIViewRepresentable
#endif


/// An enhanced version similar to `TextEditor`, aimed at maintaining consistency in its usage across iOS and macOS platforms.
///
/// ```swift
/// import TextEditorPlus
///
/// struct ContentView: View {
///     @State var text = """
///     Hello World
///     """
///     @State var isEditable = true
///     var body: some View {
///         TextEditorPlus(text: $text)
///             .textSetting(isEditable, for: .isEditable)
///     }
/// }
/// ```
///
/// Set text weight and size:
///
/// ```swift
/// TextEditorPlus(text: $text)
///     .font(.systemFont(ofSize: 24, weight: .regular))
/// ```
///
/// Set editor padding:
///
/// ```swift
/// TextEditorPlus(text: $text)
///   .textSetting(23, for: .insetPadding)
/// ```
///
/// Set editor background color:
///
/// ```swift
/// TextEditorPlus(text: $text)
///   .textSetting(NSColor.red, for: .backgroundColor)
/// ```
/// 
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
@available(iOS 13.0, macOS 10.15, *)
public struct TextEditorPlus: ViewRepresentable {
    @Binding var text: String
    @Environment(\.textViewIsEditable) private var isEditable
    @Environment(\.textViewInsetPadding) private var insetPadding
    @Environment(\.textViewAttributedString) private var textViewAttributedString
    @Environment(\.textViewBackgroundColor) private var textViewBackgroundColor
    @Environment(\.colorScheme) var colorScheme
    @Font var font: FontHelper = .systemFont(ofSize: 14, weight: .regular)
    
    public init(text: Binding<String>) {
        self._text = text
    }
    
    #if os(iOS)
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.delegate = context.coordinator
        textView.text = text
        textView.font = font
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.red.cgColor
        textView.backgroundColor = textViewBackgroundColor ?? UIColor.clear
        // 解决边距问题
        textView.textContainerInset = UIEdgeInsets(top: insetPadding, left: insetPadding, bottom: insetPadding, right: insetPadding)
        return textView
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.isEditable = isEditable
        uiView.font = font
        uiView.textContainerInset = UIEdgeInsets(top: insetPadding, left: insetPadding, bottom: insetPadding, right: insetPadding)
        
        uiView.backgroundColor = textViewBackgroundColor ?? UIColor.clear
        
        let attributedString = NSMutableAttributedString(string: text)
        let nsColor = colorScheme == .dark ? UIColor.white : UIColor.black
        // 默认设置背景
        attributedString.addAttribute(.foregroundColor, value: nsColor, range: NSRange(location: 0, length: attributedString.length))
        // 设置文字大小
        attributedString.addAttribute(.font, value: font as Any, range: NSRange(location: 0, length: attributedString.length))
        if textViewAttributedString(attributedString) != nil {
            uiView.textStorage.setAttributedString(attributedString)
        }
    }
    #elseif os(OSX)
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()
        
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(
            width: contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        layoutManager.addTextContainer(textContainer)
        
        
        let textView = NSTextView(frame: .zero, textContainer: textContainer)
        textView.autoresizingMask        = .width
        if let bgColor = textViewBackgroundColor {
            textView.backgroundColor         = bgColor
            textView.drawsBackground         = true
        } else {
            textView.backgroundColor         = NSColor.clear
            // 指示接收者是否绘制其背景
            textView.drawsBackground         = false
        }
        textView.isEditable              = isEditable
        textView.isHorizontallyResizable = false
        textView.isRichText              = false
        textView.isVerticallyResizable   = true
        textView.maxSize                 = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize                 = NSSize(width: 0, height: contentSize.height)
        textView.textColor               = NSColor.labelColor
        textView.allowsUndo              = true
        textView.delegate = context.coordinator // 设置代理
        textView.font = font

        textView.registerForDraggedTypes([.string])
        // 解决边距问题
        textView.textContainerInset = NSSize(width: 0, height: insetPadding)
        textView.textContainer?.lineFragmentPadding = insetPadding
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.documentView = textView
        return scrollView
    }

    public func updateNSView(_ scrollView: NSScrollView, context: Context) {
        if let textView = scrollView.documentView as? NSTextView {
            textView.string = text
            if context.coordinator.selectedRanges.count > 0 {
                textView.selectedRanges = context.coordinator.selectedRanges
            }
            
            if let bgColor = textViewBackgroundColor {
                textView.backgroundColor         = bgColor
                textView.drawsBackground         = true
            } else {
                textView.backgroundColor         = NSColor.clear
                // 指示接收者是否绘制其背景
                textView.drawsBackground         = false
            }
            
            textView.isEditable = isEditable
            textView.font = font
            
            textView.textContainerInset = NSSize(width: 0, height: insetPadding)
            textView.textContainer?.lineFragmentPadding = insetPadding
            
            let attributedString = NSMutableAttributedString(string: text)
            let nsColor = colorScheme == .dark ? NSColor.white : NSColor.black
            // 默认设置背景
            attributedString.addAttribute(.foregroundColor, value: nsColor, range: NSRange(location: 0, length: attributedString.length))
            // 设置文字大小
            attributedString.addAttribute(.font, value: font as Any, range: NSRange(location: 0, length: attributedString.length))
            if textViewAttributedString(attributedString) != nil {
                textView.textStorage?.setAttributedString(attributedString)
            }
        }
    }
    #endif
}

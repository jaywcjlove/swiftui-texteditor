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
    @Environment(\.textViewPlaceholderString) private var placeholderString
    @Environment(\.colorScheme) var colorScheme
    @Font var font: FontHelper = .systemFont(ofSize: 14, weight: .regular)
    
    public init(text: Binding<String>) {
        self._text = text
    }
    
    #if os(iOS)
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    public func makeUIView(context: Context) -> TextViewPlus {
        let textView = TextViewPlus()
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.delegate = context.coordinator
        textView.text = text
        textView.font = font
        textView.backgroundColor = textViewBackgroundColor ?? UIColor.clear
        textView.placeholderString = placeholderString ?? ""
        textView.placeholderFont = font
        // 解决边距问题
        textView.placeholderInsetPadding = insetPadding
        textView.textContainerInset = UIEdgeInsets(top: insetPadding, left: insetPadding, bottom: insetPadding, right: insetPadding)
        return textView
    }

    public func updateUIView(_ uiView: TextViewPlus, context: Context) {
        uiView.text = text
        uiView.isEditable = isEditable
        uiView.font = font
        uiView.placeholderFont = font
        // 解决边距问题
        uiView.placeholderInsetPadding = insetPadding
        uiView.textContainerInset = UIEdgeInsets(top: insetPadding, left: insetPadding, bottom: insetPadding, right: insetPadding)
        
        uiView.backgroundColor = textViewBackgroundColor ?? UIColor.clear
        uiView.placeholderString = placeholderString ?? ""
        
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
        
        
        let textView = TextViewPlus(frame: .zero, textContainer: textContainer)
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
        textView.allowsUndo              = true
        textView.delegate = context.coordinator // 设置代理
        textView.font = font
        textView.placeholderString = placeholderString ?? ""

        textView.registerForDraggedTypes([.string])
        // 解决边距问题
        textView.placeholderInsetPadding = insetPadding
        textView.textContainerInset = NSSize(width: 0, height: insetPadding)
        textView.textContainer?.lineFragmentPadding = insetPadding
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.documentView = textView
        return scrollView
    }

    public func updateNSView(_ scrollView: NSScrollView, context: Context) {
        if let textView = scrollView.documentView as? TextViewPlus {
            textView.string = text
            
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
            
            textView.placeholderString = placeholderString ?? ""
            textView.placeholderInsetPadding = insetPadding
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
            if context.coordinator.selectedRanges.count > 0 {
                textView.selectedRanges = context.coordinator.selectedRanges
            }
        }
    }
    #endif
}

#if os(OSX)
@available(macOS 10.15, *)
class TextViewPlus: NSTextView {
    var placeholderString: String = "" {
        didSet {
            self.needsDisplay = true
        }
    }
    var placeholderInsetPadding: CGFloat = 18
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if string.isEmpty && !placeholderString.isEmpty {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.placeholderTextColor,
                .font: self.font as Any
            ]
            let padding = placeholderInsetPadding
            let rect = CGRect(x: padding, y: padding, width: self.bounds.width - padding, height: self.bounds.height - padding)
            placeholderString.draw(in: rect, withAttributes: attributes)
        }
    }
}
#endif

#if os(iOS)
@available(iOS 13.0, *)

public class TextViewPlus: UITextView {
    var placeholderString: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    var placeholderFont: FontHelper?
    var placeholderInsetPadding: CGFloat = 18
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if text.isEmpty && !placeholderString.isEmpty {
            let font = placeholderFont != nil ? placeholderFont : self.font
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.placeholderText,
                .font: font as Any
            ]
            let padding = placeholderInsetPadding
            let rect = CGRect(x: padding + 3, y: padding + 2, width: self.bounds.width - padding, height: self.bounds.height - padding)
            placeholderString.draw(in: rect, withAttributes: attributes)
        }
    }
}
#endif

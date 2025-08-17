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
    @Binding var attributedText: NSMutableAttributedString?
    internal var isAttributedTextMode: Bool
    @Environment(\.textViewIsEditable) private var isEditable
    @Environment(\.textViewInsetPadding) private var insetPadding
    @Environment(\.textViewAttributedString) private var textViewAttributedString
    @Environment(\.textViewBackgroundColor) private var textViewBackgroundColor
    @Environment(\.textViewPlaceholderString) private var placeholderString
    @Environment(\.colorScheme) var colorScheme
    @Font var font: FontHelper = .systemFont(ofSize: 14, weight: .regular)
    
    public init(text: Binding<String>) {
        self._text = text
        self._attributedText = .constant(nil)
        self.isAttributedTextMode = false
    }
    
    public init(text: Binding<NSMutableAttributedString>) {
        self._text = .constant("")
        self._attributedText = Binding<NSMutableAttributedString?>(
            get: { text.wrappedValue },
            set: { newValue in
                if let newValue = newValue {
                    text.wrappedValue = newValue
                }
            }
        )
        self.isAttributedTextMode = true
    }
    
    private var currentText: String {
        if isAttributedTextMode {
            return attributedText?.string ?? ""
        } else {
            return text
        }
    }
    
    private var currentAttributedText: NSMutableAttributedString? {
        if isAttributedTextMode {
            return attributedText
        } else {
            return nil
        }
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
        
        // 设置文本内容
        if isAttributedTextMode {
            if let attributedText = attributedText {
                textView.attributedText = attributedText
            }
        } else {
            textView.text = text
        }
        
        textView.font = font
        textView.backgroundColor = textViewBackgroundColor ?? UIColor.clear
        textView.placeholderString = placeholderString ?? ""
        textView.placeholderFont = font
        // 关闭自动拼写、自动更正等特性
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.smartInsertDeleteType = .no
        // 解决边距问题
        textView.placeholderInsetPadding = insetPadding
        textView.textContainerInset = UIEdgeInsets(top: insetPadding, left: insetPadding, bottom: insetPadding, right: insetPadding)
        return textView
    }

    public func updateUIView(_ uiView: TextViewPlus, context: Context) {
        // 根据模式更新文本内容
        if isAttributedTextMode {
            if let attributedText = attributedText, 
               uiView.attributedText.string != attributedText.string {
                uiView.attributedText = attributedText
            }
        } else {
            // 只在内容变化时赋值，避免大文本频繁刷新
            if uiView.text != text {
                uiView.text = text
            }
        }
        
        uiView.isEditable = isEditable
        if uiView.font != font {
            uiView.font = font
        }
        uiView.placeholderFont = font
        // 解决边距问题
        uiView.placeholderInsetPadding = insetPadding
        uiView.textContainerInset = UIEdgeInsets(top: insetPadding, left: insetPadding, bottom: insetPadding, right: insetPadding)
        uiView.backgroundColor = textViewBackgroundColor ?? UIColor.clear
        uiView.placeholderString = placeholderString ?? ""
        
        // 只有在非属性字符串模式下才应用 textViewAttributedString 处理
        if !isAttributedTextMode && !text.isEmpty {
            let attributedString = NSMutableAttributedString(string: text)
            let nsColor = colorScheme == .dark ? UIColor.white : UIColor.black
            attributedString.addAttribute(.foregroundColor, value: nsColor, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(.font, value: font as Any, range: NSRange(location: 0, length: attributedString.length))
            if textViewAttributedString(attributedString) != nil {
                uiView.textStorage.setAttributedString(attributedString)
            }
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
        scrollView.autohidesScrollers = true
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
        
        // 设置文本内容
        if isAttributedTextMode {
            if let attributedText = attributedText {
                textView.textStorage?.setAttributedString(attributedText)
            }
        } else {
            textView.string = text
        }
        
        // 关闭自动拼写检查等特性
        textView.isContinuousSpellCheckingEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isGrammarCheckingEnabled = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.isAutomaticTextCompletionEnabled = false

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
            // 根据模式更新文本内容
            if isAttributedTextMode {
                if let attributedText = attributedText,
                   textView.textStorage?.string != attributedText.string {
                    textView.textStorage?.setAttributedString(attributedText)
                }
            } else {
                // 只在内容变化时赋值，避免大文本频繁刷新
                if textView.string != text {
                    textView.string = text
                }
            }
            
            if let bgColor = textViewBackgroundColor {
                textView.backgroundColor         = bgColor
                textView.drawsBackground         = true
            } else {
                textView.backgroundColor         = NSColor.clear
                textView.drawsBackground         = false
            }
            textView.isEditable = isEditable
            if textView.font != font {
                textView.font = font
            }
            textView.placeholderString = placeholderString ?? ""
            textView.placeholderInsetPadding = insetPadding
            textView.textContainerInset = NSSize(width: 0, height: insetPadding)
            textView.textContainer?.lineFragmentPadding = insetPadding
            
            // 只有在非属性字符串模式下才应用 textViewAttributedString 处理
            if !isAttributedTextMode && !text.isEmpty {
                let attributedString = NSMutableAttributedString(string: text)
                let nsColor = colorScheme == .dark ? NSColor.white : NSColor.black
                attributedString.addAttribute(.foregroundColor, value: nsColor, range: NSRange(location: 0, length: attributedString.length))
                attributedString.addAttribute(.font, value: font as Any, range: NSRange(location: 0, length: attributedString.length))
                if textViewAttributedString(attributedString) != nil {
                    textView.textStorage?.setAttributedString(attributedString)
                }
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
        
        let shouldShowPlaceholder = string.isEmpty && textStorage?.length == 0
        if shouldShowPlaceholder && !placeholderString.isEmpty {
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
        
        let shouldShowPlaceholder = text.isEmpty && attributedText.length == 0
        if shouldShowPlaceholder && !placeholderString.isEmpty {
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

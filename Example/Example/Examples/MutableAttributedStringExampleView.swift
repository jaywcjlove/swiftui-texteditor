//
//  MutableAttributedStringExampleView.swift
//  Example
//
//  Created by 王楚江 on 2024/3/26.
//

import SwiftUI
import TextEditorPlus

#if os(OSX)
    import AppKit
    public typealias ViewColor = NSColor
#elseif os(iOS)
    import UIKit
    public typealias ViewColor = UIColor
#endif

struct MutableAttributedStringExampleView: View {
    @State var text = """
    Hello World
    """
    @State var attributedText = NSMutableAttributedString(string: """
    This is a NSMutableAttributedString example.
    You can edit this text directly.
    The formatting will be preserved!
    """)
    @State var pattern: String = "[a-z]*"
    @State var isEditable = true
    @State var useAttributedString = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                TextField("Pattern", text: $pattern).labelsHidden()
                Button(isEditable ? "Disable Editing" : "Edit") {
                    isEditable.toggle()
                }
                Button(useAttributedString ? "Use String" : "Use AttributedString") {
                    useAttributedString.toggle()
                }
            }
            .padding()
            
            if useAttributedString {
                // 使用 NSMutableAttributedString 绑定
                TextEditorPlus(text: $attributedText)
                    .textSetting(isEditable, for: .isEditable)
                    .onAppear {
                        setupAttributedText()
                    }
            } else {
                // 使用 String 绑定
                TextEditorPlus(text: $text)
                    .textSetting(isEditable, for: .isEditable)
                    .textViewAttributedString(action: { val in
                        if isValidRegex(pattern) {
                            val.matchText(pattern: pattern)
                            let style = NSMutableParagraphStyle()
                            style.lineSpacing = 5
                            style.lineHeightMultiple = 1.2
                            
                            val.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: val.length))
                            return val
                        }
                        return nil
                    })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    func setupAttributedText() {
        let fullRange = NSRange(location: 0, length: attributedText.length)
        
        // 设置基础字体
        #if os(iOS)
        attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: fullRange)
        #else
        attributedText.addAttribute(.font, value: NSFont.systemFont(ofSize: 16), range: fullRange)
        #endif
        
        // 高亮 "NSMutableAttributedString" 文字
        let highlightText = "NSMutableAttributedString"
        let highlightRange = (attributedText.string as NSString).range(of: highlightText)
        if highlightRange.location != NSNotFound {
            attributedText.addAttribute(.backgroundColor, value: ViewColor.systemBlue, range: highlightRange)
            attributedText.addAttribute(.foregroundColor, value: ViewColor.white, range: highlightRange)
        }
        
        // 设置段落样式
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        paragraphStyle.paragraphSpacing = 8
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
    }
    func isValidRegex(_ pattern: String) -> Bool {
        do {
            // 尝试编译正则表达式
            let _ = try NSRegularExpression(pattern: pattern, options: [])
            return true // 如果编译成功，则正则表达式有效
        } catch {
            // 如果编译失败，则正则表达式无效
            return false
        }
    }
}

extension NSMutableAttributedString {
    func setLineHeight(_ lineHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight // 设置行高
        paragraphStyle.maximumLineHeight = lineHeight // 设置行高
        paragraphStyle.lineHeightMultiple = lineHeight // 设置行高
        
        self.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: self.length))
    }
    // 匹配文本
    func matchText(pattern: String) {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: self.length)
            let matches = regex.matches(in: self.string, options: [], range: range)
            for (index, match) in matches.enumerated() {
                let color: ViewColor
                if index % 2 == 0 { // 如果索引是偶数
                    color = ViewColor(red: 0.608, green: 0.231, blue: 0.780, alpha: 1) // 设置第一种背景颜色
                } else {
                    color = ViewColor(red: 0.239, green: 0.494, blue: 0.780, alpha: 1) // 设置第二种背景颜色
                }
                self.addAttribute(.foregroundColor, value: ViewColor.white, range: match.range)
                self.addAttribute(.backgroundColor, value: color, range: match.range)
            }
            
        } catch {
            print("Error highlighting parentheses: \(error.localizedDescription)")
        }
    }
}

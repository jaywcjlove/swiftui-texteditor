//
//  File.swift
//  
//
//  Created by 王楚江 on 2024/3/25.
//

import SwiftUI

// MARK: - Coordinator
@available(iOS 13.0, macOS 10.15, *)
extension TextEditorPlus {
    #if os(iOS)
    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextEditorPlus
        var selectedRanges: [NSValue] = []
        
        init(_ parent: TextEditorPlus) {
            self.parent = parent
        }
        
        public func textViewDidBeginEditing(_ textView: UITextView) {
            self.parent.text = textView.text
            self.selectedRanges = textView.selectedTextRange != nil ? [NSValue(range: textView.selectedRange)] : []
        }
        
        public func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
            self.selectedRanges = textView.selectedTextRange != nil ? [NSValue(range: textView.selectedRange)] : []
        }
        
        public func textViewDidEndEditing(_ textView: UITextView) {
            self.parent.text = textView.text
            self.selectedRanges = textView.selectedTextRange != nil ? [NSValue(range: textView.selectedRange)] : []
        }
    }
    #endif
    #if os(OSX)
    public class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TextEditorPlus
        var selectedRanges: [NSValue] = []
        
        init(_ parent: TextEditorPlus) {
            self.parent = parent
        }
        public func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            if let textDidBeginEditing = self.parent.textDidBeginEditing {
                textDidBeginEditing(textView.string) // 调用闭包
            }
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
        }
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
        }
        
        public func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
        }
    }
    #endif
}

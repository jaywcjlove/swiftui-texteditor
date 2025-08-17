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
        private var debounceTimer: Timer?
        
        init(_ parent: TextEditorPlus) {
            self.parent = parent
        }
        
        public func textViewDidBeginEditing(_ textView: UITextView) {
            self.parent.text = textView.text
            self.selectedRanges = textView.selectedTextRange != nil ? [NSValue(range: textView.selectedRange)] : []
        }
        
        public func textViewDidChange(_ textView: UITextView) {
            // 对于大文本，使用防抖机制减少频繁更新
            debounceTimer?.invalidate()
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.parent.text = textView.text
                    self?.selectedRanges = textView.selectedTextRange != nil ? [NSValue(range: textView.selectedRange)] : []
                }
            }
        }
        
        public func textViewDidEndEditing(_ textView: UITextView) {
            debounceTimer?.invalidate()
            self.parent.text = textView.text
            self.selectedRanges = textView.selectedTextRange != nil ? [NSValue(range: textView.selectedRange)] : []
        }
    }
    #endif
    #if os(OSX)
    public class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TextEditorPlus
        var selectedRanges: [NSValue] = []
        private var debounceTimer: Timer?
        
        init(_ parent: TextEditorPlus) {
            self.parent = parent
        }
        public func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
        }
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            // 对于大文本，使用防抖机制减少频繁更新
            debounceTimer?.invalidate()
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.parent.text = textView.string
                    self?.selectedRanges = textView.selectedRanges
                }
            }
        }
        
        public func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            debounceTimer?.invalidate()
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
        }
    }
    #endif
}

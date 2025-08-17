//
//  DiffView.swift
//  Example
//
//  Created by wong on 8/17/25.
//

import SwiftUI
import TextEditorPlus
import Sdifft

extension LocalizedStringKey {
    func localizedString(locale: Locale) -> String {
        let mirror = Mirror(reflecting: self)
        let key = mirror.children.first { $0.label == "key" }?.value as? String ?? ""
        
        let languageCode = locale.identifier
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}

// MARK: 全局状态
class TextDiff: ObservableObject {
    @Published var source: String = "Hello World!"
    @Published var target: String = "Hello DevHub!"
    @Published var attributedString: NSMutableAttributedString = .init()
}

struct TextDiffView: View {
    @StateObject var vm = TextDiff()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.locale) var locale
    
    @FocusState var input: InputFocused?
    @State var loading: Bool = false
    private var text = NSAttributedString()
    enum InputFocused {
        case text,output
    }
    
    var body: some View {
        VSplitView {
            HSplitView {
                let prompt = LocalizedStringKey("Paste your text here").localizedString(locale: locale)
               TextEditorPlus(text: $vm.source)
                   .font(.systemFont(ofSize: 14, weight: .regular))
                   .textSetting(CGFloat(5), for: .insetPadding)
                   .textSetting(prompt, for: .placeholderString)
                   .frame(minHeight: 120)
                   .focused($input, equals: .text)
                   .onChange(of: vm.source, initial: true) { oldValue, newValue in
                       if input == .text {
                           update()
                       }
                   }
                TextEditorPlus(text: $vm.target)
                    .font(.systemFont(ofSize: 14, weight: .regular))
                    .textSetting(CGFloat(10), for: .insetPadding)
                    .textSetting(prompt, for: .placeholderString)
                    .frame(minHeight: 120)
                    .focused($input, equals: .output)
                    .onChange(of: vm.target, initial: true) { oldValue, newValue in
                        if input == .output {
                            update()
                        }
                    }
                
            }
            ZStack {
                TextEditorPlus(text: $vm.attributedString).frame(minHeight: 120)
                if loading == true {
                    ProgressView().controlSize(.mini)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            update()
        }
    }
    func update() {
        loading = true
        DispatchQueue.global(qos: .userInitiated).async {
            guard let result = updateAttributedString(source: vm.source, target: vm.target) else {
                loading = false
                return
            }
            DispatchQueue.main.async {
                vm.attributedString = result as! NSMutableAttributedString
                loading = false
            }
        }
    }
    func updateAttributedString(source: String, target: String) -> NSAttributedString? {
        // 创建一个简单的测试文本，确保有内容
        let testText = ""
        let basicAttributedString = NSMutableAttributedString(string: testText)

        // 设置基本样式
        let nsColor = colorScheme == .dark ? NSColor.white : NSColor.black
        let font: NSFont = .systemFont(ofSize: 14, weight: .regular)

        let fullRange = NSRange(location: 0, length: basicAttributedString.length)
        basicAttributedString.addAttribute(.foregroundColor, value: nsColor, range: fullRange)
        basicAttributedString.addAttribute(.font, value: font, range: fullRange)

        // 尝试使用 Sdifft 进行差异比较（如果可用）
        let diffAttributes = DiffAttributes(
            insert: [.backgroundColor: NSColor.systemGreen.withAlphaComponent(0.3)],
            delete: [.backgroundColor: NSColor.systemRed.withAlphaComponent(0.3)],
            same: [.backgroundColor: NSColor.clear]
        )

        let diffResult = NSMutableAttributedString(source: source, target: target, attributes: diffAttributes)
        var _ = print("diffResult", diffResult.length)
        if diffResult.length > 0 {
            // 为 diff 结果添加基本样式
            let diffRange = NSRange(location: 0, length: diffResult.length)
            diffResult.addAttribute(.foregroundColor, value: nsColor, range: diffRange)
            diffResult.addAttribute(.font, value: font, range: diffRange)

            // 添加标题
            let diffWithTitle = NSMutableAttributedString()
            diffWithTitle.append(diffResult)

            print("✅ Using Sdifft diff result with length: \(diffWithTitle.length)")
            return diffWithTitle
        }
        return basicAttributedString
    }
}

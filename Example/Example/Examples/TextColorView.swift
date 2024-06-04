//
//  TextColorView.swift
//  Example
//
//  Created by 王楚江 on 2024/6/4.
//

import SwiftUI
import TextEditorPlus

struct TextColorView: View {
    @State var text = """
    Hello World
    """
    @State var color: Color = .red
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            ColorPicker(selection: $color, supportsOpacity: true, label: {
                    
                })
                .controlSize(.small)
                .labelsHidden()
                .padding()
            
            TextEditorPlus(text: $text)
                .foregroundColor(.red)
                .background(Color.blue)
            Divider()
            TextEditor(text: $text)
                .foregroundColor(.red)
                .background(.background)
                .background(
                    HStack(alignment: .top) {
                        text.isEmpty ? Text("placeholder") : Text("")
                    }
                    .foregroundColor(Color.primary.opacity(0.25))
                    .padding(EdgeInsets(top: 28, leading: 32, bottom: 7, trailing: 0))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .border(.red)
                )
        }
        .onChange(of: text, initial: true, { old, val in
            print("val: \(val)")
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    TextColorView()
}

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear //<<here clear
            drawsBackground = true
            textContainer?.lineFragmentPadding = 32
            textContainerInset = NSSize(width: 0, height: 32)
        }
    }
}

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
                .textSetting(NSColor(color), for: .textColor)
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

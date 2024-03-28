//
//  OnChangeView.swift
//  Example
//
//  Created by 王楚江 on 2024/3/27.
//

import SwiftUI
import TextEditorPlus

struct OnChangeView: View {
    @State var text = """
    Hello World
    """
    @State var isEditable = true
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(isEditable ? "Disable Editing" : "Edit") {
                isEditable.toggle()
            }
            .padding()
            
            TextEditorPlus(text: $text)
                .textSetting(isEditable, for: .isEditable)
        }
        .onChange(of: text, initial: true, { old, val in
            print("val: \(val)")
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    OnChangeView()
}

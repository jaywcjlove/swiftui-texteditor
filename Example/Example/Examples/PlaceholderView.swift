//
//  PlaceholderView.swift
//  Example
//
//  Created by 王楚江 on 2024/3/26.
//

import SwiftUI
import TextEditorPlus

struct PlaceholderView: View {
    @State var text = ""
    @State var isEditable = true
    @State var fontSize: String = "32"
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(isEditable ? "Disable Editing" : "Edit") {
                    isEditable.toggle()
                }
                
                Picker(selection: $fontSize, content: {
                    Text("12").tag("12")
                    Text("24").tag("24")
                    Text("32").tag("32")
                }, label: {
                    Text("Size")
                })
                .frame(width: 86)
            }
            .padding()
            
            TextEditorPlus(text: $text)
                .font(.systemFont(ofSize: CGFloat(Float(fontSize)!), weight: .regular))
                .textSetting(isEditable, for: .isEditable)
                .textSetting("Test placeholder string", for: .placeholderString)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    PlaceholderView()
}

//
//  FontExampleView.swift
//  Example
//
//  Created by 王楚江 on 2024/3/25.
//

import SwiftUI
import TextEditorPlus

struct FontExampleView: View {
    @State var text = """
    Hello World
    """
    @State var fontSize: String = "32"
    @State var insetPadding: String = "18"
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Picker(selection: $insetPadding, content: {
                    Text("18").tag("18")
                    Text("24").tag("24")
                    Text("32").tag("32")
                    Text("42").tag("42")
                }, label: {
                    Text("Inset Padding")
                })
                .frame(width: 137)
                
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
                .textSetting(CGFloat(Float(insetPadding)!), for: .insetPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

#Preview {
    FontExampleView()
}

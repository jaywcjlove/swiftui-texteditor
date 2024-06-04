//
//  ContentView.swift
//  Example
//
//  Created by 王楚江 on 2024/3/25.
//

import SwiftUI
import TextEditorPlus

struct SideBar: Identifiable, Hashable, Equatable {
    static func == (lhs: SideBar, rhs: SideBar) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let id = UUID()
    var name: String
    var view: AnyView
}

struct ContentView: View {
    @State private var examples = [
        SideBar(name: "Text Color Test", view: AnyView(TextColorView())),
        SideBar(name: "Change Event Test", view: AnyView(OnChangeView())),
        SideBar(name: "Placeholder Example", view: AnyView(PlaceholderView())),
        SideBar(name: "Mutable Attributed String", view: AnyView(MutableAttributedStringExampleView())),
        SideBar(name: "Example", view: AnyView(ExampleView())),
        SideBar(name: "Font Example", view: AnyView(FontExampleView())),
    ]
    @State private var selected: SideBar?
    var body: some View {
        NavigationSplitView {
            List(examples, selection: $selected) { team in
                Text(team.name).tag(team)
            }
            .navigationSplitViewColumnWidth(180)
        } detail: {
            selected?.view ?? AnyView(EmptyView())
        }
        .navigationSplitViewStyle(.prominentDetail)
        .onAppear() {
            selected = examples.first
        }
    }
}

#Preview {
    ContentView()
}

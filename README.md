SwiftUI TextEditorPlus
===

[![Buy me a coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-048754?logo=buymeacoffee)](https://jaywcjlove.github.io/#/sponsor)
[![CI](https://github.com/jaywcjlove/swiftui-texteditor/actions/workflows/ci.yml/badge.svg)](https://github.com/jaywcjlove/swiftui-texteditor/actions/workflows/ci.yml)
[![SwiftUI Support](https://shields.io/badge/SwiftUI-macOS%20v11%20%7C%20iOS%20v13-green?logo=Swift&style=flat)](https://swiftpackageindex.com/jaywcjlove/swiftui-texteditor)

An enhanced version similar to `TextEditor`, aimed at maintaining consistency in its usage across iOS and macOS platforms.

## Installation

You can add MarkdownUI to an Xcode project by adding it as a package dependency.

1. From the File menu, select Add Packages…
2. Enter https://github.com/jaywcjlove/swiftui-texteditor the Search or Enter Package URL search field
3. Link `Markdown` to your application target

Or add the following to `Package.swift`:

```swift
.package(url: "https://github.com/jaywcjlove/swiftui-texteditor", from: "1.0.0")
```

Or [add the package in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).

## Usage

```swift
import TextEditorPlus

struct ContentView: View {
    @State var text = """
    Hello World
    """
    @State var isEditable = true
    var body: some View {
        TextEditorPlus(text: $text)
            .textSetting(isEditable, for: .isEditable)
    }
}
```

Set text weight and size:

```swift
TextEditorPlus(text: $text)
    .font(.systemFont(ofSize: 24, weight: .regular))
```

Set editor padding:

```swift
TextEditorPlus(text: $text)
  .textSetting(23, for: .insetPadding)
```

Set editor background color:

```swift
TextEditorPlus(text: $text)
  .textSetting(NSColor.red, for: .backgroundColor)
```

Set editor placeholder string:

```swift
TextEditorPlus(text: $text)
    //.font(NSFont(name: "pencontrol", size: 12)!)
    .font(.systemFont(ofSize: CGFloat(Float(fontSize)!), weight: .regular))
    .textSetting("Test placeholder string", for: .placeholderString)
```

Manipulate attributed strings with attributes such as visual styles, hyperlinks, or accessibility data for portions of the text.

```swift
TextEditorPlus(text: $text)
    .textSetting(isEditable, for: .isEditable)
    .textViewAttributedString(action: { val in
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5
            style.lineHeightMultiple = 1.2
            val.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: val.length))
            return val
    })
````

## License

Licensed under the MIT License.

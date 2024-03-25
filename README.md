SwiftUI TextEditorPlus
===

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

## License

Licensed under the MIT License.

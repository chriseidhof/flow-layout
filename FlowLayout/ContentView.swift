import SwiftUI

struct Item: Identifiable, Hashable {
    var id: Int
    var hue = CGFloat.random(in: 0...1)
    var width = CGFloat.random(in: 100...150)

    var color: Color {
        Color(hue: hue, saturation: 0.8, brightness: 0.9)
    }
}

func layout(sizes: [CGSize], spacing: CGFloat = 10, containerWidth: CGFloat) -> [CGPoint] {
    var result: [CGPoint] = []
    var currentPosition: CGPoint = .zero
    var lineHeight: CGFloat = 0
    for size in sizes {
        if currentPosition.x + size.width > containerWidth {
            currentPosition.x = 0
            currentPosition.y += lineHeight + spacing
            lineHeight = 0
        }

        result.append(currentPosition)
        currentPosition.x += size.width
        currentPosition.x += spacing
        lineHeight = max(lineHeight, size.height)
    }

    return result
}

struct SizeKey: PreferenceKey {
    static let defaultValue: [CGSize] = []

    static func reduce(value: inout [CGSize], nextValue: () -> [CGSize]) {
        value.append(contentsOf: nextValue())
    }
}

struct FlowLayout<Element: Identifiable, Content: View>: View {
    var items: [Element]
    var containerWidth: CGFloat
    @ViewBuilder var content: (Element) -> Content
    @State private var itemSizes: [CGSize] = []

    var body: some View {
        let offsets = layout(sizes: itemSizes, containerWidth: containerWidth)
        ZStack(alignment: .topLeading) {
            ForEach(Array(items.enumerated()), id: \.element.id) { item in
                content(item.element)
                    .alignmentGuide(.leading) { _ in
                        offsets.isEmpty ? 0 : -offsets[item.offset].x
                    }
                    .alignmentGuide(.top) { _ in
                        offsets.isEmpty ? 0 : -offsets[item.offset].y
                    }
                    .overlay(GeometryReader { proxy in
                        Color.clear.preference(key: SizeKey.self, value: [proxy.size])
                    })
            }
        }
        .onPreferenceChange(SizeKey.self) { itemSizes = $0 }
    }
}

struct ContentView: View {
    @State var items = (0...30).map { Item(id: $0) }
    @State var containerWidth: CGFloat?

    var body: some View {
        ScrollView {
            FlowLayout(items: items, containerWidth: containerWidth ?? 0) { item in
                RoundedRectangle(cornerRadius: 10)
                    .fill(item.color)
                    .frame(width: item.width, height: 30)
                    .onTapGesture {
                        items.removeAll { $0.id == item.id }
                    }
            }
            .padding()
        }
        .animation(.default, value: items.map { $0.id })
        .animation(.default, value: containerWidth)
        .frame(minWidth: 0, maxWidth: .infinity)
        .overlay {
            GeometryReader { proxy in
                Color.clear.task(id: proxy.size.width) {
                    if containerWidth == nil {
                        var t = Transaction()
                        t.disablesAnimations = true
                        withTransaction(t) {
                            containerWidth = proxy.size.width
                        }
                    } else {
                        containerWidth = proxy.size.width
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

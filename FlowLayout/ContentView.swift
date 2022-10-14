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
    fatalError("TODO")
}

struct FlowLayout<Element: Identifiable, Content: View>: View {
    var items: [Element]
    var containerWidth: CGFloat
    @ViewBuilder var content: (Element) -> Content

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(items.enumerated()), id: \.element.id) { item in
                content(item.element)
            }
        }
    }
}

struct ContentView: View {
    @State var items = (0...30).map { Item(id: $0) }

    var body: some View {
        ScrollView {
            FlowLayout(items: items, containerWidth: 0) { item in
                RoundedRectangle(cornerRadius: 10)
                    .fill(item.color)
                    .frame(width: item.width, height: 30)
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


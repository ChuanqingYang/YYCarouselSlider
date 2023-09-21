// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

@available(iOS 17.0,*)
public struct YYSliderDataModel: Identifiable {
    private(set) public var id: UUID = .init()
    
    var color: Color
    var title: String
    var subTitle: String
}

@available(iOS 17.0,*)
public struct YYPagingSlider<Content: View,TitleContent: View,Item: RandomAccessCollection>: View where Item: MutableCollection,Item.Element: Identifiable {
    
    var titleContentScrollSpeed: CGFloat = 0.6
    var showIndicator: ScrollIndicatorVisibility = .hidden
    var showPagingControl: Bool = true
    var pagingControlSpacing: CGFloat = 20
    var spacing: CGFloat = 10
    
    @Binding var data: Item
    @ViewBuilder var content: (Binding<Item.Element>) -> Content
    @ViewBuilder var titleContent: (Binding<Item.Element>) -> TitleContent
    
    @State private var activeId: UUID?
    public var body: some View {
        VStack(spacing: pagingControlSpacing) {
            ScrollView(.horizontal) {
                HStack(spacing: spacing) {
                    ForEach($data) { item in
                        VStack(spacing: 0) {
                            titleContent(item)
                                .frame(maxWidth: .infinity)
                                .visualEffect { content, geometryProxy in
                                    content
                                        .offset(x: scrollOffset(geometryProxy))
                                }
                            content(item)
                        }
                        .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(showIndicator)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $activeId)
            
            if showPagingControl {
                YYPagingControl(numberOfPages: data.count, activePage: activePage) { index in
                    if let pageIndex = index as? Item.Index,data.indices.contains(pageIndex) {
                        if let id = data[pageIndex].id as? UUID {
                            withAnimation(.snappy(duration: 0.35, extraBounce: 0)) {
                                activeId = id
                            }
                        }
                    }
                }
            }
        }
    }
    
    var activePage: Int {
        if let index = data.firstIndex(where: { $0.id as? UUID == activeId }) as? Int {
            return index
        }
        
        return 0
    }
    
    func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.bounds(of: .scrollView)?.minX ?? 0
        return -minX * min(titleContentScrollSpeed, 1.0)
    }
}

/// PagingControl
@available(iOS 17.0, *)
struct YYPagingControl: UIViewRepresentable {
    var numberOfPages: Int
    var activePage: Int
    var onPageChanged: (Int) -> ()
    
    func makeUIView(context: Context) -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = activePage
        pageControl.backgroundStyle = .prominent
        pageControl.currentPageIndicatorTintColor = UIColor(Color.primary)
        pageControl.pageIndicatorTintColor = UIColor.placeholderText
        pageControl.addTarget(context.coordinator, action: #selector(Coordinator.onPageUpdate(control:)), for: .valueChanged)
        return pageControl
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.numberOfPages = numberOfPages
        uiView.currentPage = activePage
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onPageChange: onPageChanged)
    }
    
    class Coordinator: NSObject {
        
        var onPageChange: (Int) -> ()
        init(onPageChange: @escaping (Int) -> Void) {
            self.onPageChange = onPageChange
        }
        
        @objc
        func onPageUpdate(control: UIPageControl) {
            onPageChange(control.currentPage)
        }
        
    }
}

/// for test
@available(iOS 17.0,*)
struct TestView: View {
    
    @State private var items:[YYSliderDataModel] = [
        .init(color: .red, title: "Hello World", subTitle: "First App for iOS 17"),
        .init(color: .green, title: "Hello SwiftUI", subTitle: "SwiftUI is an Amazing Language"),
        .init(color: .yellow, title: "Hello iOS17", subTitle: "iOS 17 gives a shit"),
        .init(color: .purple, title: "Hello World", subTitle: "First App for iOS 17"),
    ]
    
    var body: some View {
        YYPagingSlider(data: $items) { $item in
            RoundedRectangle(cornerRadius: 15)
                .fill(item.color.gradient)
                .frame(width: nil ,height: 150)
                
        } titleContent: { $item in
            VStack(spacing: 0) {
                Text(item.title)
                    .font(.largeTitle.bold())
                
                Text(item.subTitle)
                    .font(.headline.italic())
                    .foregroundStyle(.gray)
            }
            .padding(.vertical,10)
        }
        .safeAreaPadding(.horizontal,35)

    }
}

@available(iOS 17.0,*)
#Preview {
    TestView()
}
import SwiftUI

private struct DragAndDropModifier<T: Hashable & Identifiable>: ViewModifier {
    
    @Environment(DragItem<T>.self) private var dragItem
    
    @State private var frame: CGRect = .zero
    
    let value: T
    
    let drop: (T) -> Void
    
    func body(content: Content) -> some View {
        content
            .id(value.id)
            .opacity(dragItem.value == value ? 0 : 1)
            .background(background)
            .onLongPressGesture(minimumDuration: 0.3) {
                dragItem.value = value
                dragItem.frame = frame
            } onPressingChanged: { value in
                if !value {
                    dragItem.value = nil
                    dragItem.frame = .zero
                    dragItem.translation = .zero
                    dragItem.intersections = [:]
                }
            }
            .onChange(of: dragItem.translation) { _, newValue in
                guard dragItem.value != value else { return }
                guard frame.height != .zero else { return }
                
                let newFrame = dragItem.frame.offsetBy(dx: newValue.width, dy: newValue.height)
                let intersection = frame.intersection(newFrame)
                
                if intersection.height / frame.height > 0.6 {
                    dragItem.intersections[value.id] = .init(frame: frame, value: value)
                } else {
                    dragItem.intersections[value.id] = nil
                }
            }
            .onChange(of: dragItem.farestIntersection) { oldValue, newValue in
                if let dragValue = dragItem.value, newValue?.value == value {
                    drop(dragValue)
                }
            }
    }
    
    private var background: some View {
        GeometryReader { geometry in
            Color.clear.onChange(of: geometry.frame(in: .named("drag_and_drop"))) { _, newValue in
                frame = newValue
            }.onAppear {
                frame = geometry.frame(in: .named("drag_and_drop"))
            }
        }
    }
    
}

public extension View {
    
    func dragAndDrop<T>(
        value: T,
        onDrop: @escaping (T) -> Void
    ) -> some View where T: Hashable & Identifiable {
        modifier(DragAndDropModifier(value: value, drop: onDrop))
    }
    
}

import SwiftUI

private struct DragAndDropPreviewModifier<T: Hashable & Identifiable, Preview: View>: ViewModifier {
    
    @Binding var dragItem: DragItem<T>
    
    let preview: (T) -> Preview
    
    func body(content: Content) -> some View {
        content.overlay {
            if let value = dragItem.value {
                preview(value)
                    .frame(
                        width: dragItem.frame.width,
                        height: dragItem.frame.height
                    )
                    .transformEffect(.init(scaleX: 1.03, y: 1.03))
                    .transformEffect(.init(
                        translationX: -dragItem.frame.width * 0.015,
                        y: -dragItem.frame.height * 0.015
                    ))
                    .position(
                        x: dragItem.frame.midX + dragItem.translation.width,
                        y: dragItem.frame.midY + dragItem.translation.height
                    )
                    .shadow(color: .black.opacity(0.25), radius: 10)
                    .id(value.id)
            }
        }
        .scrollDisabled(dragItem.value != nil)
        .coordinateSpace(name: "drag_and_drop")
        .environment(dragItem)
        .animation(.spring(duration: 0.1), value: dragItem.value)
        .sensoryFeedback(.selection, trigger: dragItem.value)
        .simultaneousGesture(dragGesture)
    }
    
    private var dragGesture: some Gesture {
        let longPressGesture = LongPressGesture(minimumDuration: 0.3)
        let dragGesture = DragGesture()
            .onChanged { value in
                dragItem.translation = value.translation
            }
        
        return longPressGesture.sequenced(before: dragGesture)
    }
    
}

public extension View {
    
    func draggableItem<T, Preview>(
        item: Binding<DragItem<T>>,
        @ViewBuilder preview: @escaping (T) -> Preview
    ) -> some View where T: Hashable & Identifiable, Preview: View {
        modifier(DragAndDropPreviewModifier(
            dragItem: item,
            preview: preview
        ))
    }
    
}

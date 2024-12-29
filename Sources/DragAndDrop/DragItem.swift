import Foundation
import Observation
import CoreGraphics

@Observable public final class DragItem<T: Hashable & Identifiable> {
    
    enum State {
        case idle
        case preparing
        case dragging
    }
    
    struct Intersection: Hashable {
        let frame: CGRect
        let value: T
    }
    
    var state: State = .idle
    
    var frame: CGRect = .zero
    
    var translation: CGSize = .zero
    
    var value: T?
    
    var intersections: [T.ID: Intersection] = [:]
    
    public init() {}
    
    var farestIntersection: Intersection? {
        intersections.values.max {
            $0.frame.centerDistance(to: frame) < $1.frame.centerDistance(to: frame)
        }
    }
    
}

private extension CGRect {
    /// Calculates the Euclidean distance between the centers of this CGRect and another CGRect.
    /// - Parameter other: The other CGRect to calculate the distance to.
    /// - Returns: The Euclidean distance between the centers of the two CGRects.
    func centerDistance(to other: CGRect) -> CGFloat {
        let center1 = CGPoint(x: self.midX, y: self.midY)
        let center2 = CGPoint(x: other.midX, y: other.midY)
        let dx = center2.x - center1.x
        let dy = center2.y - center1.y
        return sqrt(dx * dx + dy * dy)
    }
    
}

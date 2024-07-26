import Foundation
import RealityKit

/// Bundle for the URRobots project
public let urrobotBundle = Bundle.module

public func entity(named name: String) async -> Entity? {
    do {
        return try await Entity(named: name, in: urrobotBundle)

    } catch is CancellationError {
        // The entity initializer can throw this error if an enclosing
        // RealityView disappears before the model loads. Exit gracefully.
        return nil

    } catch let error {
        // Other errors indicate unrecoverable problems.
        fatalError("Failed to load \(name): \(error)")
    }
}

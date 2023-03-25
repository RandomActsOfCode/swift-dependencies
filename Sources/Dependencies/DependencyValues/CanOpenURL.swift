import Foundation
#if canImport(UIKit)
  import UIKit
#endif

extension DependencyValues {
  /// A dependency that queries if a URL can be opened without opening the URL
  @available(macOS, unavailable)
  @available(watchOS, unavailable)
  @available(iOS 14,tvOS 14, watchOS 7, *)
  public var canOpenURL: CanOpenURLEffect {
    get { self[CanOpenURLKey.self] }
    set { self[CanOpenURLKey.self] = newValue }
  }
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(iOS 14,tvOS 14, watchOS 7, *)
private enum CanOpenURLKey: DependencyKey {
  static let liveValue = CanOpenURLEffect { url in
    let stream = AsyncStream<Bool> { continuation in
      let task = Task { @MainActor in
        #if canImport(UIKit)
          let canOpenURL = UIApplication.shared.canOpenURL(url)
          continuation.yield(canOpenURL)
        #endif
        continuation.finish()
      }
      continuation.onTermination = { @Sendable _ in
        task.cancel()
      }
    }
    return await stream.first(where: { _ in true }) ?? false
  }

  static let testValue = CanOpenURLEffect { _ in
    XCTFail(#"Unimplemented: @Dependency(\.canOpenURL)"#)
    return false
  }
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(iOS 14,tvOS 14, watchOS 7, *)
public struct CanOpenURLEffect: Sendable {
  public init(handler: @escaping @Sendable (URL) async -> Bool) {
    self.handler = handler
  }

  public func callAsFunction(_ url: URL) async -> Bool {
    await handler(url)
  }

  private let handler: @Sendable (URL) async -> Bool
}

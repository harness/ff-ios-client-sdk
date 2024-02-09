import Foundation

@objc public class AnalyticsWrapper : NSObject, Codable {
    
  public var analytics: Analytics
  private var counter: AtomicInt

  init (analytics: Analytics, count: Int) {
      self.analytics = analytics
      self.counter = AtomicInt(0)
  }

  public func increment() {
    counter.increment()
  }

  public func count() -> Int {
    return counter.get()
  }

  private enum CodingKeys : String, CodingKey {
    case analytics
    case counter

  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(count(), forKey: .counter)
    try container.encode(analytics, forKey: .analytics)
  }

  required public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.analytics = try values.decode(Analytics.self, forKey: .analytics)
    let c = try values.decode(Int.self, forKey: .counter)
    self.counter = AtomicInt(c)
  }

}

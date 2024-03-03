// swiftlint:disable all
import Amplify
import Foundation

public struct Event: Model {
  public let id: String
  public var title: String
  public var startDate: Temporal.DateTime
  public var endDate: Temporal.DateTime
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      title: String,
      startDate: Temporal.DateTime,
      endDate: Temporal.DateTime) {
    self.init(id: id,
      title: title,
      startDate: startDate,
      endDate: endDate,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      title: String,
      startDate: Temporal.DateTime,
      endDate: Temporal.DateTime,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.title = title
      self.startDate = startDate
      self.endDate = endDate
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}

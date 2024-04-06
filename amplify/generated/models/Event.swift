// swiftlint:disable all
import Amplify
import Foundation

public struct Event: Model {
  public let id: String
  public var title: String
  public var startTime: Temporal.DateTime
  public var endTime: Temporal.DateTime
  public var createdBy: String
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      title: String,
      startTime: Temporal.DateTime,
      endTime: Temporal.DateTime,
      createdBy: String) {
    self.init(id: id,
      title: title,
      startTime: startTime,
      endTime: endTime,
      createdBy: createdBy,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      title: String,
      startTime: Temporal.DateTime,
      endTime: Temporal.DateTime,
      createdBy: String,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.title = title
      self.startTime = startTime
      self.endTime = endTime
      self.createdBy = createdBy
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}
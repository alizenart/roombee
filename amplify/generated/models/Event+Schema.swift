// swiftlint:disable all
import Amplify
import Foundation

extension Event {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case title
    case startDate
    case endDate
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let event = Event.keys
    
    model.listPluralName = "Events"
    model.syncPluralName = "Events"
    
    model.attributes(
      .primaryKey(fields: [event.id])
    )
    
    model.fields(
      .field(event.id, is: .required, ofType: .string),
      .field(event.title, is: .required, ofType: .string),
      .field(event.startDate, is: .required, ofType: .dateTime),
      .field(event.endDate, is: .required, ofType: .dateTime),
      .field(event.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(event.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Event: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}
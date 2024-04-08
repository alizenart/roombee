// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "9cc31f70d88747b88f27f1c576926c38"
  
  public func registerModels(registry: ModelRegistry.Type) {
//    ModelRegistry.register(modelType: User.self)
    ModelRegistry.register(modelType: Event.self)
  }
}

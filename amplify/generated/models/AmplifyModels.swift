// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "f5b56c456bf797c0e075a15484d76866"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Event.self)
  }
}

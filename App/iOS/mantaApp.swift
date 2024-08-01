import ComposableArchitecture
import AppFeature
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
  let store = Store(initialState: AppReducer.State()) {
    AppReducer()
  }
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    store.send(.appDelegate(.didFinishLaunching))
    return true
  }
}

@main
struct mantaApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  
  var body: some Scene {
    WindowGroup {
      AppView(store: appDelegate.store)
    }
  }
}

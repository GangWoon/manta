import ComposableArchitecture
import NewAndNowFeature
import SwiftUI

@main
struct mantaApp: App {
  var body: some Scene {
    WindowGroup {
      NewAndNowView(
        store: Store(
          initialState: NewAndNowCore.State(),
          reducer: NewAndNowCore.init
        )
      )
    }
  }
}

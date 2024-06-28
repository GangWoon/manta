import ComposableArchitecture
import ApiClient
import SwiftUI

public struct NewAndNowView: View {
  let store: StoreOf<NewAndNowCore>
  
  public init(store: StoreOf<NewAndNowCore>) {
    self.store = store
  }
  
  public var body: some View {
    WithPerceptionTracking {
      VStack {
        dashboard
        HStack {
          
        }
        ScrollView(.vertical, showsIndicators: false) {
          LazyVStack(spacing: 24) {
            ForEach(
              store.scope(state: \.webToonList, action: \.webToonList)
            ) { store in
              WebToonRow(store: store)
            }
          }
        }
      }
      .padding(.horizontal, 16)
      .task { await store.send(.prepare).finish() }
    }
  }
  
  private var dashboard: some View {
    VStack {
      HStack {
        Text("New & Now")
        Spacer()
        Image(systemName: "text.magnifyingglass")
        Image(systemName: "person.crop.circle")
      }
      .font(.system(size: 22).bold())
    }
  }
  
  private func episodesView(_ webtoon: Components.Schemas.NewAndNow.WebToon) -> some View {
    HStack {
      LazyImage(url: webtoon.episodes.first?.thumbnail) { image in
        image
          .resizable()
          .frame(width: 24, height: 24)
          .cornerRadius(6)
      } placeholder: {
        Color.clear
      }

      Text("Binge past seasons")
        .font(.system(size: 14).bold())
        
      Spacer()
      
      Image(systemName: "chevron.down")
        .font(.system(size: 11).bold())
    }
    .foregroundStyle(.white)
    .padding(8)
    .background {
      RoundedRectangle(cornerRadius: 10)
        .fill(Color(hex: webtoon.thumbnailColor))
    }
  }
}

#Preview {
  NewAndNowView(
    store: Store(initialState: NewAndNowCore.State()) {
      NewAndNowCore()
    }
  )
}

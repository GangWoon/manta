import SwiftUI

struct WebToonRow: View {
  @State private var isExpanded: Bool = false
  
  let url: URL?
  let title: String
  let tags: [String]
  let thumbnailColor: String
  let summary: String
  var notifyAction: () -> Void
  
  init(
    url: URL?,
    title: String,
    tags: [String],
    thumbnailColor: String,
    summary: String,
    notifyAction: @escaping () -> Void = { }
  ) {
    self.url = url
    self.title = title
    self.tags = tags
    self.thumbnailColor = thumbnailColor
    self.summary = summary
    self.notifyAction = notifyAction
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Spacer()
      
      Text(title)
        .font(.system(size: 22).bold())
        .foregroundStyle(.white)
      
      VStack(alignment: .leading) {
        tagList
        summaryView
        notifyButton
      }
      .padding(.bottom, 16)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.horizontal, 16)
    .background { dimmingView }
    .background { thumbnail }
  }
  
  private var tagList: some View {
    HStack {
      ForEach(tags, id: \.self) { tag in
        Text("#\(tag)")
      }
    }
    .font(.system(size: 12))
    .foregroundStyle(isExpanded ? .white : Color(hex: "#D3D3D3"))
    .onTapGesture { isExpanded.toggle() }
  }
  
  private var summaryView: some View {
    HStack(alignment: .bottom) {
      Text(summary)
        .lineLimit(isExpanded ? nil : 2)
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
        .transition(.move(edge: .bottom))
      
      if !isExpanded {
        Text("More")
          .foregroundStyle(.white)
          .onTapGesture {
            isExpanded = true
          }
      }
    }
    .animation(.easeInOut, value: isExpanded)
    .font(.system(size: 12))
    .foregroundStyle(isExpanded ? .white : Color(hex: "#D3D3D3"))
    .onTapGesture { isExpanded.toggle() }
  }
  
  private var dimmingView: some View {
    VStack {
      if isExpanded {
        Color.black
          .opacity(0.25)
          .onTapGesture { isExpanded = false }
      }
    }
  }
  
  private var notifyButton: some View {
    Button(action: { notifyAction() }) {
      HStack {
        Image(systemName: "bell")
        Text("Notify me")
          .font(.system(size: 16).bold())
      }
      .foregroundStyle(.white)
      .padding(.vertical, 8)
      .frame(maxWidth: .infinity)
      .background {
        RoundedRectangle(cornerRadius: 8)
          .foregroundColor(Color(hex: "#D3D3D3").opacity(0.6))
      }
    }
  }
  
  private var thumbnail: some View {
    LazyImage(url: url) { image in
      image
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(height: 460)
        .overlay(alignment: .bottom) {
          VStack(spacing: 0) {
            LinearGradient(
              colors: [.clear, Color(hex: thumbnailColor)],
              startPoint: .top,
              endPoint: .bottom
            )
            .frame(height: 120)
            
            Color(hex: thumbnailColor)
              .frame(height: 40)
          }
        }
    } placeholder: {
      Color.clear
    }
  }
}

// MARK: - 유틸로 분리시키기
extension Color {
  init(hex: String) {
    var hexString = hex
    if hexString.hasPrefix("#") {
      hexString = String(hexString.dropFirst())
    }
    
    let scanner = Scanner(string: hexString)
    var rgbValue: UInt64 = 0
    scanner.scanHexInt64(&rgbValue)
    
    let red = Double((rgbValue & 0xff0000) >> 16) / 255.0
    let green = Double((rgbValue & 0x00ff00) >> 8) / 255.0
    let blue = Double(rgbValue & 0x0000ff) / 255.0
    
    self.init(red: red, green: green, blue: blue)
  }
}

#Preview {
  WebToonRow(
    url: URL(string: "https://github.com/GangWoon/manta/assets/48466830/8d4487b9-a8fc-4612-9444-b5c5dc1b19c7"),
    title: "Choose Your Heroes Carefully",
    tags: ["BL", "Fantasy", "Adventure"],
    thumbnailColor: "#5B7AA1",
    summary: "Stuck in a game with a lousy hero? Me too!\nMinjoon, a normal office worker, wakes up inside the game he was reviewing for his friend. It's not his fault the trailer was so boring it put him to sleep! Bewildered, Minjoon is tasked with summoning a hero to guide. The hero certainly looks strong, but he seems to be less useful than expected."
  )
  .frame(height: 460)
}

import Dependencies
import Foundation
@preconcurrency import SQLite

extension LocalDatabaseClient: DependencyKey {
  public static let liveValue: LocalDatabaseClient = {
    live()
  }()
  
  public static func live() -> Self {
    var _db: Connection!
    var db: Connection {
      if _db == nil {
        let path = try! FileManager.default.url(
          for: .documentDirectory,
          in: .userDomainMask,
          appropriateFor: nil,
          create: true
        )
          .appendingPathComponent("db.sqlite3")
          .path
        _db = try? Connection(path)
      }
      return _db
    }
    
    let table = Table("notifications")
    let id: SQLite.Expression<String> = .init("id")
    _ = try? db.run(
      table.create(ifNotExists: true) { t in
        t.column(id, primaryKey: true)
      }
    )
    
    return .init(
      fetchNotifiedWebtoons: {
        return try db.prepare(table)
          .compactMap { UUID(uuidString: $0[id]) }
      },
      saveNotifiedWebtoon:  {
        let uuidString = $0.uuidString
        let insert = table.insert(id <- uuidString)
        try db.run(insert)
      },
      deleteNotifiedWebtoon: {
        let uuidString = $0.uuidString
        let item = table.filter(id == uuidString)
        try db.run(item.delete())
      }
    )
  }
}

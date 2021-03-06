//
//  LocaleDataSource.swift
//  Dolanan.id myGame Catalogue
//
//  Created by Dimas Putro on 20/11/21.
//

import Foundation
import RxSwift
import RealmSwift

protocol LocalDataSourceProtocol: AnyObject {
  func addGameToFavorite(data: GameEntity) -> Observable<Bool>
  func getFavoriteGames() -> Observable<[GameEntity]>
  func removeGameFromFavorite(id: Int) -> Observable<Bool>
  func addUser(data: UserEntity) -> Observable<Bool>
  func getUser() -> Observable<UserEntity>
}

final class LocalDataSource: NSObject {

  private let realm: Realm?

  private init(realm: Realm?) {
    self.realm = realm
  }

  static let sharedInstance: (Realm?) -> LocalDataSource = { db in
    return LocalDataSource(realm: db)
  }
}

extension LocalDataSource: LocalDataSourceProtocol {

  func addGameToFavorite(data: GameEntity) -> Observable<Bool> {
    return Observable<Bool>.create { observer in
      if let localDatabase = self.realm {
        do {
          try localDatabase.write {
            localDatabase.add(data)

            observer.onNext(true)
            observer.onCompleted()
            print("data has beeen saved to local DB")
          }
        } catch {
          observer.onError(DatabaseError.requestFailed)
          print(DatabaseError.requestFailed)
        }
      } else {
        observer.onError(DatabaseError.requestFailed)
        print(DatabaseError.requestFailed)
      }
      return Disposables.create()
    }
  }

  func getFavoriteGames() -> Observable<[GameEntity]> {
    return Observable<[GameEntity]>.create { observer in
      if let localDatabase = self.realm {
        let favoriteGames: Results<GameEntity> = {
          localDatabase.objects(GameEntity.self)
            .sorted(byKeyPath: "id", ascending: false)
        }()
        observer.onNext(favoriteGames.toArray(ofType: GameEntity.self))
        observer.onCompleted()
      } else {
        observer.onError(DatabaseError.invalidInstance)
      }
      return Disposables.create()
    }
  }

  func removeGameFromFavorite(id: Int) -> Observable<Bool> {
    return Observable<Bool>.create { observer in
      if let localDatabase = self.realm {
        do {

          let getObjectById = localDatabase.objects(GameEntity.self).filter("id == %@", id).first

          try localDatabase.write {
            localDatabase.delete(getObjectById!)

            observer.onNext(true)
            observer.onCompleted()
            print("data has beeen deleted to local DB")
          }
        } catch {
          observer.onError(DatabaseError.requestFailed)
          print(DatabaseError.requestFailed)
        }
      } else {
        observer.onError(DatabaseError.requestFailed)
        print(DatabaseError.requestFailed)
      }
      return Disposables.create()
    }
  }

  func addUser(data: UserEntity) -> Observable<Bool> {
    return Observable<Bool>.create { observer in
      if let localDatabase = self.realm {
        do {

          let user = localDatabase.objects(UserEntity.self).filter("id == %@", "0").first

          if let user = user {
            try localDatabase.write {
              user.name = data.name
              user.email = data.email
              user.phoneNumber = data.phoneNumber
              user.website = data.website
              user.githubUrl = data.githubUrl
              user.profilePicture = data.profilePicture

              observer.onNext(true)
              observer.onCompleted()
              print("user has been updated")
            }
          } else {
            try localDatabase.write {
              localDatabase.add(data)

              observer.onNext(true)
              observer.onCompleted()
              print("data has been saved to local DB")
            }
          }
        } catch {
          observer.onError(DatabaseError.requestFailed)
          print(DatabaseError.requestFailed)
        }
      } else {
        observer.onError(DatabaseError.requestFailed)
        print(DatabaseError.requestFailed)
      }
      return Disposables.create()
    }
  }

  func getUser() -> Observable<UserEntity> {
    return Observable<UserEntity>.create { observer in
      if let localDatabase = self.realm {
        let getObjectById = localDatabase.objects(UserEntity.self).filter("id == %@", "0").first

        observer.onNext(getObjectById!)
        observer.onCompleted()
      } else {
        observer.onError(DatabaseError.requestFailed)
        print(DatabaseError.requestFailed)
      }
      return Disposables.create()
    }
  }

}

extension Results {

  func toArray<T>(ofType: T.Type) -> [T] {
    var array = [T]()
    for index in 0 ..< count {
      if let result = self[index] as? T {
        array.append(result)
      }
    }
    return array
  }

}

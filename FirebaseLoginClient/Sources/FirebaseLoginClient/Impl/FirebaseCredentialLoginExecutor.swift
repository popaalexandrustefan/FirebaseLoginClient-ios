//
//  FirebaseCredentialLoginExecutor.swift
//  FirebaseAuthClient
//
//  Created by Alexandru Popa on 30.09.2022.
//

import Foundation

import Combine
import FirebaseAuth
import FirebaseAuthCombineSwift
import Foundation

protocol CredentialLoginExecutor {
  func executeCredentialBasedLogin(
    provider providerId: String,
    idToken: String,
    nonce: String,
    givenName: String?,
    familyName: String?
  ) -> AnyPublisher<Void, Error>
}

class FirebaseLoginExecutorImpl: CredentialLoginExecutor {  
  private let firebaseAuth: Auth
  private let nameStorageOptions: FirebaseDisplayNameStorageOptions
  
  init(firebaseAuth: Auth, nameStorageOptions: FirebaseDisplayNameStorageOptions) {
    self.firebaseAuth = firebaseAuth
    self.nameStorageOptions = nameStorageOptions
    let changeRequest = firebaseAuth.currentUser?.createProfileChangeRequest()
//    changeRequest?.displayName
    changeRequest?.commitChanges()
  }
  
  func executeCredentialBasedLogin(
    provider providerId: String,
    idToken: String,
    nonce: String,
    givenName: String?,
    familyName: String?
  ) -> AnyPublisher<Void, Error> {
    let credential = OAuthProvider.credential(
      withProviderID: providerId,
      idToken: idToken,
      rawNonce: nonce
    )
    
    let displayName = nameStorageOptions.buildDisplayName(with: givenName, familyName: familyName)
    
    return firebaseAuth
      .signIn(with: credential)
      .flatMap {
        guard let displayName = displayName else {
          return Empty<Void, Error>().eraseToAnyPublisher()
        }
        return $0.user.updateDisplayName(to: displayName) }
      .eraseToAnyPublisher()
    
  }
}

private extension User {
  func updateDisplayName(to newDisplayName: String) -> AnyPublisher<Void, Error> {
    let request = createProfileChangeRequest()
    return Future<Void, Error> { promise in
      request.displayName = newDisplayName
      request.commitChanges { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}

extension FirebaseDisplayNameStorageOptions {
  func buildDisplayName(with givenName: String?, familyName: String?) -> String? {
    guard
      let givenName = givenName,
      let familyName = familyName
    else { return nil }
    
    switch (contains(.givenName), contains(.familyName)) {
    case (true, true):
      return "\(givenName) \(familyName)"
    case (true, false):
      return givenName
    case (false, true):
      return familyName
    case (false, false):
      assertionFailure("Empty FirebaseDisplayNameStorageOptions")
      return nil
    }
  }
}

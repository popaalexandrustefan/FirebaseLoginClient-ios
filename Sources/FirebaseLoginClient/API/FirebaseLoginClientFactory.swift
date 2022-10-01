//
//  FirebaseLoginServiceFactory.swift
//  FirebaseAuthClient
//
//  Created by Alexandru Popa on 01.10.2022.
//

import FirebaseAuth

public struct FirebaseLoginClientFactory {
  public static func make(
    firebaseAuth: Auth = .auth(),
    displayNameStorageOptions: FirebaseDisplayNameStorageOptions = .fullName
  ) -> FirebaseLoginClient {
    FirebaseLoginClientImpl(firebaseAuth: firebaseAuth, displayNameStorageOptions: displayNameStorageOptions)
  }
}

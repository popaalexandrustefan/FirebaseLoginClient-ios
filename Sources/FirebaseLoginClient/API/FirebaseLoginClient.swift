//
//  FirebaseLoginClient.swift
//  FirebaseAuthClient
//
//  Created by Alexandru Popa on 29.09.2022.
//

import Combine
import Foundation

public enum FirebaseLoginError: Error {
  case appleLoginError(AppleLoginHandlerError)
  case failedToLogout(Error)
}

public protocol FirebaseLoginClient {
  var state: AnyPublisher<LoginState, Never> { get }
  var error: AnyPublisher<FirebaseLoginError, Never> { get }
  func makeAppleLoginHandler() -> AppleLoginHandler
  func logout()
}

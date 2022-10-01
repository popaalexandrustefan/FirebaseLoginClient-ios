//
//  FirebaseLoginClientImpl.swift
//  FirebaseAuthClient
//
//  Created by Alexandru Popa on 29.09.2022.
//

import Combine
import FirebaseAuth
import FirebaseAuthCombineSwift
import Foundation

private extension LoginState {
  init(user: User?) {
    guard let user = user else {
      self = .notLoggedIn
      return
    }
    self = .loggedIn(user)
  }
}

class FirebaseLoginClientImpl: FirebaseLoginClient {
  private var disposeBag = [AnyCancellable]()
  private let displayNameStorageOptions: FirebaseDisplayNameStorageOptions
  private let credentialLoginExecutor: CredentialLoginExecutor
  private let firebaseAuth: Auth
  
  private let errorSubject = PassthroughSubject<FirebaseLoginError, Never>()
  var error: AnyPublisher<FirebaseLoginError, Never> {
    errorSubject.eraseToAnyPublisher()
  }
  
  private let stateSubject = CurrentValueSubject<LoginState, Never>(.undetermined)
  var state: AnyPublisher<LoginState, Never> {
    stateSubject.eraseToAnyPublisher()
  }
  
  init(
    firebaseAuth: Auth,
    displayNameStorageOptions: FirebaseDisplayNameStorageOptions
  ) {
    self.firebaseAuth = firebaseAuth
    self.displayNameStorageOptions = displayNameStorageOptions
    self.credentialLoginExecutor = FirebaseLoginExecutorImpl(
      firebaseAuth: firebaseAuth,
      nameStorageOptions: displayNameStorageOptions
    )
    
    firebaseAuth
      .authStateDidChangePublisher()
      .map(LoginState.init(user:))
      .subscribe(stateSubject)
      .store(in: &disposeBag)
  }
  
  func logout() {
    do {
      try firebaseAuth.signOut()
    } catch {
      errorSubject.send(.failedToLogout(error))
    }
  }
  
  func makeAppleLoginHandler() -> AppleLoginHandler {
    let loginHandler = AppleLoginHandlerImpl(credentialLoginExecutor: credentialLoginExecutor)
    loginHandler.error
      .map { FirebaseLoginError.appleLoginError($0) }
      .subscribe(errorSubject)
      .store(in: &disposeBag)
    return loginHandler
  }
}

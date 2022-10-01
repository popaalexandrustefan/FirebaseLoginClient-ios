//
//  AppleLoginHandlerImpl.swift
//  FirebaseAuthClient
//
//  Created by Alexandru Popa on 30.09.2022.
//

import AuthenticationServices
import Combine
import Foundation

class AppleLoginHandlerImpl: AppleLoginHandler {
  private var executorCancellable: AnyCancellable?
  private let credentialLoginExecutor: CredentialLoginExecutor
  private let nonceGenerator = NonceGenerator()
  private var currentNonce: String?
  
  private let errorSubject = PassthroughSubject<AppleLoginHandlerError, Never>()
  
  var error: AnyPublisher<AppleLoginHandlerError, Never> {
    errorSubject.eraseToAnyPublisher()
  }
  
  init(credentialLoginExecutor: CredentialLoginExecutor) {
    self.credentialLoginExecutor = credentialLoginExecutor
  }
  
  func prepareRequest(_ request: ASAuthorizationAppleIDRequest) {
    let nonce = nonceGenerator.generateRandomNonce()
    currentNonce = nonce
    request.requestedScopes = [.fullName, .email]
    request.nonce = nonce.sha256Hash
  }
  
  func handleResult(_ result: Result<ASAuthorization, Error>) {
    guard
      case let .success(authResults) = result,
      let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential
    else {
      if case let .failure(error) = result {
        errorSubject.send(.appleError(error))
      } else {
        errorSubject.send(.unknown)
      }
      return
    }
    
    guard let nonce = currentNonce else {
      errorSubject.send(.invalidNonce)
      return
    }
    guard
      let appleIDToken = appleIDCredential.identityToken,
      let stringifiedToken = String(data: appleIDToken, encoding: .utf8)
    else {
      errorSubject.send(.invalidTokenReceived(appleIDCredential.identityToken))
      return
    }
    
    executorCancellable = credentialLoginExecutor
      .executeCredentialBasedLogin(
        provider: "apple.com",
        idToken: stringifiedToken,
        nonce: nonce,
        givenName: appleIDCredential.fullName?.givenName,
        familyName: appleIDCredential.fullName?.familyName
      )
      .sink(
        receiveCompletion: { [errorSubject] completion in
          guard case let .failure(error) = completion else { return }
          errorSubject.send(.loginExecutorError(error))
        },
        receiveValue: {}
      )
  }
}

private extension ASAuthorizationAppleIDCredential {
  var name: String? {
    guard
      let givenName = self.fullName?.givenName,
      let familyName = self.fullName?.familyName
    else { return nil }
    
    return "\(givenName) \(familyName)"
  }
}

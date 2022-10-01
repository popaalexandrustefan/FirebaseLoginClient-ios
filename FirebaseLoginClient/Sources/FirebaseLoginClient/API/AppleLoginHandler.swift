//
//  AppleLoginHandler.swift
//  FirebaseAuthClient
//
//  Created by Alexandru Popa on 30.09.2022.
//

import AuthenticationServices
import Combine
import Foundation

public enum AppleLoginHandlerError: Error {
  case unknown
  case appleError(Error)
  case invalidNonce
  case invalidTokenReceived(Data?)
  case loginExecutorError(Error)
}

public protocol AppleLoginHandler {
  func prepareRequest(_ request: ASAuthorizationAppleIDRequest)
  func handleResult(_ result: Result<ASAuthorization, Error>)
}

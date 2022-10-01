//
//  LoginState.swift
//  FirebaseAuthClient
//
//  Created by Alexandru Popa on 29.09.2022.
//

import FirebaseAuth
import Foundation

public enum LoginState {
  case undetermined
  case loggedIn(User)
  case notLoggedIn
}

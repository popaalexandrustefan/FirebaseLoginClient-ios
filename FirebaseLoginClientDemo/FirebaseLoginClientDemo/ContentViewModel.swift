//
//  ContentViewModel.swift
//  FirebaseAuthClientDemo
//
//  Created by Alexandru Popa on 30.09.2022.
//

import Combine
import Foundation
import FirebaseLoginClient

final class ContentViewModel: ObservableObject {
  private var cancellables = [AnyCancellable]()
  let loginService = FirebaseLoginClientFactory.make()
  let appleLogin: AppleLoginHandler
  @Published var state: LoginState = .undetermined
  @Published var error: FirebaseLoginError?
  
  init() {
    self.appleLogin = loginService.makeAppleLoginHandler()
    loginService.state
      .sink { [weak self] state in
        self?.state = state
        guard case let .loggedIn(user) = state else { return }
        print(user)
      }
      .store(in: &cancellables)
    
    loginService.error
      .map { Optional($0) }
      .assign(to: \.error, on: self)
      .store(in: &cancellables)
  }
}

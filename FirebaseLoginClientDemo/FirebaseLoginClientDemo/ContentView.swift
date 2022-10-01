//
//  ContentView.swift
//  FirebaseAuthClientDemo
//
//  Created by Alexandru Popa on 29.09.2022.
//

import AuthenticationServices
import Combine
import FirebaseLoginClient
import SwiftUI

struct ContentView: View {
  @ObservedObject var viewModel: ContentViewModel
  
  
  var body: some View {
    VStack(spacing: 20) {
      switch viewModel.state {
      case .undetermined:
        ProgressView("Determining state...")
          .progressViewStyle(.circular)
      case .notLoggedIn:
        VStack(spacing: 20) {
          Text("Not logged in")
          loginButton
        }
      case let .loggedIn(user):
        VStack(spacing: 20) {
          Text("Logged in")
          Text("Name: \(String(describing: user.displayName))")
          Text("email: \(String(describing: user.email))")
    
          Button("Logout") {
            viewModel.loginService.logout()
          }
        }
      }
    }
    .padding()
    .alert(
      isPresented: .init(
        get: { viewModel.error != nil },
        set: { newValue in
          guard newValue == false else { return }
          viewModel.error = nil
        }
      )) {
        Alert(
          title: Text("Error"),
          message: Text(viewModel.error?.localizedDescription ?? "No Error")
        )
      }
  }
}

private extension ContentView {
  var loginButton: some View {
    SignInWithAppleButton(
      onRequest: viewModel.appleLogin.prepareRequest(_:),
      onCompletion: viewModel.appleLogin.handleResult(_:)
    )
    .frame(width: 280, height: 45, alignment: .center)
    .cornerRadius(5)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(viewModel: .init())
  }
}

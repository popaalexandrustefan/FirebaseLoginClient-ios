//
//  DisplayNameStorageOptions.swift
//  FirebaseAuthClient
//
//  Created by Alexandru Popa on 01.10.2022.
//

import Foundation

public struct FirebaseDisplayNameStorageOptions: OptionSet {
  public let rawValue: Int
  public static let givenName = FirebaseDisplayNameStorageOptions(rawValue: 1 << 0)
  public static let familyName = FirebaseDisplayNameStorageOptions(rawValue: 1 << 1)
  public static let fullName: FirebaseDisplayNameStorageOptions = [.givenName, .familyName]
  
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}

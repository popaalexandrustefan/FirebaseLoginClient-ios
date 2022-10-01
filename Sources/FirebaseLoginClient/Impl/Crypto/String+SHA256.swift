//
//  String+SHA256.swift
//  BetterAlarm
//
//  Created by Alexandru Popa on 07.08.2022.
//

import CryptoKit
import Foundation

extension String {
  var sha256Hash: String {
    SHA256.hash(data: Data(utf8))
      .compactMap { String(format: "%02x", $0) }
      .joined()
  }
}

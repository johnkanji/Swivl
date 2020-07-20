//  ArrayExtensions.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Array {

  func any(where predicate: (Element) throws -> Bool) rethrows -> Bool {
    try self.first(where: predicate) != nil
  }

  func find(where predicate: (Element) throws -> Bool) rethrows -> IndexSet {
    try IndexSet(self.enumerated().filter({ try predicate($0.1) }).map({ $0.0 }))
  }

}

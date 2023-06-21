//
//  Functions.swift
//  Location
//
//  Created by Iwy2th on 21/06/2023.
//

import Foundation
func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

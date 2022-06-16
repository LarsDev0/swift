// RUN: %target-typecheck-verify-swift -I %S/Inputs -enable-experimental-cxx-interop
//
// REQUIRES: OS=macosx || OS=linux-gnu

import CustomSequence
import std

// === SimpleSequence ===

extension SimpleSequence.ConstIterator: UnsafeCxxInputIterator {
  // This should probably be synthesized from operator++.
  public func successor() -> Self {
    return SimpleSequence.ConstIterator(pointee + 1)
  }

  // This shouldn't be required, since operator== is defined on the C++ side.
  // However, without this decl it fails to typecheck, likely due to a lookup issue.
  public static func ==(lhs: SimpleSequence.ConstIterator, rhs: SimpleSequence.ConstIterator) -> Bool {
    return lhs.pointee == rhs.pointee
  }
}

extension SimpleSequence: CxxSequence {}

func checkSimpleSequence() {
  let seq = SimpleSequence()
  let contains = seq.contains(where: { $0 == 3 })
  print(contains)

  for item in seq {
    print(item)
  }
}

// === SimpleArrayWrapper ===

// No UnsafeCxxInputIterator conformance required, since the iterators are actually UnsafePointers here.

extension SimpleArrayWrapper: CxxSequence {}

func checkSimpleArrayWrapper() {
  let seq = SimpleArrayWrapper()
  let contains = seq.contains(where: { $0 == 25 })
  print(contains)

  for item in seq {
    print(item)
  }
}

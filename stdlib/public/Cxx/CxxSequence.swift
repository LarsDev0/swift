//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

/// Bridged C++ iterator that allows to traverse the elements of a sequence using a for-in loop.
///
/// Mostly useful for conforming a type to the `CxxSequence` protocol and should not generally be used directly.
///
/// - SeeAlso: https://en.cppreference.com/w/cpp/named_req/InputIterator
public protocol UnsafeCxxInputIterator: Equatable {
  associatedtype Pointee

  /// Returns the unwrapped result of C++ `operator*()`.
  ///
  /// Generally, Swift creates this property automatically for C++ types that define `operator*()`.
  var pointee: Pointee { get }

  /// Returns an iterator pointing to the next item in the sequence.
  func successor() -> Self
}

extension UnsafePointer: UnsafeCxxInputIterator {}

extension UnsafeMutablePointer: UnsafeCxxInputIterator {}

public protocol CxxSequence: Sequence {
  associatedtype RawIterator: UnsafeCxxInputIterator
  associatedtype Element = RawIterator.Pointee
  func begin() -> RawIterator
  func end() -> RawIterator
}

public struct CxxIterator<T>: IteratorProtocol where T: CxxSequence {
  public typealias Element = T.RawIterator.Pointee
  private let sequence: T
  private var rawIterator: T.RawIterator

  public init(sequence: T, rawIterator: T.RawIterator) {
    self.sequence = sequence
    self.rawIterator = rawIterator
  }

  public mutating func next() -> Element? {
    // TODO: Should `sequence.end()` be stored in a field of this struct?
    // That would change the semantics if someone creates an iterator, and then modifies the sequence.
    if self.rawIterator == self.sequence.end() {
      return nil
    }
    let object = self.rawIterator.pointee
    self.rawIterator = self.rawIterator.successor()
    return object
  }
}

extension CxxSequence {
  public func makeIterator() -> CxxIterator<Self> {
    return CxxIterator(sequence: self, rawIterator: begin())
  }
}

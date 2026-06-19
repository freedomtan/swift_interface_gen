public struct MyStruct { @_lifetime(borrow self) public func test(startingAt: inout Array<Int>) -> Span<Any> { fatalError() } }

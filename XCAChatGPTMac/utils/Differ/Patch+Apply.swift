public extension RangeReplaceableCollection {
    /// Applies the changes described by the provided patches to a copy of this collection and returns the result.
    ///
    /// - Parameter patches: a collection of ``Patch`` instances to apply.
    /// - Returns: A copy of the current collection with the provided patches applied to it.
    func apply<C: Collection>(_ patches: C) -> Self where C.Element == Patch<Element> {
        var mutableSelf = self

        for patch in patches {
            switch patch {
                case let .insertion(i, element):
                    let target = mutableSelf.index(mutableSelf.startIndex, offsetBy: i)
                    mutableSelf.insert(element, at: target)
                case let .deletion(i):
                    let target = mutableSelf.index(mutableSelf.startIndex, offsetBy: i)
                    mutableSelf.remove(at: target)
            }
        }

        return mutableSelf
    }
}

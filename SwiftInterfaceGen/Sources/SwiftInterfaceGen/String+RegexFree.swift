import Foundation

extension String {
    // 1. stripLongNumbers: removes any sequence of 5 or more consecutive digits.
    func stripLongNumbers() -> String {
        var result = ""
        let chars = Array(self)
        var i = 0
        let n = chars.count
        while i < n {
            if chars[i].isNumber {
                let start = i
                while i < n && chars[i].isNumber {
                    i += 1
                }
                let length = i - start
                if length < 5 {
                    result.append(contentsOf: chars[start..<i])
                }
                continue
            }
            result.append(chars[i])
            i += 1
        }
        return result
    }

    // 2. replaceWord: replaces whole word occurrences of `word` with `replacement`.
    func replaceWord(_ word: String, with replacement: String, allowPrecededByDot: Bool = true, allowFollowedByDot: Bool = true) -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: word, range: startSearch..<result.endIndex) {
            let isWordCharBefore: Bool
            var precededByDot = false
            if range.lowerBound > result.startIndex {
                let prevChar = result[result.index(before: range.lowerBound)]
                isWordCharBefore = prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$"
                if prevChar == "." {
                    precededByDot = true
                }
            } else {
                isWordCharBefore = false
            }
            
            let isWordCharAfter: Bool
            var followedByDot = false
            if range.upperBound < result.endIndex {
                let nextChar = result[range.upperBound]
                isWordCharAfter = nextChar.isLetter || nextChar.isNumber || nextChar == "_" || nextChar == "$"
                if nextChar == "." {
                    followedByDot = true
                }
            } else {
                isWordCharAfter = false
            }
            
            let shouldReplace = !isWordCharBefore && !isWordCharAfter && (allowPrecededByDot || !precededByDot) && (allowFollowedByDot || !followedByDot)
            if shouldReplace {
                result.replaceSubrange(range, with: replacement)
                if replacement.isEmpty {
                    startSearch = range.lowerBound
                } else {
                    startSearch = result.index(range.lowerBound, offsetBy: replacement.count, limitedBy: result.endIndex) ?? result.endIndex
                }
            } else {
                startSearch = range.upperBound
            }
        }
        return result
    }

    // 3. replaceWordDot: replaces whole word `word` followed by dot, e.g. `\bword\.` with `replacement`.
    func replaceWordDot(_ word: String, with replacement: String) -> String {
        var result = self
        let target = word + "."
        var startSearch = result.startIndex
        while let range = result.range(of: target, range: startSearch..<result.endIndex) {
            let isWordCharBefore: Bool
            if range.lowerBound > result.startIndex {
                let prevChar = result[result.index(before: range.lowerBound)]
                isWordCharBefore = prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$"
            } else {
                isWordCharBefore = false
            }
            
            if !isWordCharBefore {
                result.replaceSubrange(range, with: replacement)
                if replacement.isEmpty {
                    startSearch = range.lowerBound
                } else {
                    startSearch = result.index(range.lowerBound, offsetBy: replacement.count, limitedBy: result.endIndex) ?? result.endIndex
                }
            } else {
                startSearch = range.upperBound
            }
        }
        return result
    }

    // 4. replaceDotWord: replaces `\.word\b` with `replacement`.
    func replaceDotWord(word: String, replacement: String) -> String {
        var result = self
        let target = "." + word
        var startSearch = result.startIndex
        while let range = result.range(of: target, range: startSearch..<result.endIndex) {
            let afterIdx = range.upperBound
            let isWordCharAfter: Bool
            if afterIdx < result.endIndex {
                let nextChar = result[afterIdx]
                isWordCharAfter = nextChar.isLetter || nextChar.isNumber || nextChar == "_" || nextChar == "$"
            } else {
                isWordCharAfter = false
            }
            
            if !isWordCharAfter {
                result.replaceSubrange(range, with: replacement)
                startSearch = result.index(range.lowerBound, offsetBy: replacement.count, limitedBy: result.endIndex) ?? result.endIndex
            } else {
                startSearch = range.upperBound
            }
        }
        return result
    }

    // 5. replaceWordWithoutGeneric: replaces `\bword\b(?!<)` or `(?![<])` with `replacement`.
    func replaceWordWithoutGeneric(_ word: String, with replacement: String, allowPrecededByDot: Bool = true) -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: word, range: startSearch..<result.endIndex) {
            let isWordCharBefore: Bool
            if range.lowerBound > result.startIndex {
                let prevChar = result[result.index(before: range.lowerBound)]
                isWordCharBefore = prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$" || (!allowPrecededByDot && prevChar == ".")
            } else {
                isWordCharBefore = false
            }
            
            let isWordCharAfter: Bool
            if range.upperBound < result.endIndex {
                let nextChar = result[range.upperBound]
                isWordCharAfter = nextChar.isLetter || nextChar.isNumber || nextChar == "_" || nextChar == "$"
            } else {
                isWordCharAfter = false
            }
            
            let followedByGeneric = (range.upperBound < result.endIndex && result[range.upperBound] == "<")
            
            if !isWordCharBefore && !isWordCharAfter && !followedByGeneric {
                result.replaceSubrange(range, with: replacement)
                startSearch = result.index(range.lowerBound, offsetBy: replacement.count, limitedBy: result.endIndex) ?? result.endIndex
            } else {
                startSearch = range.upperBound
            }
        }
        return result
    }

    // 6. replaceTrailingDigitsAfterParen: replaces `\)[0-9]+` with `)`.
    func replaceTrailingDigitsAfterParen() -> String {
        var result = ""
        let chars = Array(self)
        var i = 0
        let n = chars.count
        while i < n {
            result.append(chars[i])
            if chars[i] == ")" {
                i += 1
                while i < n && chars[i].isNumber {
                    i += 1
                }
                continue
            }
            i += 1
        }
        return result
    }

    // 7. stripModuleBeforeSubscriptOrGeneric: replaces `[a-zA-Z0-9_$]+\.\[` with `[` and `[a-zA-Z0-9_$]+\.<` with `<`.
    func stripModuleBeforeSubscriptOrGeneric() -> String {
        var result = self
        let targets = [".[", ".<"]
        for target in targets {
            var startSearch = result.startIndex
            while let dotRange = result.range(of: target, range: startSearch..<result.endIndex) {
                let dotIdx = dotRange.lowerBound
                var startIdx = dotIdx
                while startIdx > result.startIndex {
                    let prevIdx = result.index(before: startIdx)
                    let char = result[prevIdx]
                    let isIdent = char.isLetter || char.isNumber || char == "_" || char == "$"
                    if !isIdent {
                        break
                    }
                    startIdx = prevIdx
                }
                if startIdx < dotIdx {
                    result.replaceSubrange(startIdx...dotIdx, with: "")
                    startSearch = startIdx
                } else {
                    result.replaceSubrange(dotIdx...dotIdx, with: "")
                    startSearch = dotIdx
                }
            }
        }
        return result
    }

    // 8. stripParenthesesAroundAsyncThrows: strips unnecessary parentheses around async/throws keywords.
    func stripParenthesesAroundAsyncThrows() -> String {
        var result = self
        while let range = result.range(of: "(async throws") {
            let startIdx = range.lowerBound
            var endIdx = range.upperBound
            while endIdx < result.endIndex && result[endIdx].isWhitespace {
                endIdx = result.index(after: endIdx)
            }
            if endIdx < result.endIndex && result[endIdx] == ")" {
                result.replaceSubrange(startIdx...endIdx, with: "async throws")
            } else {
                break
            }
        }
        while let range = result.range(of: "(async") {
            let afterRange = result.index(range.upperBound, offsetBy: 7, limitedBy: result.endIndex)
            if let after = afterRange, result[range.upperBound..<after] == " throws" {
                break
            }
            let startIdx = range.lowerBound
            var endIdx = range.upperBound
            while endIdx < result.endIndex && result[endIdx].isWhitespace {
                endIdx = result.index(after: endIdx)
            }
            if endIdx < result.endIndex && result[endIdx] == ")" {
                result.replaceSubrange(startIdx...endIdx, with: "async")
            } else {
                break
            }
        }
        while let range = result.range(of: "(throws") {
            let startIdx = range.lowerBound
            var endIdx = range.upperBound
            while endIdx < result.endIndex && result[endIdx].isWhitespace {
                endIdx = result.index(after: endIdx)
            }
            if endIdx < result.endIndex && result[endIdx] == ")" {
                result.replaceSubrange(startIdx...endIdx, with: "throws")
            } else {
                break
            }
        }
        return result
    }

    // 9. stripExtensionInNamespacePrefix: replaces `\(extension in [^)]+\):` with `""`.
    func stripExtensionInNamespacePrefix() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: "(extension in ", range: startSearch..<result.endIndex) {
            let startIdx = range.lowerBound
            var scanIdx = range.upperBound
            var found = false
            while scanIdx < result.endIndex {
                if result[scanIdx] == ")" {
                    let colIdx = result.index(after: scanIdx)
                    if colIdx < result.endIndex && result[colIdx] == ":" {
                        result.replaceSubrange(startIdx...colIdx, with: "")
                        found = true
                        startSearch = startIdx
                        break
                    }
                }
                scanIdx = result.index(after: scanIdx)
            }
            if !found {
                break
            }
        }
        return result
    }

    // 10. replaceExtensionSubsigWithAny: replaces `\(\bextension\b[^)]+\)` with `"Any"`.
    func replaceExtensionSubsigWithAny() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: "(extension", range: startSearch..<result.endIndex) {
            let startIdx = range.lowerBound
            var scanIdx = range.upperBound
            var found = false
            while scanIdx < result.endIndex {
                if result[scanIdx] == ")" {
                    result.replaceSubrange(startIdx...scanIdx, with: "Any")
                    found = true
                    startSearch = result.index(startIdx, offsetBy: 3, limitedBy: result.endIndex) ?? result.endIndex
                    break
                }
                scanIdx = result.index(after: scanIdx)
            }
            if !found {
                break
            }
        }
        return result
    }

    // 11. replacePlaceholderDotsWithSelf: replaces `\b[A-Z][0-9]?\.` with `"Self."` or `"Any"` depending on validAssoc.
    // A path like `A.LocalService.Interface` refers to a genuine associated type (`LocalService`) followed
    // by one of ITS members (`Interface`) — only the `A` head should become `Self`, leaving `.Interface` as-is.
    // A path like `A.AssetBackedResource.CatalogAssetType` is instead a self-referential repeat of the
    // conforming type's own name before the real associated type — here the whole path collapses using the
    // LAST segment, since the first segment isn't a real associated type and can't be kept dangling.
    func replacePlaceholderDotsWithSelf(validAssoc: Set<String>? = nil) -> String {
        guard let regex = try? NSRegularExpression(pattern: "\\b(A|Self)((?:\\.[A-Za-z0-9_]+)+)\\b", options: []) else {
            return self
        }

        let nsString = self as NSString
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))

        var result = self
        for match in matches.reversed() {
            let pathRange = match.range(at: 2)
            let fullRange = match.range

            let path = nsString.substring(with: pathRange)
            let segments = path.split(separator: ".").map(String.init)
            let firstSegment = segments.first ?? ""
            let lastSegment = segments.last ?? ""

            let replacement: String
            if let valid = validAssoc {
                if valid.contains(firstSegment) {
                    replacement = "Self" + path
                } else if valid.contains(lastSegment) {
                    replacement = "Self." + lastSegment
                } else {
                    replacement = "Any"
                }
            } else {
                replacement = "Self" + path
            }

            if let r = Range(fullRange, in: result) {
                result.replaceSubrange(r, with: replacement)
            }
        }
        return result
    }

    // 12. replaceMultiSegmentSelfPathsWithAny: replaces `\bSelf\.[a-zA-Z0-9_$]+\.[a-zA-Z0-9_$]+(?:\.[a-zA-Z0-9_$]+)*\b` with `"Any"`.
    func replaceMultiSegmentSelfPathsWithAny() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: "Self.", range: startSearch..<result.endIndex) {
            let isWordCharBefore: Bool
            if range.lowerBound > result.startIndex {
                let prevChar = result[result.index(before: range.lowerBound)]
                isWordCharBefore = prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$"
            } else {
                isWordCharBefore = false
            }
            
            if isWordCharBefore {
                startSearch = range.upperBound
                continue
            }
            
            var scanIdx = range.upperBound
            var componentsCount = 0
            var inIdentifier = false
            
            while scanIdx < result.endIndex {
                let char = result[scanIdx]
                let isIdentChar = char.isLetter || char.isNumber || char == "_" || char == "$"
                if isIdentChar {
                    if !inIdentifier {
                        inIdentifier = true
                    }
                    scanIdx = result.index(after: scanIdx)
                } else if char == "." {
                    if inIdentifier {
                        componentsCount += 1
                        inIdentifier = false
                        scanIdx = result.index(after: scanIdx)
                    } else {
                        break
                    }
                } else {
                    break
                }
            }
            if inIdentifier {
                componentsCount += 1
            }
            
            if componentsCount >= 2 {
                let endPathIdx = inIdentifier ? scanIdx : result.index(before: scanIdx)
                let matchedPath = String(result[range.lowerBound..<endPathIdx])
                let components = matchedPath.components(separatedBy: ".")
                let lastComponent = components.last ?? ""
                if ["CatalogAssetType", "LocalService", "RemoteService", "Service", "ModelType", "TokenizerType", "Interface", "SchedulerTimeType", "Stride"].contains(lastComponent) {
                    let allowedTypes = ["CatalogAssetType", "LocalService", "RemoteService", "Service", "ModelType", "TokenizerType", "Interface", "SchedulerTimeType", "Stride"]
                    let suffixComponents = Array(components.dropFirst())
                    let allAllowed = suffixComponents.allSatisfy { allowedTypes.contains($0) }
                    if allAllowed {
                        let sub = suffixComponents.joined(separator: ".")
                        result.replaceSubrange(range.lowerBound..<endPathIdx, with: "Self.\(sub)")
                        startSearch = result.index(range.lowerBound, offsetBy: 5 + sub.count, limitedBy: result.endIndex) ?? result.endIndex
                    } else {
                        result.replaceSubrange(range.lowerBound..<endPathIdx, with: "Self.\(lastComponent)")
                        startSearch = result.index(range.lowerBound, offsetBy: 5 + lastComponent.count, limitedBy: result.endIndex) ?? result.endIndex
                    }
                } else {
                    result.replaceSubrange(range.lowerBound..<endPathIdx, with: "Any")
                    startSearch = result.index(range.lowerBound, offsetBy: 3, limitedBy: result.endIndex) ?? result.endIndex
                }
            } else {
                startSearch = range.upperBound
            }
        }
        return result
    }

    // 13. replaceGenericPlaceholderPathsWithAny: replaces `\b[A-Z][0-9]?\.[a-zA-Z0-9_$]+(?:\.[a-zA-Z0-9_$]+)*\b` with `"Any"`.
    func replaceGenericPlaceholderPathsWithAny(inScope: Set<String> = []) -> String {
        var result = self
        var startSearch = result.startIndex
        while startSearch < result.endIndex {
            guard let dotIdx = result[startSearch...].firstIndex(of: ".") else { break }
            
            let checkIdx = dotIdx
            var matchedPrefix = false
            var prefixStartIdx = dotIdx
            
            if checkIdx > result.startIndex {
                let prevIdx = result.index(before: checkIdx)
                let prevChar = result[prevIdx]
                if prevChar.isNumber {
                    if prevIdx > result.startIndex {
                        let prevPrevIdx = result.index(before: prevIdx)
                        let prevPrevChar = result[prevPrevIdx]
                        if prevPrevChar.isUppercase {
                            let isWordCharBefore: Bool
                            if prevPrevIdx > result.startIndex {
                                let beforeChar = result[result.index(before: prevPrevIdx)]
                                isWordCharBefore = beforeChar.isLetter || beforeChar.isNumber || beforeChar == "_" || beforeChar == "$"
                            } else {
                                isWordCharBefore = false
                            }
                            if !isWordCharBefore {
                                matchedPrefix = true
                                prefixStartIdx = prevPrevIdx
                            }
                        }
                    }
                } else if prevChar.isUppercase {
                    let isWordCharBefore: Bool
                    if prevIdx > result.startIndex {
                        let beforeChar = result[result.index(before: prevIdx)]
                        isWordCharBefore = beforeChar.isLetter || beforeChar.isNumber || beforeChar == "_" || beforeChar == "$"
                    } else {
                        isWordCharBefore = false
                    }
                    if !isWordCharBefore {
                        matchedPrefix = true
                        prefixStartIdx = prevIdx
                    }
                }
            }
            
            if matchedPrefix {
                var scanIdx = result.index(after: dotIdx)
                var componentsCount = 0
                var inIdentifier = false
                
                while scanIdx < result.endIndex {
                    let char = result[scanIdx]
                    let isIdentChar = char.isLetter || char.isNumber || char == "_" || char == "$"
                    if isIdentChar {
                        if !inIdentifier {
                            inIdentifier = true
                        }
                        scanIdx = result.index(after: scanIdx)
                    } else if char == "." {
                        if inIdentifier {
                            componentsCount += 1
                            inIdentifier = false
                            scanIdx = result.index(after: scanIdx)
                        } else {
                            break
                        }
                    } else {
                        break
                    }
                }
                if inIdentifier {
                    componentsCount += 1
                }
                
                if componentsCount >= 1 {
                    let endPathIdx = inIdentifier ? scanIdx : result.index(before: scanIdx)
                    let matchedPath = String(result[prefixStartIdx..<endPathIdx])
                    let components = matchedPath.components(separatedBy: ".")
                    let lastComponent = components.last ?? ""
                    let prefix = String(result[prefixStartIdx..<dotIdx])
                    
                    let allowedTypes = ["CatalogAssetType", "LocalService", "RemoteService", "Service", "ModelType", "TokenizerType", "Interface", "Type", "Element", "Index", "Iterator", "SubSequence", "EventType", "Stream", "Failure", "Output", "Input", "FormatInput", "FormatOutput", "Content", "SchedulerTimeType", "Stride", "RawSignificand", "RawValue", "WrappedElement", "Bound", "Result", "Body", "Indices", "SchedulerOptions", "Exponent", "Scalar", "Swift"]
                    let suffixComponents = Array(components.dropFirst())
                    let allAllowed = suffixComponents.allSatisfy { allowedTypes.contains($0) }
                    
                    var basePrefix = prefix
                    while let last = basePrefix.last, last.isNumber {
                        basePrefix = String(basePrefix.dropLast())
                    }
                    if inScope.contains(prefix) || inScope.contains(basePrefix) {
                        let actualPrefix = inScope.contains(prefix) ? prefix : basePrefix
                        if allAllowed {
                            let sub = suffixComponents.joined(separator: ".")
                            result.replaceSubrange(prefixStartIdx..<endPathIdx, with: "\(actualPrefix).\(sub)")
                            startSearch = result.index(prefixStartIdx, offsetBy: actualPrefix.count + 1 + sub.count, limitedBy: result.endIndex) ?? result.endIndex
                        } else {
                            // Associated-type path like A.EventType or A.Stream cannot be expressed
                            // without the protocol constraint. Replace with Any for mock interfaces.
                            result.replaceSubrange(prefixStartIdx..<endPathIdx, with: "Any")
                            startSearch = result.index(prefixStartIdx, offsetBy: 3, limitedBy: result.endIndex) ?? result.endIndex
                        }
                    } else if ["CatalogAssetType", "LocalService", "RemoteService", "Service", "ModelType", "TokenizerType", "Interface"].contains(lastComponent) {
                        if allAllowed {
                            let sub = suffixComponents.joined(separator: ".")
                            result.replaceSubrange(prefixStartIdx..<endPathIdx, with: "Self.\(sub)")
                            startSearch = result.index(prefixStartIdx, offsetBy: 5 + sub.count, limitedBy: result.endIndex) ?? result.endIndex
                        } else {
                            result.replaceSubrange(prefixStartIdx..<endPathIdx, with: "Self.\(lastComponent)")
                            startSearch = result.index(prefixStartIdx, offsetBy: 5 + lastComponent.count, limitedBy: result.endIndex) ?? result.endIndex
                        }
                    } else if lastComponent == "Type" {
                        result.replaceSubrange(prefixStartIdx..<endPathIdx, with: "\(prefix).Type")
                        startSearch = result.index(prefixStartIdx, offsetBy: prefix.count + 5, limitedBy: result.endIndex) ?? result.endIndex
                    } else {
                        result.replaceSubrange(prefixStartIdx..<endPathIdx, with: "Any")
                        startSearch = result.index(prefixStartIdx, offsetBy: 3, limitedBy: result.endIndex) ?? result.endIndex
                    }
                } else {
                    startSearch = result.index(after: dotIdx)
                }
            } else {
                startSearch = result.index(after: dotIdx)
            }
        }
        return result
    }

    // 14. stripParentPrefix: replaces `\b([a-zA-Z0-9_]+\.)+\(parentName)\.` with `""`.
    func stripParentPrefix(parentName: String) -> String {
        var result = self
        let target = parentName + "."
        var startSearch = result.startIndex
        while let range = result.range(of: target, range: startSearch..<result.endIndex) {
            if range.lowerBound > result.startIndex {
                let beforeDotIdx = result.index(before: range.lowerBound)
                if result[beforeDotIdx] == "." {
                    var scanIdx = beforeDotIdx
                    var isValidPrefix = false
                    while scanIdx > result.startIndex {
                        var checkIdx = scanIdx
                        var hasIdent = false
                        while checkIdx > result.startIndex {
                            let prevIdx = result.index(before: checkIdx)
                            let char = result[prevIdx]
                            let isIdentChar = char.isLetter || char.isNumber || char == "_" || char == "$"
                            if isIdentChar {
                                checkIdx = prevIdx
                                hasIdent = true
                            } else {
                                break
                            }
                        }
                        if hasIdent {
                            if checkIdx == result.startIndex {
                                isValidPrefix = true
                                scanIdx = checkIdx
                                break
                            } else {
                                let beforeCharIdx = result.index(before: checkIdx)
                                let beforeChar = result[beforeCharIdx]
                                if beforeChar == "." {
                                    scanIdx = beforeCharIdx
                                } else if beforeChar.isWhitespace || beforeChar == "(" || beforeChar == "," || beforeChar == "<" || beforeChar == ">" {
                                    isValidPrefix = true
                                    scanIdx = checkIdx
                                    break
                                } else {
                                    break
                                }
                            }
                        } else {
                            break
                        }
                    }
                    if isValidPrefix {
                        result.replaceSubrange(scanIdx..<range.upperBound, with: "")
                        startSearch = scanIdx
                        continue
                    }
                }
            }
            startSearch = range.upperBound
        }
        return result
    }

    // 15. replaceSelfPattern: handles:
    // selfPattern1: \b([a-zA-Z0-9_]+\.)+\(self.name)<[^>]+> -> Self
    // selfPattern2: \b([a-zA-Z0-9_]+\.)+\(self.name)\b -> Self
    // prefixPattern: \b([a-zA-Z0-9_]+\.)+\(self.name)\b -> self.name
    func replaceSelfPattern(parentName: String, enclosingPath: String, replaceWith: String, defaultModule: String = "") -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: parentName, range: startSearch..<result.endIndex) {
            var isValidPrefix = false
            var prefixStartIdx = range.lowerBound
            var beforeDotIdx = range.lowerBound
            if range.lowerBound > result.startIndex {
                beforeDotIdx = result.index(before: range.lowerBound)
                if result[beforeDotIdx] == "." {
                    var scanIdx = beforeDotIdx
                    while scanIdx > result.startIndex {
                        var checkIdx = scanIdx
                        var hasIdent = false
                        while checkIdx > result.startIndex {
                            let prevIdx = result.index(before: checkIdx)
                            let char = result[prevIdx]
                            let isIdentChar = char.isLetter || char.isNumber || char == "_" || char == "$"
                            if isIdentChar {
                                checkIdx = prevIdx
                                hasIdent = true
                            } else {
                                break
                            }
                        }
                        if hasIdent {
                            if checkIdx == result.startIndex {
                                isValidPrefix = true
                                prefixStartIdx = checkIdx
                                break
                            } else {
                                let beforeCharIdx = result.index(before: checkIdx)
                                let beforeChar = result[beforeCharIdx]
                                if beforeChar == "." {
                                    scanIdx = beforeCharIdx
                                } else if beforeChar.isWhitespace || beforeChar == "(" || beforeChar == "," || beforeChar == "<" || beforeChar == ">" {
                                    isValidPrefix = true
                                    prefixStartIdx = checkIdx
                                    break
                                } else {
                                    break
                                }
                            }
                        } else {
                            break
                        }
                    }
                }
            }
            
            if isValidPrefix {
                let scannedPrefix = range.lowerBound > result.startIndex ? String(result[prefixStartIdx..<beforeDotIdx]) : ""
                if enclosingPath.isEmpty {
                    if !scannedPrefix.isEmpty && !defaultModule.isEmpty && scannedPrefix != defaultModule {
                        isValidPrefix = false
                    }
                } else {
                    if scannedPrefix != enclosingPath && (!defaultModule.isEmpty && scannedPrefix != (defaultModule + "." + enclosingPath)) {
                        isValidPrefix = false
                    }
                }
            }
            
            if isValidPrefix {
                let afterIdx = range.upperBound
                var isWordCharAfter = false
                if afterIdx < result.endIndex {
                    let nextChar = result[afterIdx]
                    isWordCharAfter = nextChar.isLetter || nextChar.isNumber || nextChar == "_" || nextChar == "$"
                }
                
                if !isWordCharAfter {
                    var replaceRange = prefixStartIdx..<range.upperBound
                    if replaceWith == "Self" && afterIdx < result.endIndex && result[afterIdx] == "<" {
                        var scanIdx = result.index(after: afterIdx)
                        while scanIdx < result.endIndex && result[scanIdx] != ">" {
                            scanIdx = result.index(after: scanIdx)
                        }
                        if scanIdx < result.endIndex && result[scanIdx] == ">" {
                            replaceRange = prefixStartIdx..<result.index(after: scanIdx)
                        }
                    }
                    result.replaceSubrange(replaceRange, with: replaceWith)
                    startSearch = result.index(prefixStartIdx, offsetBy: replaceWith.count, limitedBy: result.endIndex) ?? result.endIndex
                    continue
                }
            }
            startSearch = range.upperBound
        }
        return result
    }

    // 16. replaceSequenceRef: replaces "Sequence<[^>]+>" with "Sequence".
    func replaceSequenceRef() -> String {
        var t = self
        while let range = t.range(of: "Sequence<") {
            var depth = 0
            var endIdx: String.Index? = nil
            for idx in t.indices[range.upperBound...] {
                if t[idx] == "<" {
                    depth += 1
                } else if t[idx] == ">" {
                    if depth == 0 {
                        endIdx = t.index(after: idx)
                        break
                    } else {
                        depth -= 1
                    }
                }
            }
            if let endIdx = endIdx {
                t.replaceSubrange(range.lowerBound..<endIdx, with: "Sequence")
            } else {
                break
            }
        }
        return t
    }

    // 17. hasGenericPlaceholderInBrackets: checks if the string contains a generic placeholder whole-word inside <...> before the first '('
    func hasGenericPlaceholderInBrackets(p: String) -> Bool {
        guard let openIdx = self.firstIndex(of: "<"),
              let closeIdx = self.firstIndex(of: ">"),
              openIdx < closeIdx else { return false }
        
        let afterIdx = self.index(after: openIdx)
        guard afterIdx < self.endIndex else { return false }
        let nextChar = self[afterIdx]
        guard nextChar.isLetter else {
            return false
        }
        
        if let parenIdx = self.firstIndex(of: "("), parenIdx < openIdx {
            return false
        }
        
        let inside = String(self[self.index(after: openIdx)..<closeIdx])
        
        var startSearch = inside.startIndex
        while let range = inside.range(of: p, range: startSearch..<inside.endIndex) {
            let isWordCharBefore: Bool
            if range.lowerBound > inside.startIndex {
                let prevChar = inside[inside.index(before: range.lowerBound)]
                isWordCharBefore = prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$"
            } else {
                isWordCharBefore = false
            }
            
            let isWordCharAfter: Bool
            if range.upperBound < inside.endIndex {
                let nextChar = inside[range.upperBound]
                isWordCharAfter = nextChar.isLetter || nextChar.isNumber || nextChar == "_" || nextChar == "$"
            } else {
                isWordCharAfter = false
            }
            
            if !isWordCharBefore && !isWordCharAfter {
                return true
            }
            startSearch = range.upperBound
        }
        return false
    }

    // 18. replaceCriteriaWithoutGeneric: handles nested Criteria generic issue
    func replaceCriteriaWithoutGeneric() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: "Criteria", range: startSearch..<result.endIndex) {
            var wordStartIdx = range.lowerBound
            while wordStartIdx > result.startIndex {
                let prevIdx = result.index(before: wordStartIdx)
                let char = result[prevIdx]
                let isIdentOrDot = char.isLetter || char.isNumber || char == "_" || char == "."
                if isIdentOrDot {
                    wordStartIdx = prevIdx
                } else {
                    break
                }
            }
            
            let firstChar = result[wordStartIdx]
            guard firstChar.isUppercase else {
                startSearch = range.upperBound
                continue
            }
            
            // Check if preceded by struct/class/enum/protocol/typealias definition keyword
            var scanPrev = wordStartIdx
            while scanPrev > result.startIndex {
                let prevIdx = result.index(before: scanPrev)
                if result[prevIdx].isWhitespace {
                    scanPrev = prevIdx
                } else {
                    break
                }
            }
            var keywordStart = scanPrev
            while keywordStart > result.startIndex {
                let prevIdx = result.index(before: keywordStart)
                let char = result[prevIdx]
                let isIdent = char.isLetter || char.isNumber || char == "_" || char == "$"
                if isIdent {
                    keywordStart = prevIdx
                } else {
                    break
                }
            }
            let prevWord = String(result[keywordStart..<scanPrev])
            if ["struct", "class", "enum", "protocol", "typealias"].contains(prevWord) {
                startSearch = range.upperBound
                continue
            }
            
            let fullWordRange = wordStartIdx..<range.upperBound
            let fullWord = String(result[fullWordRange])
            
            let afterIdx = range.upperBound
            var isFollowedByGenericOrIdent = false
            if afterIdx < result.endIndex {
                let nextChar = result[afterIdx]
                isFollowedByGenericOrIdent = nextChar == "<" || nextChar.isLetter || nextChar.isNumber || nextChar == "_"
            }
            
            if !isFollowedByGenericOrIdent {
                result.replaceSubrange(fullWordRange, with: fullWord + "<Any>")
                startSearch = result.index(wordStartIdx, offsetBy: fullWord.count + 5, limitedBy: result.endIndex) ?? result.endIndex
            } else {
                startSearch = range.upperBound
            }
        }
        return result
    }

    // 19. fixPrefixAndPostfixOperators: cleans up operator keywords prefix/postfix
    func fixPrefixAndPostfixOperators() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: "func ", range: startSearch..<result.endIndex) {
            let postFuncIdx = range.upperBound
            
            var scanIdx = postFuncIdx
            var parenIdx: String.Index? = nil
            while scanIdx < result.endIndex {
                let char = result[scanIdx]
                if char == "(" {
                    parenIdx = scanIdx
                    break
                } else if char == "\n" {
                    break
                }
                scanIdx = result.index(after: scanIdx)
            }
            
            if let parenIdx = parenIdx {
                let sigPart = String(result[postFuncIdx..<parenIdx])
                
                if sigPart.hasSuffix(" prefix") {
                    let opName = sigPart.dropLast(7).trimmingCharacters(in: .whitespaces)
                    if !opName.contains(" ") && !opName.isEmpty {
                        let fullRange = range.lowerBound..<result.index(after: parenIdx)
                        let replacement = "prefix func \(opName)("
                        result.replaceSubrange(fullRange, with: replacement)
                        startSearch = result.index(range.lowerBound, offsetBy: replacement.count, limitedBy: result.endIndex) ?? result.endIndex
                        continue
                    }
                } else if sigPart.hasSuffix(" postfix") {
                    let opName = sigPart.dropLast(8).trimmingCharacters(in: .whitespaces)
                    if !opName.contains(" ") && !opName.isEmpty {
                        let fullRange = range.lowerBound..<result.index(after: parenIdx)
                        let replacement = "postfix func \(opName)("
                        result.replaceSubrange(fullRange, with: replacement)
                        startSearch = result.index(range.lowerBound, offsetBy: replacement.count, limitedBy: result.endIndex) ?? result.endIndex
                        continue
                    }
                }
            }
            
            startSearch = range.upperBound
        }
        return result
    }

    // 20a. removeInvalidAnyGenericClauses
    // On func/init/subscript/associatedtype DECLARATION lines only, strips a `<...>` generic
    // parameter clause whose parameter NAME is a Swift keyword (Any, Self) or a parameter pack
    // (`each Any`). These arise when unresolved generic placeholders (A, B, ...) are substituted
    // with `Any`. Restricted to declaration lines by prefix so type-use positions like
    // `Array<Any>` in a body are never touched.
    func removeInvalidAnyGenericClauses() -> String {
        let lines = self.components(separatedBy: "\n")
        let fixed = lines.map { (line: String) -> String in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // A declaration line contains one of these keywords (possibly after modifiers
            // like `public final static`), followed by a generic clause.
            let isDecl = trimmed.contains("func ") || trimmed.contains("init<")
                || trimmed.contains("init(") || trimmed.contains("subscript")
                || trimmed.hasPrefix("associatedtype ")
            guard isDecl, line.contains("<") else { return line }

            var out = line

            // Fix `<T where T: P, ...>` — Swift 5.9+ obsoleted inline where in generic params.
            // Also handles orphaned `<where T: P, ...>` (param name was dropped).
            // Strategy: extract the param name + constraints, replace `<T where ...>` with `<T>`,
            // and append ` where ...` after the closing `)` of the parameter list.
            var whereChanged = true
            while whereChanged {
                whereChanged = false
                // Match either `<where ` (orphaned) or `<Ident where ` (inline)
                var matchStart: String.Index? = nil
                var paramName: String = ""
                var clauseContent: String = ""
                var matchEnd: String.Index? = nil

                if let r = out.range(of: "<where ") {
                    // Orphaned: `<where Ident: P, ...>`
                    let lt = r.lowerBound
                    let afterWhere = r.upperBound
                    var nameEnd = afterWhere
                    while nameEnd < out.endIndex && (out[nameEnd].isLetter || out[nameEnd].isNumber || out[nameEnd] == "_") {
                        nameEnd = out.index(after: nameEnd)
                    }
                    if nameEnd > afterWhere {
                        let pname = String(out[afterWhere..<nameEnd])
                        if !["Any", "Self", "some", "any", "each"].contains(pname) {
                            var depth = 0; var j = lt; var gt: String.Index? = nil
                            while j < out.endIndex {
                                if out[j] == "<" { depth += 1 }
                                else if out[j] == ">" { depth -= 1; if depth == 0 { gt = j; break } }
                                j = out.index(after: j)
                            }
                            if let g = gt {
                                var raw = String(out[out.index(after: lt)..<g])
                                if raw.hasPrefix("where ") { raw = String(raw.dropFirst(6)) }
                                matchStart = lt; paramName = pname; clauseContent = raw; matchEnd = g
                            }
                        } else {
                            // `<where Any:...>` — strip entirely
                            var depth = 0; var j = lt; var gt: String.Index? = nil
                            while j < out.endIndex {
                                if out[j] == "<" { depth += 1 }
                                else if out[j] == ">" { depth -= 1; if depth == 0 { gt = j; break } }
                                j = out.index(after: j)
                            }
                            if let g = gt { out.removeSubrange(lt...g); whereChanged = true }
                            break
                        }
                    }
                }

                // Also fix `<T where T: P>` style (inline where in generic bracket, e.g. from old demangler)
                if matchStart == nil {
                    // Scan for `<Ident where ` pattern
                    var scan = out.startIndex
                    while scan < out.endIndex {
                        guard let ltRange = out.range(of: "<", range: scan..<out.endIndex) else { break }
                        let lt = ltRange.lowerBound
                        // Read identifier after `<`
                        var identEnd = ltRange.upperBound
                        while identEnd < out.endIndex && (out[identEnd].isLetter || out[identEnd].isNumber || out[identEnd] == "_") {
                            identEnd = out.index(after: identEnd)
                        }
                        if identEnd > ltRange.upperBound {
                            let pname = String(out[ltRange.upperBound..<identEnd])
                            // Check if followed by ` where `
                            let rest = String(out[identEnd...])
                            if rest.hasPrefix(" where ") {
                                // Found `<Ident where`
                                var depth = 0; var j = lt; var gt: String.Index? = nil
                                while j < out.endIndex {
                                    if out[j] == "<" { depth += 1 }
                                    else if out[j] == ">" { depth -= 1; if depth == 0 { gt = j; break } }
                                    j = out.index(after: j)
                                }
                                if let g = gt {
                                    let inner = String(out[out.index(after: lt)..<g])
                                    // inner = "Ident where constraints..."
                                    if let wRange = inner.range(of: " where ") {
                                        let constraints = String(inner[wRange.upperBound...])
                                        matchStart = lt; paramName = pname; clauseContent = constraints; matchEnd = g
                                    }
                                }
                                break
                            }
                        }
                        scan = ltRange.upperBound
                    }
                }

                guard let ms = matchStart, let me = matchEnd else { break }

                // Strip labeled-tuple syntax from constraint RHS: `(_ arg1: Any, _ arg2: Any)` → `(Any, Any)`
                var cleanClause = clauseContent
                cleanClause = cleanClause.stripLabeledTupleInWhereClause()

                // Replace `<Ident where ...>` with `<Ident>` and append where clause before `{` (or at end of line)
                out.replaceSubrange(ms...me, with: "<\(paramName)>")
                if let bodyBrace = out.range(of: " {", options: .backwards, range: ms..<out.endIndex)?.lowerBound {
                    out.insert(contentsOf: " where \(cleanClause)", at: bodyBrace)
                } else if let parenClose = out.range(of: ") {", range: ms..<out.endIndex)?.lowerBound ??
                                       out.range(of: ") ->", range: ms..<out.endIndex)?.lowerBound ??
                                       out.range(of: ") throws", range: ms..<out.endIndex)?.lowerBound ??
                                       out.range(of: ") async", range: ms..<out.endIndex)?.lowerBound {
                    let insertAt = out.index(after: parenClose)
                    out.insert(contentsOf: " where \(cleanClause)", at: insertAt)
                }
                whereChanged = true
            }

            // Fix unnamed single-param signatures left by generic stripping: `(TypeName) ->` etc.
            // This handles `(GenericA) ->`, `(Any) ->` etc. that lack argument labels.
            // Excluded: typed-throws `throws(Error)` and closure types `(T) -> R`.
            let keywordsBeforeParen: Set<String> = ["throws", "async", "rethrows", "await", "catch", "return"]
            for suffix in [") ->", ") {", ") throws", ") async"] {
                var searchFrom = out.startIndex
                while let r = out.range(of: suffix, range: searchFrom..<out.endIndex) {
                    let closeP = r.lowerBound
                    // Find matching `(` by scanning backwards
                    var depth = 0; var j = closeP; var openP: String.Index? = nil
                    while j >= out.startIndex {
                        if out[j] == ")" { depth += 1 }
                        else if out[j] == "(" { depth -= 1; if depth == 0 { openP = j; break } }
                        if j == out.startIndex { break }
                        j = out.index(before: j)
                    }
                    if let op = openP {
                        guard op == out.firstIndex(of: "(") else {
                            searchFrom = r.upperBound
                            continue
                        }
                        // Check: the char/word BEFORE `(` must be an identifier or `>`, not a keyword
                        var prevEnd = op
                        while prevEnd > out.startIndex {
                            let pi = out.index(before: prevEnd)
                            if out[pi].isWhitespace { prevEnd = pi } else { break }
                        }
                        var prevStart = prevEnd
                        while prevStart > out.startIndex {
                            let pi = out.index(before: prevStart)
                            if out[pi].isLetter || out[pi].isNumber || out[pi] == "_" { prevStart = pi } else { break }
                        }
                        let prevWord = String(out[prevStart..<prevEnd])
                        // Skip if preceded by a keyword (typed-throws, async closure, etc.)
                        if keywordsBeforeParen.contains(prevWord) {
                            searchFrom = r.upperBound
                            continue
                        }
                        let inner = String(out[out.index(after: op)..<closeP]).trimmingCharacters(in: .whitespaces)
                        let containsAtDepth0 = { (str: String, char: Character) -> Bool in
                            var depth = 0
                            for c in str {
                                if c == "<" || c == "(" || c == "[" { depth += 1 }
                                else if c == ">" || c == ")" || c == "]" { if depth > 0 { depth -= 1 } }
                                else if c == char && depth == 0 {
                                    return true
                                }
                            }
                            return false
                        }
                        // Single bare type with no `:` at depth 0 (no label) — needs `_ arg1: `
                        if !inner.isEmpty && !containsAtDepth0(inner, ":") && !containsAtDepth0(inner, ",") {
                            let replacement = "(_ arg1: \(inner))"
                            out.replaceSubrange(op...closeP, with: replacement)
                            searchFrom = out.index(op, offsetBy: replacement.count, limitedBy: out.endIndex) ?? out.endIndex
                            continue
                        }
                    }
                    searchFrom = r.upperBound
                }
            }

            // Bad clause openers: `<Any` / `<Self` used as the generic param NAME, or `<each Any`
            let badOpeners = ["<Any:", "<Any,", "<Any>", "<Any ", "<each Any",
                              "<Self:", "<Self,", "<Self>", "<Self "]
            var changed = true
            while changed {
                changed = false
                for opener in badOpeners {
                    guard let r = out.range(of: opener) else { continue }
                    let lt = r.lowerBound
                    // Only strip a `<...>` clause if it is in the GENERIC PARAMETER position:
                    // i.e. before the first `(` on the line. Inside `(...)` it is a type argument.
                    if let firstParen = out.firstIndex(of: "("), lt > firstParen { continue }
                    // Find matching `>` by depth from `lt`
                    var depth = 0
                    var j = lt
                    var gt: String.Index? = nil
                    while j < out.endIndex {
                        if out[j] == "<" { depth += 1 }
                        else if out[j] == ">" {
                            depth -= 1
                            if depth == 0 { gt = j; break }
                        }
                        j = out.index(after: j)
                    }
                    if let g = gt {
                        out.removeSubrange(lt...g)
                        changed = true
                        break
                    }
                }
            }
            // After stripping a func/init generic clause, a bare `(Any)` parameter list is left
            // unnamed — give it a label so it parses.
            if let firstParen = out.firstIndex(of: "(") {
                let tail = out[firstParen...]
                if tail.hasPrefix("(Any) ->") || tail.hasPrefix("(Any) {") || tail.hasPrefix("(Any) throws") || tail.hasPrefix("(Any) async") || tail.hasPrefix("(Any) where") {
                    let rangeToReplace = firstParen...out.index(firstParen, offsetBy: 4)
                    out.replaceSubrange(rangeToReplace, with: "(_ arg1: Any)")
                }
            }
            return out
        }
        return fixed.joined(separator: "\n")
    }

    // 20b-helper. stripLabeledTupleInWhereClause: converts `(_ arg1: Any, _ arg2: Any)` style
    // back to `(Any, Any)` for use in where-clause type positions (not parameter lists).
    func stripLabeledTupleInWhereClause() -> String {
        // Pattern: `(_ argN: Type, ...)` → `(Type, ...)`
        // Simple approach: replace `_ arg\d+: ` with `` inside parens
        var out = self
        var startSearch = out.startIndex
        while let r = out.range(of: "(_ arg", range: startSearch..<out.endIndex) {
            // Find matching `)` from start of `(`
            let lparen = r.lowerBound
            var depth = 0; var j = lparen; var rparen: String.Index? = nil
            while j < out.endIndex {
                if out[j] == "(" { depth += 1 }
                else if out[j] == ")" { depth -= 1; if depth == 0 { rparen = j; break } }
                j = out.index(after: j)
            }
            if let rp = rparen {
                // Strip `_ argN: ` from each element
                let inner = String(out[out.index(after: lparen)..<rp])
                var cleaned = ""
                var cur = ""
                var d = 0
                for ch in inner {
                    if ch == "(" || ch == "[" { d += 1 }
                    else if ch == ")" || ch == "]" { d -= 1 }
                    else if ch == "," && d == 0 {
                        cleaned += stripOneLabel(cur.trimmingCharacters(in: .whitespaces)) + ", "
                        cur = ""
                        continue
                    }
                    cur.append(ch)
                }
                if !cur.trimmingCharacters(in: .whitespaces).isEmpty {
                    cleaned += stripOneLabel(cur.trimmingCharacters(in: .whitespaces))
                }
                out.replaceSubrange(lparen...rp, with: "(\(cleaned))")
                startSearch = lparen
            } else {
                startSearch = r.upperBound
            }
        }
        return out
    }

    private func stripOneLabel(_ s: String) -> String {
        // `_ argN: Type` → `Type`, `label argN: Type` → `Type`
        let parts = s.components(separatedBy: ": ")
        if parts.count >= 2 {
            let label = parts[0].trimmingCharacters(in: .whitespaces)
            let words = label.components(separatedBy: " ")
            // If looks like `_ argN` or `label argN` pattern → strip
            if words.count == 2, words[1].hasPrefix("arg") {
                return parts.dropFirst().joined(separator: ": ")
            }
        }
        return s
    }

    // 20c-sub. fixSubscriptGetSetInExtensions: converts `subscript ... { get set }` to
    // `subscript ... { get { fatalError() } set {} }` when outside protocol declarations.
    // Protocol subscripts use `{ get }` / `{ get set }` syntax; extensions need implementations.
    func fixSubscriptGetSetInExtensions() -> String {
        let lines = self.components(separatedBy: "\n")
        var inProtocol = false
        var depth = 0
        var protocolEntryDepth = 0
        var result = [String]()

        for line in lines {
            let opens = line.filter { $0 == "{" }.count
            let closes = line.filter { $0 == "}" }.count
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Detect protocol declaration entry
            if opens > 0 {
                let protocolPattern = ["public protocol ", "internal protocol ", "protocol "]
                for pat in protocolPattern {
                    if trimmed.contains(pat) && !trimmed.hasPrefix("//") {
                        inProtocol = true
                        protocolEntryDepth = depth
                        break
                    }
                }
            }

            // Only convert if NOT inside a protocol
            var processedLine = line
            if !inProtocol && trimmed.contains("subscript") {
                // `{ get set }` → `{ get { fatalError() } set {} }`
                processedLine = processedLine.replacingOccurrences(
                    of: "{ get set }", with: "{ get { fatalError() } set {} }")
                processedLine = processedLine.replacingOccurrences(
                    of: "{ get set}", with: "{ get { fatalError() } set {} }")
                // `{ get }` → `{ get { fatalError() } }` (only when no existing body)
                if processedLine.contains("{ get }") {
                    processedLine = processedLine.replacingOccurrences(
                        of: "{ get }", with: "{ get { fatalError() } }")
                }
            }

            result.append(processedLine)
            depth += opens - closes

            // Exit protocol scope
            if inProtocol && depth <= protocolEntryDepth {
                inProtocol = false
            }
        }
        return result.joined(separator: "\n")
    }

    // 20c. stripConstrainedExistentialGenerics: removes `<...>` from `any Protocol<X == Y>`.
    // Constrained existentials with same-type constraints in `<>` are invalid Swift syntax.
    // E.g. `any Subject<Self.Failure == Any, Self.Output>` → `any Subject`
    func stripConstrainedExistentialGenerics() -> String {
        var result = self
        var startSearch = result.startIndex
        while let anyRange = result.range(of: "any ", range: startSearch..<result.endIndex) {
            // Check word boundary before 'any'
            if anyRange.lowerBound > result.startIndex {
                let prev = result[result.index(before: anyRange.lowerBound)]
                if prev.isLetter || prev.isNumber || prev == "_" {
                    startSearch = anyRange.upperBound
                    continue
                }
            }
            // Scan the protocol name
            var nameEnd = anyRange.upperBound
            while nameEnd < result.endIndex && (result[nameEnd].isLetter || result[nameEnd].isNumber || result[nameEnd] == "_" || result[nameEnd] == ".") {
                nameEnd = result.index(after: nameEnd)
            }
            // Check if followed by `<`
            guard nameEnd < result.endIndex && result[nameEnd] == "<" else {
                startSearch = nameEnd
                continue
            }
            // Find matching `>` with depth tracking
            let lt = nameEnd
            var depth = 0; var j = lt; var gt: String.Index? = nil
            while j < result.endIndex {
                if result[j] == "<" { depth += 1 }
                else if result[j] == ">" { depth -= 1; if depth == 0 { gt = j; break } }
                j = result.index(after: j)
            }
            guard let g = gt else { startSearch = nameEnd; continue }
            // Check if the content contains `==` (same-type constraint syntax)
            let inner = String(result[result.index(after: lt)..<g])
            if inner.contains("==") {
                // Strip `<...>` from `any Protocol<...>`
                result.removeSubrange(lt...g)
                startSearch = lt
            } else {
                startSearch = result.index(after: g)
            }
        }
        return result
    }

    // 20b. cleanAnyWhereConstraints: on declaration lines, removes where-clause same-type
    // constraints whose LHS is `Any` (e.g. `Any == Void`, `Any == (Any, Any)`).
    // Keeps conformance constraints (T: P) and same-type constraints where neither side is `Any`.
    // Also removes empty where clauses left behind.
    func cleanAnyWhereConstraints() -> String {
        guard self.contains(" where ") else { return self }
        // Find the ` where ` boundary — only in declaration context (already line-scoped by caller)
        let result = self
        // Find ` where ` — keep the part before and after
        guard let whereRange = result.range(of: " where ") else { return result }
        let beforeWhere = String(result[..<whereRange.lowerBound])
        let constraintStr = String(result[whereRange.upperBound...])

        // Split the constraint list on top-level commas (not inside parens/brackets)
        var constraints = [String]()
        var current = ""
        var depth = 0
        for ch in constraintStr {
            if ch == "(" || ch == "[" { depth += 1 }
            else if ch == ")" || ch == "]" { depth -= 1 }
            else if ch == "," && depth == 0 {
                constraints.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
                continue
            }
            current.append(ch)
        }
        if !current.trimmingCharacters(in: .whitespaces).isEmpty {
            constraints.append(current.trimmingCharacters(in: .whitespaces))
        }

        // Keep constraints that don't have `Any` on the LHS of `==`
        let kept = constraints.filter { c in
            let t = c.trimmingCharacters(in: .whitespaces)
            // `Any == <whatever>` or `any <something> == <whatever>` → drop
            if t.hasPrefix("Any ==") || t.hasPrefix("any ==") { return false }
            // `Any: <protocol>` → drop (Any can't be constrained as a type param)
            if t.hasPrefix("Any:") || t.hasPrefix("any:") { return false }
            // `Self == <whatever>` → drop
            if t.hasPrefix("Self ==") { return false }
            return true
        }

        if kept.isEmpty {
            return beforeWhere
        } else {
            return beforeWhere + " where " + kept.joined(separator: ", ")
        }
    }

    // 20. stripAnyGenericApplicationBeforeParen: strips <Any> and <Any, Any> before parenthesis
    func stripAnyGenericApplicationBeforeParen() -> String {
        guard let regex = try? NSRegularExpression(pattern: "<(?:\\s*Any\\s*,)*\\s*Any\\s*>\\(", options: []) else {
            return self
        }
        let nsString = self as NSString
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
        
        var result = self
        for match in matches.reversed() {
            let matchRange = match.range
            if matchRange.length > 1 {
                let replaceRange = NSRange(location: matchRange.location, length: matchRange.length - 1)
                if let r = Range(replaceRange, in: result) {
                    result.replaceSubrange(r, with: "")
                }
            }
        }
        return result
    }

    // 21. stripInvalidAnyPrefixes: removes 'any' keyword before concrete types that are NOT also protocols.
    // If a type name appears in both concreteTypes and protocolNames (e.g. ResourceBundle, which is both
    // a protocol and a nested enum), we keep the 'any' prefix since the usage is existential.
    func stripInvalidAnyPrefixes(concreteTypes: Set<String>, protocolNames: Set<String> = []) -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: "any ", range: startSearch..<result.endIndex) {
            let isWordCharBefore: Bool
            if range.lowerBound > result.startIndex {
                let prevChar = result[result.index(before: range.lowerBound)]
                isWordCharBefore = prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$"
            } else {
                isWordCharBefore = false
            }
            
            if isWordCharBefore {
                startSearch = range.upperBound
                continue
            }
            
            var scanIdx = range.upperBound
            while scanIdx < result.endIndex {
                let char = result[scanIdx]
                let isIdentChar = char.isLetter || char.isNumber || char == "_" || char == "$" || char == "."
                if isIdentChar {
                    scanIdx = result.index(after: scanIdx)
                } else {
                    break
                }
            }
            
            let typeNameRange = range.upperBound..<scanIdx
            var fullType = String(result[typeNameRange])
            if fullType.hasSuffix(".") {
                fullType = String(fullType.dropLast())
            }
            
            if !fullType.isEmpty {
                let lastComponent = fullType.components(separatedBy: ".").last!
                var baseType = lastComponent
                if let underscoreIdx = lastComponent.firstIndex(of: "_") {
                    baseType = String(lastComponent[result.index(after: underscoreIdx)...])
                }
                
                let components = fullType.components(separatedBy: ".")
                var isNestedUnderConcrete = false
                if components.count > 1 {
                    let first = components[0]
                    if concreteTypes.contains(first) {
                        isNestedUnderConcrete = true
                    } else if components.count > 2 {
                        let second = components[1]
                        if concreteTypes.contains(second) {
                            isNestedUnderConcrete = true
                        }
                    }
                }
                
                let isConcrete = concreteTypes.contains(baseType) || concreteTypes.contains(lastComponent) || isNestedUnderConcrete
                // Don't strip if this type is ALSO a protocol (e.g. ResourceBundle is both a
                // concrete nested enum AND a top-level protocol — keep 'any' for the protocol usage)
                // but if it is nested under a concrete type, it cannot be a protocol in Swift
                let isAlsoProtocol = !isNestedUnderConcrete && (protocolNames.contains(lastComponent) || protocolNames.contains(baseType))
                
                if isConcrete && !isAlsoProtocol {
                    result.replaceSubrange(range, with: "")
                    startSearch = range.lowerBound
                    continue
                }
            }
            startSearch = range.upperBound
        }
        return result
    }

    // 22. addAnyToProtocolExistentials: inserts 'any' before known protocol names used in existential positions.
    // Accepts a pre-filtered set of unambiguous protocol short names (no same-named top-level concrete type).
    // Handles: Array<Proto>, Optional<Proto>, -> Proto, : Proto, = Proto, (Proto, etc.
    // Skips: protocol Proto, extension Proto declaration contexts.
    func addAnyToProtocolExistentials(protocols shortProtos: Set<String>) -> String {
        guard !shortProtos.isEmpty else { return self }
        var result = self
        
        for proto in shortProtos.sorted(by: { $0.count > $1.count }) {
            var startSearch = result.startIndex
            while let range = result.range(of: proto, range: startSearch..<result.endIndex) {
                // Word boundary check: not preceded by an identifier char
                let isWordCharBefore: Bool
                if range.lowerBound > result.startIndex {
                    let prevChar = result[result.index(before: range.lowerBound)]
                    isWordCharBefore = prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$"
                } else {
                    isWordCharBefore = false
                }
                
                // Word boundary check: not followed by an identifier char
                let isWordCharAfter: Bool
                if range.upperBound < result.endIndex {
                    let nextChar = result[range.upperBound]
                    isWordCharAfter = nextChar.isLetter || nextChar.isNumber || nextChar == "_" || nextChar == "$"
                } else {
                    isWordCharAfter = false
                }
                
                guard !isWordCharBefore && !isWordCharAfter else {
                    startSearch = range.upperBound
                    continue
                }
                
                // Check if already preceded by 'any '
                var alreadyHasAny = false
                if range.lowerBound >= result.index(result.startIndex, offsetBy: 4, limitedBy: result.endIndex) ?? result.startIndex {
                    let anyEnd = range.lowerBound
                    let anyStart = result.index(anyEnd, offsetBy: -4)
                    if String(result[anyStart..<anyEnd]) == "any " {
                        alreadyHasAny = true
                    }
                }
                
                if alreadyHasAny {
                    startSearch = range.upperBound
                    continue
                }
                
                // Check if this is a declaration site (preceded by struct/class/protocol/extension/typealias/enum)
                // Scan backwards skipping whitespace to find the preceding word
                var scanBack = range.lowerBound
                while scanBack > result.startIndex {
                    let prevIdx = result.index(before: scanBack)
                    let prevChar = result[prevIdx]
                    if prevChar.isWhitespace {
                        scanBack = prevIdx
                    } else {
                        break
                    }
                }
                // Collect the preceding keyword
                let kwEnd = scanBack
                var kwStart = scanBack
                while kwStart > result.startIndex {
                    let prevIdx = result.index(before: kwStart)
                    let prevChar = result[prevIdx]
                    if prevChar.isLetter {
                        kwStart = prevIdx
                    } else {
                        break
                    }
                }
                let prevKeyword = String(result[kwStart..<kwEnd])
                
                if ["struct", "class", "protocol", "extension", "typealias", "enum", "import"].contains(prevKeyword) {
                    startSearch = range.upperBound
                    continue
                }
                
                // Also skip if it's a conformance position in a type declaration header:
                // i.e., after `: ` following a type name (like `struct Foo: Proto {`)
                // We approximate: if preceded by `, ` or `: ` at the *declaration* level — but this is complex.
                // Instead, check if the proto appears as an inheriting conformance on the LHS of `{`:
                // Simpler heuristic: check character 2 positions back (skip whitespace) for colon
                // and if we're at top indentation level (very hard without AST).
                // We accept a small false-negative (protocol decl conformances will get `any` too but
                // Swift ignores it there or it gets stripped by stripInvalidAnyPrefixes later).
                
                // Check if it's inside a generic argument (e.g., Array<Proto>) or after ->/ :
                // Check the character immediately before (after stripping whitespace) for existential context
                var contextChar: Character = "\0"
                var ctxScan = range.lowerBound
                while ctxScan > result.startIndex {
                    let prevIdx = result.index(before: ctxScan)
                    let prevChar = result[prevIdx]
                    if prevChar.isWhitespace {
                        ctxScan = prevIdx
                    } else {
                        ctxScan = prevIdx
                        contextChar = prevChar
                        break
                    }
                }
                
                // Existential position: inside generics, after arrow, colon, equals, or comma/paren
                let isAfterArrow: Bool
                if contextChar == ">" && ctxScan > result.startIndex {
                    let beforeArrow = result[result.index(before: ctxScan)]
                    isAfterArrow = (beforeArrow == "-")
                } else {
                    isAfterArrow = false
                }
                
                let existentialContextChars: Set<Character> = ["<", ",", "(", "[", ":", "="]
                let shouldInsertAny = existentialContextChars.contains(contextChar) || isAfterArrow
                
                if shouldInsertAny {
                    result.insert(contentsOf: "any ", at: range.lowerBound)
                    startSearch = result.index(range.lowerBound, offsetBy: proto.count + 4, limitedBy: result.endIndex) ?? result.endIndex
                } else {
                    startSearch = range.upperBound
                }
            }
        }
        return result
    }

    // 22b. stripAnyFromConformanceList: removes incorrectly added 'any' from conformance list items.
    // Handles: `struct Foo: any Bar, any Baz {` -> `struct Foo: Bar, Baz {`
    // Also handles: `class Foo: Base, any Bar {`
    func stripAnyFromConformanceList() -> String {
        var result = self
        var startSearch = result.startIndex
        
        while startSearch < result.endIndex {
            // Find the next 'any ' that appears in conformance list position
            guard let anyRange = result.range(of: "any ", range: startSearch..<result.endIndex) else { break }
            
            let isWordCharBefore: Bool
            if anyRange.lowerBound > result.startIndex {
                let prevChar = result[result.index(before: anyRange.lowerBound)]
                isWordCharBefore = prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$"
            } else {
                isWordCharBefore = false
            }
            
            if isWordCharBefore {
                startSearch = anyRange.upperBound
                continue
            }
            
            // Check if the character before 'any' (skipping whitespace) is ':' or ','
            var ctxScan = anyRange.lowerBound
            while ctxScan > result.startIndex {
                let prevIdx = result.index(before: ctxScan)
                let prevChar = result[prevIdx]
                if prevChar.isWhitespace {
                    ctxScan = prevIdx
                } else {
                    ctxScan = prevIdx
                    break
                }
            }
            let contextChar = ctxScan < anyRange.lowerBound ? result[ctxScan] : "\0"
            
            // Also check if we're on a conformance line (look backward for a `{` not found before a `:`)
            // Heuristic: if context char is ':' or ',', check that the same line contains a `{`
            if contextChar == ":" || contextChar == "," {
                // Check forward to see if this line ends with ` {`
                var lineScan = anyRange.upperBound
                var foundBrace = false
                while lineScan < result.endIndex && result[lineScan] != "\n" {
                    if result[lineScan] == "{" {
                        foundBrace = true
                        break
                    }
                    lineScan = result.index(after: lineScan)
                }
                
                // Also look backward to start of line
                var lineStart = anyRange.lowerBound
                while lineStart > result.startIndex {
                    let prevIdx = result.index(before: lineStart)
                    if result[prevIdx] == "\n" { break }
                    lineStart = prevIdx
                }
                let linePrefix = String(result[lineStart..<anyRange.lowerBound])
                
                let isConformanceLine = foundBrace && (
                    linePrefix.contains("struct ") || linePrefix.contains("class ") ||
                    linePrefix.contains("enum ") || linePrefix.contains("protocol ")
                )
                
                if isConformanceLine {
                    result.replaceSubrange(anyRange, with: "")
                    startSearch = anyRange.lowerBound
                    continue
                }
            }
            
            startSearch = anyRange.upperBound
        }
        return result
    }

    // 23. applyDiscoveredGenerics: appends generic placeholders to types found in flatGenerics/shortGenerics
    func applyDiscoveredGenerics(flatGenerics: [String: Int], shortGenerics: [String: Int]) -> String {
        let chars = Array(self)
        let n = chars.count
        var result = ""
        result.reserveCapacity(n + n / 10)
        
        var i = 0
        while i < n {
            let c = chars[i]
            let isIdentStart = c.isLetter || c == "_" || c == "$"
            
            var isWordBoundary = true
            if isIdentStart && i > 0 {
                let prev = chars[i - 1]
                if prev.isLetter || prev.isNumber || prev == "_" || prev == "$" {
                    isWordBoundary = false
                }
            }
            
            if isIdentStart && isWordBoundary {
                let start = i
                while i < n {
                    let nextC = chars[i]
                    let isIdentChar = nextC.isLetter || nextC.isNumber || nextC == "_" || nextC == "$"
                    if isIdentChar {
                        i += 1
                    } else {
                        break
                    }
                }
                
                let word = String(chars[start..<i])
                
                var isCapitalized = false
                var scanIdx = word.startIndex
                while scanIdx < word.endIndex && (word[scanIdx] == "_" || word[scanIdx] == "$") {
                    scanIdx = word.index(after: scanIdx)
                }
                if scanIdx < word.endIndex && word[scanIdx].isUppercase {
                    isCapitalized = true
                }
                
                if isCapitalized {
                    var followedByGeneric = false
                    var nextIdx = i
                    while nextIdx < n && chars[nextIdx].isWhitespace {
                        nextIdx += 1
                    }
                    if nextIdx < n && chars[nextIdx] == "<" {
                        followedByGeneric = true
                    }
                    
                    var precededByDefinition = false
                    var prevIdx = start - 1
                    while prevIdx >= 0 && chars[prevIdx].isWhitespace {
                        prevIdx -= 1
                    }
                    if prevIdx >= 0 {
                        var kwStart = prevIdx
                        while kwStart >= 0 && (chars[kwStart].isLetter || chars[kwStart] == "_" || chars[kwStart] == "$") {
                            kwStart -= 1
                        }
                        if kwStart < prevIdx {
                            let kw = String(chars[(kwStart + 1)...prevIdx])
                            if ["struct", "class", "enum", "protocol", "typealias", "extension"].contains(kw) {
                                precededByDefinition = true
                            }
                        }
                    }
                    if !followedByGeneric && !precededByDefinition {
                        // Scan backward to build fullPath in the code (e.g. Publishers.Buffer)
                        var fullPath = word
                        var pIdx = start - 1
                        while pIdx >= 0 {
                            var wsIdx = pIdx
                            while wsIdx >= 0 && chars[wsIdx].isWhitespace {
                                wsIdx -= 1
                            }
                            if wsIdx >= 0 && chars[wsIdx] == "." {
                                var wordEnd = wsIdx - 1
                                while wordEnd >= 0 && chars[wordEnd].isWhitespace {
                                    wordEnd -= 1
                                }
                                if wordEnd >= 0 && (chars[wordEnd].isLetter || chars[wordEnd].isNumber || chars[wordEnd] == "_" || chars[wordEnd] == "$") {
                                    var wordStart = wordEnd
                                    while wordStart >= 0 && (chars[wordStart].isLetter || chars[wordStart].isNumber || chars[wordStart] == "_" || chars[wordStart] == "$") {
                                        wordStart -= 1
                                    }
                                    let prefixWord = String(chars[(wordStart + 1)...wordEnd])
                                    fullPath = prefixWord + "." + fullPath
                                    pIdx = wordStart
                                        
                                    // Security check: if the prefix is self/Self/Any/etc., stop building
                                    if prefixWord == "Self" || prefixWord == "Any" || prefixWord.count == 1 {
                                        break
                                    }
                                } else {
                                    break
                                }
                            } else {
                                break
                            }
                        }
                        
                        // Find generic count matching this fullPath
                        var count = 0
                        let firstComponent = fullPath.components(separatedBy: ".").first ?? ""
                        let isGenericPrefix = firstComponent.hasPrefix("Generic") || firstComponent.count == 1 || firstComponent == "Self"
                        
                        // A word immediately preceded by a dot (e.g. `A1.Output`) is a member
                        // access — most often an associated-type reference — not a bare type
                        // name, so it must never get generic args appended, regardless of
                        // whether `word` also happens to match a same-named generic struct
                        // (e.g. `Combine.Publishers.Output<A>`) elsewhere in the module.
                        var isPrecededByDot = false
                        if start > 0 && chars[start - 1] == "." {
                            isPrecededByDot = true
                        }
                        if !isGenericPrefix && !isPrecededByDot {
                            if let cVal = flatGenerics[word] {
                                count = cVal
                            } else if let cVal = shortGenerics[word] {
                                count = cVal
                            }
                        }
                        
                        if count > 0 {
                            let placeholders: String
                            if word == "Result" && count == 2 {
                                placeholders = "Any, Error"
                            } else if word == "InlineArray" && count == 2 {
                                placeholders = "1, Any"
                            } else if word == "CatalogAsset" && count == 2 {
                                placeholders = "ModelCatalog.GenericA, ModelCatalog.GenericA"
                            } else {
                                placeholders = Array(repeating: "Any", count: count).joined(separator: ", ")
                            }
                            result.append("\(word)<\(placeholders)>")
                            continue
                        }
                    }
                }
                result.append(word)
            } else {
                result.append(c)
                i += 1
            }
        }
        return result
    }

    // 23. stripGenericFromTypealias: removes `<Any, Any>` from LHS of public typealias declarations
    func stripGenericFromTypealias() -> String {
        guard let regex = try? NSRegularExpression(pattern: "(public\\s+typealias\\s+[A-Za-z0-9_]+)<(?:\\s*Any\\s*,)*\\s*Any\\s*>(\\s*=)", options: []) else {
            return self
        }
        let nsString = self as NSString
        return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: nsString.length), withTemplate: "$1$2")
    }

    // 24. stripGenericFromProtocol: removes `<Any, Any>` from LHS of protocol declarations
    func stripGenericFromProtocol() -> String {
        guard let regex = try? NSRegularExpression(pattern: "(protocol\\s+[A-Za-z0-9_]+)<(?:\\s*Any\\s*,)*\\s*Any\\s*>", options: []) else {
            return self
        }
        let nsString = self as NSString
        return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: nsString.length), withTemplate: "$1")
    }

    // 26. replaceMissingNestedTypes: handles fallbacks for missing nested types
    func replaceMissingNestedTypes(missingName: String) -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: missingName, range: startSearch..<result.endIndex) {
            var isValidPrefix = false
            var prefixStartIdx = range.lowerBound
            if range.lowerBound > result.startIndex {
                let beforeIdx = result.index(before: range.lowerBound)
                let beforeChar = result[beforeIdx]
                if beforeChar == "." || beforeChar == "_" {
                    var scanIdx = beforeIdx
                    while scanIdx > result.startIndex {
                        var checkIdx = scanIdx
                        var hasIdent = false
                        while checkIdx > result.startIndex {
                            let prevIdx = result.index(before: checkIdx)
                            let char = result[prevIdx]
                            let isIdentChar = char.isLetter || char.isNumber || char == "_" || char == "$"
                            if isIdentChar {
                                checkIdx = prevIdx
                                hasIdent = true
                            } else {
                                break
                            }
                        }
                        if hasIdent {
                            if checkIdx == result.startIndex {
                                isValidPrefix = true
                                prefixStartIdx = checkIdx
                                break
                            } else {
                                let beforeCharIdx = result.index(before: checkIdx)
                                let beforeChar = result[beforeCharIdx]
                                if beforeChar == "." || beforeChar == "_" {
                                    scanIdx = beforeCharIdx
                                } else if beforeChar.isWhitespace || beforeChar == "(" || beforeChar == "," || beforeChar == "<" || beforeChar == ">" {
                                    isValidPrefix = true
                                    prefixStartIdx = checkIdx
                                    break
                                } else {
                                    break
                                }
                            }
                        } else {
                            break
                        }
                    }
                }
            }
            
            let afterIdx = range.upperBound
            var isWordCharAfter = false
            if afterIdx < result.endIndex {
                let nextChar = result[afterIdx]
                isWordCharAfter = nextChar.isLetter || nextChar.isNumber || nextChar == "_" || nextChar == "$"
            }
            
            if isValidPrefix && !isWordCharAfter {
                let replaceRange = prefixStartIdx..<range.upperBound
                result.replaceSubrange(replaceRange, with: "PlaceholderB1")
                startSearch = result.index(prefixStartIdx, offsetBy: 13, limitedBy: result.endIndex) ?? result.endIndex
            } else {
                startSearch = range.upperBound
            }
        }
        return result
    }

    // 27. scanGenericTypeApplications: returns array of (name, params)
    func scanGenericTypeApplications() -> [(name: String, params: String)] {
        var results: [(name: String, params: String)] = []
        let chars = Array(self)
        let n = chars.count
        var i = 0
        while i < n {
            if chars[i] == "<" {
                if i + 1 < n {
                    let nextC = chars[i + 1]
                    if nextC == " " || nextC == "=" || nextC == "<" {
                        i += 1
                        continue
                    }
                }
                let nameEnd = i
                var nameStart = i
                while nameStart > 0 {
                    let prevChar = chars[nameStart - 1]
                    let isIdentChar = prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$" || prevChar == "."
                    if isIdentChar {
                        nameStart -= 1
                    } else {
                        break
                    }
                }
                
                if nameStart < nameEnd {
                    var isValidBoundary = true
                    if nameStart > 0 {
                        let beforeChar = chars[nameStart - 1]
                        let isIdentChar = beforeChar.isLetter || beforeChar.isNumber || beforeChar == "_" || beforeChar == "$"
                        if isIdentChar {
                            isValidBoundary = false
                        }
                    }
                    
                    if isValidBoundary {
                        var name = String(chars[nameStart..<nameEnd])
                        while name.hasPrefix(".") {
                            name = String(name.dropFirst())
                        }
                        while name.hasSuffix(".") {
                            name = String(name.dropLast())
                        }
                        
                        if !name.isEmpty {
                            var depth = 1
                            var j = i + 1
                            while j < n && depth > 0 {
                                if chars[j] == "<" {
                                    depth += 1
                                } else if chars[j] == ">" {
                                    depth -= 1
                                }
                                j += 1
                            }
                            if depth == 0 {
                                var params = String(chars[(i + 1)..<(j - 1)])
                                if let whereRange = params.range(of: " where ") {
                                    params = String(params[..<whereRange.lowerBound])
                                }
                                results.append((name: name, params: params))
                            }
                        }
                    }
                }
            }
            i += 1
        }
        return results
    }

    // 28. scanNamespaces: returns array of capitalized words followed by a dot
    func scanNamespaces() -> [String] {
        var results: [String] = []
        let chars = Array(self)
        let n = chars.count
        var i = 0
        while i < n {
            if chars[i] == "." {
                let wordEnd = i
                var wordStart = i
                while wordStart > 0 {
                    let prevChar = chars[wordStart - 1]
                    let isWordChar = prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$"
                    if isWordChar {
                        wordStart -= 1
                    } else {
                        break
                    }
                }
                
                if wordStart < wordEnd {
                    let firstChar = chars[wordStart]
                    if firstChar.isUppercase {
                        var isValidBoundary = true
                        if wordStart > 0 {
                            let beforeChar = chars[wordStart - 1]
                            let isWordChar = beforeChar.isLetter || beforeChar.isNumber || beforeChar == "_" || beforeChar == "$"
                            if isWordChar {
                                isValidBoundary = false
                            }
                        }
                        if isValidBoundary {
                            let ns = String(chars[wordStart..<wordEnd])
                            results.append(ns)
                        }
                    }
                }
            }
            i += 1
        }
        return results
    }

    // 29. scanProtocols: returns array of protocol names preceded by "any "
    func scanProtocols() -> [String] {
        var results: [String] = []
        let chars = Array(self)
        let n = chars.count
        var i = 0
        while i <= n - 4 {
            if chars[i] == "a" && chars[i+1] == "n" && chars[i+2] == "y" && chars[i+3] == " " {
                var isValidBoundary = true
                if i > 0 {
                    let prevChar = chars[i - 1]
                    let isWordChar = prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$"
                    if isWordChar {
                        isValidBoundary = false
                    }
                }
                
                if isValidBoundary {
                    var j = i + 4
                    while j < n {
                        let c = chars[j]
                        let isIdentChar = c.isLetter || c.isNumber || c == "_" || c == "$" || c == "."
                        if isIdentChar {
                            j += 1
                        } else {
                            break
                        }
                    }
                    
                    if j > i + 4 {
                        var protoName = String(chars[(i + 4)..<j])
                        while protoName.hasSuffix(".") {
                            protoName = String(protoName.dropLast())
                            j -= 1
                        }
                        
                        var isValidEnd = true
                        if j < n {
                            let nextChar = chars[j]
                            let isWordChar = nextChar.isLetter || nextChar.isNumber || nextChar == "_" || nextChar == "$"
                            if isWordChar {
                                isValidEnd = false
                            }
                        }
                        
                        if isValidEnd && !protoName.isEmpty {
                            results.append(protoName)
                        }
                    }
                }
                i += 3
            } else {
                i += 1
            }
        }
        return results
    }

    // 30. scanFrameworkDefinedTypes: returns Set of defined struct/class/enum/protocol/typealias names
    func scanFrameworkDefinedTypes() -> Set<String> {
        var defined = Set<String>()
        let keywords: Set<String> = ["struct", "class", "enum", "protocol", "typealias", "var", "func"]
        let chars = Array(self)
        let n = chars.count
        var i = 0
        while i < n {
            if chars[i].isLetter {
                let start = i
                while i < n && chars[i].isLetter {
                    i += 1
                }
                let word = String(chars[start..<i])
                if keywords.contains(word) {
                    var isValidBefore = true
                    if start > 0 {
                        let prevChar = chars[start - 1]
                        if prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$" {
                            isValidBefore = false
                        }
                    }
                    
                    if isValidBefore {
                        var j = i
                        while j < n && chars[j].isWhitespace {
                            j += 1
                        }
                        
                        if j < n && (chars[j].isLetter || chars[j] == "_" || chars[j] == "$") {
                            let identStart = j
                            while j < n && (chars[j].isLetter || chars[j].isNumber || chars[j] == "_" || chars[j] == "$") {
                                j += 1
                            }
                            
                            var isValidAfter = true
                            if j < n {
                                let nextChar = chars[j]
                                if nextChar.isLetter || nextChar.isNumber || nextChar == "_" || nextChar == "$" {
                                    isValidAfter = false
                                }
                            }
                            
                            if isValidAfter {
                                let typeName = String(chars[identStart..<j])
                                defined.insert(typeName)
                            }
                        }
                    }
                }
            } else {
                i += 1
            }
        }
        return defined
    }

    // 31. scanReferencedTypes: returns array of (typeName, isProtocol, genericCount)
    func scanReferencedTypes() -> [(typeName: String, isProtocol: Bool, genericCount: Int)] {
        var results: [(typeName: String, isProtocol: Bool, genericCount: Int)] = []
        let chars = Array(self)
        let n = chars.count
        var i = 0
        while i < n {
            if chars[i].isLetter || chars[i] == "_" || chars[i] == "$" {
                let start = i
                while i < n && (chars[i].isLetter || chars[i].isNumber || chars[i] == "_" || chars[i] == "$") {
                    i += 1
                }
                let word = String(chars[start..<i])
                
                var isCapitalized = false
                var scanIdx = word.startIndex
                while scanIdx < word.endIndex && (word[scanIdx] == "_" || word[scanIdx] == "$") {
                    scanIdx = word.index(after: scanIdx)
                }
                if scanIdx < word.endIndex && word[scanIdx].isUppercase {
                    isCapitalized = true
                }
                
                if isCapitalized {
                    var isValidBefore = true
                    if start > 0 {
                        let prevChar = chars[start - 1]
                        if prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$" {
                            isValidBefore = false
                        }
                    }
                    
                    if isValidBefore {
                        var isProtocol = false
                        var prevIdx = start
                        while prevIdx > 0 && chars[prevIdx - 1].isWhitespace {
                            prevIdx -= 1
                        }
                        if prevIdx >= 3 {
                            let anyWord = String(chars[(prevIdx - 3)..<prevIdx])
                            if anyWord == "any" {
                                var isAnyBoundary = true
                                if prevIdx - 3 > 0 {
                                    let beforeAny = chars[prevIdx - 4]
                                    if beforeAny.isLetter || beforeAny.isNumber || beforeAny == "_" || beforeAny == "$" {
                                        isAnyBoundary = false
                                    }
                                }
                                if isAnyBoundary {
                                    isProtocol = true
                                }
                            }
                        }
                        
                        var genericCount = 0
                        var nextIdx = i
                        while nextIdx < n && chars[nextIdx].isWhitespace {
                            nextIdx += 1
                        }
                        if nextIdx < n && chars[nextIdx] == "<" {
                            var depth = 1
                            var commas = 0
                            var scan = nextIdx + 1
                            while scan < n && depth > 0 {
                                let c = chars[scan]
                                if c == "<" { depth += 1 }
                                else if c == ">" { depth -= 1 }
                                else if c == "," && depth == 1 { commas += 1 }
                                scan += 1
                            }
                            if depth == 0 {
                                genericCount = commas + 1
                            }
                        }
                        
                        results.append((typeName: word, isProtocol: isProtocol, genericCount: genericCount))
                    }
                }
            } else {
                i += 1
            }
        }
        return results
    }

    // 32. stripGenericFromSequence: replaces bare Sequence<...> (the stdlib protocol used as a
    // primary-associated-type existential, e.g. `any Sequence<Element>`) with Sequence, since
    // that constrained-existential syntax can't be expressed generically here. Does NOT touch
    // module-qualified or dot-nested occurrences like `Publishers.Sequence<A, B>` or
    // `Swift.Sequence<A>` — those name a real concrete/nested generic type (e.g. Combine's own
    // Publishers.Sequence), not the bare existential this function targets.
    func stripGenericFromSequence() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: "Sequence<", range: startSearch..<result.endIndex) {
            if range.lowerBound > result.startIndex {
                let prevIdx = result.index(before: range.lowerBound)
                let prevChar = result[prevIdx]
                if prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$" || prevChar == "." {
                    startSearch = range.upperBound
                    continue
                }
            }
            var depth = 1
            var scanIdx = range.upperBound
            while scanIdx < result.endIndex && depth > 0 {
                let char = result[scanIdx]
                if char == "<" {
                    depth += 1
                } else if char == ">" {
                    depth -= 1
                }
                scanIdx = result.index(after: scanIdx)
            }
            if depth == 0 {
                let replaceRange = range.lowerBound..<scanIdx
                result.replaceSubrange(replaceRange, with: "Sequence")
                startSearch = result.index(range.lowerBound, offsetBy: 8, limitedBy: result.endIndex) ?? result.endIndex
            } else {
                startSearch = range.upperBound
            }
        }
        return result
    }

    // 33. stripModuleBeforeAngle: replaces Word.< with <
    func stripModuleBeforeAngle() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: ".<", range: startSearch..<result.endIndex) {
            var wordStart = range.lowerBound
            while wordStart > result.startIndex {
                let prevIdx = result.index(before: wordStart)
                let char = result[prevIdx]
                if char.isLetter || char.isNumber || char == "_" || char == "$" {
                    wordStart = prevIdx
                } else {
                    break
                }
            }
            if wordStart < range.lowerBound {
                let replaceRange = wordStart..<range.upperBound
                result.replaceSubrange(replaceRange, with: "<")
                startSearch = wordStart
            } else {
                startSearch = range.upperBound
            }
        }
        return result
    }

    // 34. stripExtensionInParens: replaces (extension in ...): with empty string
    func stripExtensionInParens() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: "(extension in ", range: startSearch..<result.endIndex) {
            var scanIdx = range.upperBound
            var found = false
            while scanIdx < result.endIndex {
                if result[scanIdx] == ")" {
                    let nextIdx = result.index(after: scanIdx)
                    if nextIdx < result.endIndex && result[nextIdx] == ":" {
                        let replaceRange = range.lowerBound..<result.index(after: nextIdx)
                        result.replaceSubrange(replaceRange, with: "")
                        startSearch = range.lowerBound
                        found = true
                        break
                    }
                }
                scanIdx = result.index(after: scanIdx)
            }
            if !found {
                startSearch = range.upperBound
            }
        }
        return result
    }

    // 35. replaceExtensionParensWithAny: replaces (extension ...) with Any
    func replaceExtensionParensWithAny() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: "(extension", range: startSearch..<result.endIndex) {
            var scanIdx = range.upperBound
            var found = false
            while scanIdx < result.endIndex {
                if result[scanIdx] == ")" {
                    let replaceRange = range.lowerBound..<result.index(after: scanIdx)
                    result.replaceSubrange(replaceRange, with: "Any")
                    startSearch = result.index(range.lowerBound, offsetBy: 3, limitedBy: result.endIndex) ?? result.endIndex
                    found = true
                    break
                }
                scanIdx = result.index(after: scanIdx)
            }
            if !found {
                startSearch = range.upperBound
            }
        }
        return result
    }

    // 36. stripNumbersAfterParen: replaces )[0-9]+ with )
    func stripNumbersAfterParen() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: ")", range: startSearch..<result.endIndex) {
            var scanIdx = range.upperBound
            while scanIdx < result.endIndex && result[scanIdx].isNumber {
                scanIdx = result.index(after: scanIdx)
            }
            if scanIdx > range.upperBound {
                let replaceRange = range.lowerBound..<scanIdx
                result.replaceSubrange(replaceRange, with: ")")
                startSearch = range.upperBound
            } else {
                startSearch = range.upperBound
            }
        }
        return result
    }

    // 37. stripGenericAngles: removes <...> generic parameters from a type name
    func stripGenericAngles() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: "<", range: startSearch..<result.endIndex) {
            var depth = 1
            var scanIdx = range.upperBound
            while scanIdx < result.endIndex && depth > 0 {
                let char = result[scanIdx]
                if char == "<" {
                    depth += 1
                } else if char == ">" {
                    depth -= 1
                }
                scanIdx = result.index(after: scanIdx)
            }
            if depth == 0 {
                let replaceRange = range.lowerBound..<scanIdx
                result.replaceSubrange(replaceRange, with: "")
                startSearch = range.lowerBound
            } else {
                startSearch = range.upperBound
            }
        }
        return result
    }
    
    // removingUnusedMethodGenericParams: removes method-level generic params (e.g. GenericA, GenericB)
    // from the `<...>` bracket before `(` if they are not actually used in the function's
    // arguments or return type. Prevents "generic parameter 'GenericX' is not used in function
    // signature" compiler errors.
    func removingUnusedMethodGenericParams() -> String {
        // Find the method generic brackets: the `<...>` that appears before `(`
        guard let openParen = self.firstIndex(of: "(") else { return self }
        guard let openAngle = self.firstIndex(of: "<"), openAngle < openParen else { return self }
        
        // Make sure the `>` that closes the bracket is before `(`
        var depth = 0
        var closeAngle: String.Index? = nil
        var i = openAngle
        while i < openParen {
            if self[i] == "<" { depth += 1 }
            else if self[i] == ">" {
                depth -= 1
                if depth == 0 { closeAngle = i; break }
            }
            i = self.index(after: i)
        }
        guard let ca = closeAngle else { return self }
        
        // Extract the param list inside the bracket
        let bracketContent = String(self[self.index(after: openAngle)..<ca])
        // The function body is everything from `(` onward
        let funcBody = String(self[openParen...])
        
        var checkBody = funcBody
        var whereClause = ""
        if let whereRange = funcBody.range(of: " where ") {
            checkBody = String(funcBody[..<whereRange.lowerBound])
            whereClause = String(funcBody[whereRange.upperBound...])
        } else if let whereRange = funcBody.range(of: "where ") {
            checkBody = String(funcBody[..<whereRange.lowerBound])
            whereClause = String(funcBody[whereRange.upperBound...])
        }
        
        // Parse generic params (split on comma, handling nested brackets)
        let rawParams = bracketContent.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        var keptParams = [String]()
        var prunedParams = Set<String>()
        for param in rawParams {
            if param.isEmpty { continue }
            var cleanParam = param
            if cleanParam.hasPrefix("each ") {
                cleanParam = String(cleanParam.dropFirst(5)).trimmingCharacters(in: .whitespaces)
            }
            // Check if the param name (whole-word) appears in the signature (excluding where clause)
            let usedInSig = checkBody.replaceWord(cleanParam, with: "").count < checkBody.count
            if usedInSig {
                keptParams.append(param)
            } else {
                prunedParams.insert(cleanParam)
                prunedParams.insert(param)
            }
        }
        
        // Clean up the where clause: remove constraints referencing pruned parameters
        // and also any constraints containing ~Copyable.
        var finalWhere = ""
        if !whereClause.isEmpty {
            let constraints = whereClause.splitByCommaRespectingBrackets()
            var keptConstraints = [String]()
            for constraint in constraints {
                let trimmed = constraint.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty { continue }
                if trimmed.contains("~Copyable") || trimmed.contains("~ Copyable") {
                    continue
                }
                var mentionsPruned = false
                for pruned in prunedParams {
                    if trimmed.replaceWord(pruned, with: "").count < trimmed.count {
                        mentionsPruned = true
                        break
                    }
                }
                if !mentionsPruned {
                    keptConstraints.append(trimmed)
                }
            }
            if !keptConstraints.isEmpty {
                finalWhere = " where " + keptConstraints.joined(separator: ", ")
            }
        }
        
        let prefix = String(self[..<openAngle])
        let suffix = String(self[self.index(after: ca)...])
        
        // If we removed the where clause from funcBody, we must replace it in the returned string
        let baseSig = suffix.range(of: " where ") != nil ? String(suffix[..<suffix.range(of: " where ")!.lowerBound]) : (suffix.range(of: "where ") != nil ? String(suffix[..<suffix.range(of: "where ")!.lowerBound]) : suffix)
        
        if keptParams.isEmpty {
            return prefix + baseSig + finalWhere
        } else {
            return prefix + "<" + keptParams.joined(separator: ", ") + ">" + baseSig + finalWhere
        }
    }

    func flattenTypePath(forPrefix prefix: String) -> String {
        var result = self
        var startIdx = result.startIndex
        while let range = result.range(of: prefix + ".", range: startIdx..<result.endIndex) {
            let nextStart = range.upperBound
            var endIdx = nextStart
            var scan = nextStart
            var currentWordIsCapitalized = true
            
            while scan < result.endIndex {
                let wordStart = scan
                while scan < result.endIndex && (result[scan].isLetter || result[scan].isNumber || result[scan] == "_" || result[scan] == "$") {
                    scan = result.index(after: scan)
                }
                let word = String(result[wordStart..<scan])
                if let firstChar = word.first, firstChar.isUppercase {
                    currentWordIsCapitalized = true
                } else {
                    currentWordIsCapitalized = false
                }
                
                if !currentWordIsCapitalized {
                    break
                }
                
                endIdx = scan
                
                if scan < result.endIndex && result[scan] == "." {
                    scan = result.index(after: scan)
                } else {
                    break
                }
            }
            
            let subPath = String(result[range.lowerBound..<endIdx])
            let flatSubPath = subPath.replacingOccurrences(of: ".", with: "_")
            result.replaceSubrange(range.lowerBound..<endIdx, with: flatSubPath)
            startIdx = result.index(range.lowerBound, offsetBy: flatSubPath.count)
        }
        return result
    }

    // Replaces `any Self` inside protocol bodies with `any <ProtocolName>`.
    // The demangler sometimes produces `[any Self]` for protocol requirements whose
    // real Swift source uses the protocol name (e.g. `[any AppleIntelligenceError]`).
    // Leaving `[any Self]` causes conforming types that implement `[any Proto]` to
    // fail with "does not conform to protocol".
    func replaceAnySelfInProtocolBodies() -> String {
        let lines = self.components(separatedBy: "\n")
        var result = [String]()
        // Stack of (protocolName, minDepthToRemain): pop when globalDepth < minDepthToRemain
        var protocolStack: [(name: String, minDepth: Int)] = []
        var depth = 0

        for line in lines {
            let opens = line.filter { $0 == "{" }.count
            let closes = line.filter { $0 == "}" }.count
            let net = opens - closes

            // Detect `protocol Name` opening on this line
            if opens > 0 {
                var searchStart = line.startIndex
                while let kRange = line.range(of: "protocol ", range: searchStart..<line.endIndex) {
                    let afterKeyword = kRange.upperBound
                    // Read the protocol name (alphanumeric + _)
                    var nameEnd = afterKeyword
                    while nameEnd < line.endIndex && (line[nameEnd].isLetter || line[nameEnd].isNumber || line[nameEnd] == "_") {
                        nameEnd = line.index(after: nameEnd)
                    }
                    if nameEnd > afterKeyword {
                        let protocolName = String(line[afterKeyword..<nameEnd])
                        // minDepth = depth after processing this line
                        protocolStack.append((name: protocolName, minDepth: depth + net))
                    }
                    searchStart = kRange.upperBound
                }
            }

            // Replace `any Self` if inside a protocol body
            var processedLine = line
            if let current = protocolStack.last {
                processedLine = processedLine.replacingOccurrences(of: "any Self", with: "any \(current.name)")
            }

            depth += net

            // Pop protocols whose body has been closed
            while let top = protocolStack.last, depth < top.minDepth {
                protocolStack.removeLast()
            }

            result.append(processedLine)
        }

        return result.joined(separator: "\n")
    }

    func fixResultAndEmptyFailureTypes() -> String {
        var result = self
        var searchStart = result.startIndex
        
        while searchStart < result.endIndex {
            var foundIndex: String.Index? = nil
            var isResult = true
            
            if let resultRange = result.range(of: "Result<", range: searchStart..<result.endIndex) {
                if let emptyRange = result.range(of: "Empty<", range: searchStart..<result.endIndex) {
                    if resultRange.lowerBound < emptyRange.lowerBound {
                        foundIndex = resultRange.lowerBound
                        isResult = true
                    } else {
                        foundIndex = emptyRange.lowerBound
                        isResult = false
                    }
                } else {
                    foundIndex = resultRange.lowerBound
                    isResult = true
                }
            } else if let emptyRange = result.range(of: "Empty<", range: searchStart..<result.endIndex) {
                foundIndex = emptyRange.lowerBound
                isResult = false
            }
            
            guard let start = foundIndex else {
                break
            }
            
            let scanStart = result.index(start, offsetBy: isResult ? 7 : 6)
            var depth = 1
            var parenDepth = 0
            var i = scanStart
            var topLevelComma: String.Index? = nil
            
            while i < result.endIndex && depth > 0 {
                let char = result[i]
                if char == "<" {
                    depth += 1
                } else if char == ">" {
                    depth -= 1
                } else if char == "(" {
                    parenDepth += 1
                } else if char == ")" {
                    parenDepth -= 1
                } else if char == "," && depth == 1 && parenDepth == 0 {
                    topLevelComma = i
                }
                if depth > 0 {
                    i = result.index(after: i)
                }
            }
            
            if depth == 0, let comma = topLevelComma {
                let afterCommaStart = result.index(after: comma)
                let secondArg = result[afterCommaStart..<i]
                let trimmed = secondArg.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed == "Any" {
                    let replacement = "any Swift.Error"
                    result.replaceSubrange(afterCommaStart..<i, with: replacement)
                    let newEndOffset = result.distance(from: result.startIndex, to: afterCommaStart) + replacement.count
                    searchStart = result.index(result.startIndex, offsetBy: newEndOffset)
                    continue
                }
            }
            
            searchStart = result.index(after: start)
        }

        return result
    }

    // Drops declarations that reference a private, underscore-prefixed ObjC type via
    // "__C._Foo" (e.g. Translation's `_LTTextSessionDelegate`, HealthKit's
    // `_HKQuantityDistributionStyle`). These types have real ABI symbols but no declaration in
    // the framework's public header, so `import-underlying-module`/`__C` can never resolve
    // them — Apple's own .swiftinterface simply omits the member entirely. Drops the whole
    // member's line(s) for properties/methods, and the whole block for `extension __C._Foo { }`.
    func removePrivateObjCTypeReferences() -> String {
        // "__C._Foo" (underscore-prefixed Swift-facing name) and "__C.snake_case" (a bare C
        // struct/typedef simplifyType deliberately left qualified, see the "__C." handling in
        // Parser.simplifyType) both indicate a type with no public Swift declaration.
        let referencesPrivateType: (String) -> Bool = { line in
            if line.contains("__C._") { return true }
            var searchStart = line.startIndex
            while let range = line.range(of: "__C.", range: searchStart..<line.endIndex) {
                if range.upperBound < line.endIndex, line[range.upperBound].isLowercase {
                    return true
                }
                searchStart = range.upperBound
            }
            return false
        }
        let lines = self.components(separatedBy: "\n")
        var result = [String]()
        var skipDepth = 0
        var i = 0
        while i < lines.count {
            let line = lines[i]
            if skipDepth > 0 {
                skipDepth += line.filter { $0 == "{" }.count
                skipDepth -= line.filter { $0 == "}" }.count
                i += 1
                continue
            }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("extension __C._"), trimmed.contains("{") {
                skipDepth = 1 + line.filter { $0 == "{" }.count - 1
                i += 1
                continue
            }
            if referencesPrivateType(line) {
                // A one-line member (property/method/init with a body on the same line) is
                // simply dropped; a multi-line opening brace would need block-skip, but every
                // member emitted by generateCode is single-line, so this is sufficient.
                i += 1
                continue
            }
            result.append(line)
            i += 1
        }
        return result.joined(separator: "\n")
    }

    func splitByCommaRespectingBrackets() -> [String] {
        var result = [String]()
        var current = ""
        var depth = 0
        let chars = Array(self)
        var idx = 0
        let n = chars.count
        while idx < n {
            let char = chars[idx]
            if char == "<" || char == "(" || char == "[" {
                depth += 1
            } else if char == ">" || char == ")" || char == "]" {
                depth -= 1
            }
            if char == "," && depth == 0 {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
            idx += 1
        }
        if !current.isEmpty {
            result.append(current)
        }
        return result
    }

    func removeAnyConstraintsFromWhereClause() -> String {
        let lines = self.components(separatedBy: "\n")
        let fixed = lines.map { line -> String in
            guard let whereRange = line.range(of: " where ") else { return line }
            let prefix = String(line[..<whereRange.lowerBound])
            let suffix = String(line[whereRange.upperBound...])
            var body = suffix
            var trailing = ""
            if let braceRange = suffix.range(of: " {") {
                body = String(suffix[..<braceRange.lowerBound])
                trailing = String(suffix[braceRange.lowerBound...])
            }
            let constraints = body.splitByCommaRespectingBrackets()
            let kept = constraints.filter { c in
                let trimmed = c.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("Any == ") || trimmed.hasPrefix("Any:") || trimmed.hasPrefix("Any.") { return false }
                if trimmed.contains("Any ==") || trimmed.contains("Any :") { return false }
                if trimmed.hasSuffix("== Any") || trimmed.hasSuffix(": Any") { return false }
                if trimmed.contains("== Any") || trimmed.contains(": Any") { return false }
                return true
            }
            if kept.isEmpty {
                return prefix + trailing
            } else {
                return prefix + " where " + kept.joined(separator: ", ") + trailing
            }
        }
        return fixed.joined(separator: "\n")
    }

    func stripRawRepresentableWrapperExtensions() -> String {
        let lines = self.components(separatedBy: "\n")
        var output = [String]()
        var skipping = false
        var depth = 0
        for line in lines {
            if !skipping && line.contains("extension RawRepresentableWrapper") {
                skipping = true
                depth = line.reduce(0) { $0 + ($1 == "{" ? 1 : 0) - ($1 == "}" ? 1 : 0) }
                if depth <= 0 { skipping = false }
                continue
            }
            if skipping {
                depth += line.reduce(0) { $0 + ($1 == "{" ? 1 : 0) - ($1 == "}" ? 1 : 0) }
                if depth <= 0 { skipping = false }
                continue
            }
            output.append(line)
        }
        return output.joined(separator: "\n")
    }
}

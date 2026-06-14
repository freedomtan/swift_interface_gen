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
    func replaceWord(_ word: String, with replacement: String) -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: word, range: startSearch..<result.endIndex) {
            let isWordCharBefore: Bool
            if range.lowerBound > result.startIndex {
                let prevChar = result[result.index(before: range.lowerBound)]
                isWordCharBefore = prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$"
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
            
            if !isWordCharBefore && !isWordCharAfter {
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
    func replaceWordWithoutGeneric(_ word: String, with replacement: String) -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: word, range: startSearch..<result.endIndex) {
            let isWordCharBefore: Bool
            if range.lowerBound > result.startIndex {
                let prevChar = result[result.index(before: range.lowerBound)]
                isWordCharBefore = prevChar.isLetter || prevChar.isNumber || prevChar == "_" || prevChar == "$"
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

    // 11. replacePlaceholderDotsWithSelf: replaces `\b[A-Z][0-9]?\.` with `"Self."`.
    func replacePlaceholderDotsWithSelf() -> String {
        var result = self
        var startSearch = result.startIndex
        while startSearch < result.endIndex {
            guard let dotIdx = result[startSearch...].firstIndex(of: ".") else { break }
            
            let checkIdx = dotIdx
            var matched = false
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
                                result.replaceSubrange(prevPrevIdx...dotIdx, with: "Self.")
                                matched = true
                                startSearch = result.index(prevPrevIdx, offsetBy: 5)
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
                        result.replaceSubrange(prevIdx...dotIdx, with: "Self.")
                        matched = true
                        startSearch = result.index(prevIdx, offsetBy: 5)
                    }
                }
            }
            
            if !matched {
                startSearch = result.index(after: dotIdx)
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
                result.replaceSubrange(range.lowerBound..<endPathIdx, with: "Any")
                startSearch = result.index(range.lowerBound, offsetBy: 3, limitedBy: result.endIndex) ?? result.endIndex
            } else {
                startSearch = range.upperBound
            }
        }
        return result
    }

    // 13. replaceGenericPlaceholderPathsWithAny: replaces `\b[A-Z][0-9]?\.[a-zA-Z0-9_$]+(?:\.[a-zA-Z0-9_$]+)*\b` with `"Any"`.
    func replaceGenericPlaceholderPathsWithAny() -> String {
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
                    result.replaceSubrange(prefixStartIdx..<endPathIdx, with: "Any")
                    startSearch = result.index(prefixStartIdx, offsetBy: 3, limitedBy: result.endIndex) ?? result.endIndex
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
    func replaceSelfPattern(parentName: String, replaceWith: String) -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: parentName, range: startSearch..<result.endIndex) {
            var isValidPrefix = false
            var prefixStartIdx = range.lowerBound
            if range.lowerBound > result.startIndex {
                let beforeDotIdx = result.index(before: range.lowerBound)
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

    // 17. hasGenericPlaceholderInBrackets: checks if the string contains a generic placeholder whole-word inside <...>
    func hasGenericPlaceholderInBrackets(p: String) -> Bool {
        guard let openIdx = self.firstIndex(of: "<"),
              let closeIdx = self.firstIndex(of: ">"),
              openIdx < closeIdx else { return false }
        let inside = String(self[self.index(after: openIdx)..<closeIdx])
        
        let variations = [p, "\(p)1", "\(p)2", "\(p)3", "\(p)4"]
        for v in variations {
            var startSearch = inside.startIndex
            while let range = inside.range(of: v, range: startSearch..<inside.endIndex) {
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
            if let prefixRange = result[postFuncIdx...].range(of: " prefix(") {
                let opName = String(result[postFuncIdx..<prefixRange.lowerBound])
                if !opName.contains(" ") && !opName.isEmpty {
                    let fullRange = range.lowerBound..<prefixRange.upperBound
                    let replacement = "prefix func \(opName)("
                    result.replaceSubrange(fullRange, with: replacement)
                    startSearch = result.index(range.lowerBound, offsetBy: replacement.count, limitedBy: result.endIndex) ?? result.endIndex
                    continue
                }
            }
            startSearch = range.upperBound
        }
        
        startSearch = result.startIndex
        while let range = result.range(of: "func ", range: startSearch..<result.endIndex) {
            let postFuncIdx = range.upperBound
            if let postfixRange = result[postFuncIdx...].range(of: " postfix(") {
                let opName = String(result[postFuncIdx..<postfixRange.lowerBound])
                if !opName.contains(" ") && !opName.isEmpty {
                    let fullRange = range.lowerBound..<postfixRange.upperBound
                    let replacement = "postfix func \(opName)("
                    result.replaceSubrange(fullRange, with: replacement)
                    startSearch = result.index(range.lowerBound, offsetBy: replacement.count, limitedBy: result.endIndex) ?? result.endIndex
                    continue
                }
            }
            startSearch = range.upperBound
        }
        
        return result
    }

    // 20. stripAnyGenericApplicationBeforeParen: strips <Any> and <Any, Any> before parenthesis
    func stripAnyGenericApplicationBeforeParen() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: "<Any", range: startSearch..<result.endIndex) {
            var scanIdx = range.upperBound
            var onlyAny = true
            while scanIdx < result.endIndex {
                let char = result[scanIdx]
                if char == ">" {
                    let nextIdx = result.index(after: scanIdx)
                    if nextIdx < result.endIndex && result[nextIdx] == "(" {
                        let replaceRange = range.lowerBound...scanIdx
                        result.replaceSubrange(replaceRange, with: "")
                        scanIdx = range.lowerBound
                    }
                    break
                } else if char == "," || char.isWhitespace {
                    scanIdx = result.index(after: scanIdx)
                } else {
                    let nextRange = result.index(scanIdx, offsetBy: 3, limitedBy: result.endIndex)
                    if let endAnyIdx = nextRange, result[scanIdx..<endAnyIdx] == "Any" {
                        scanIdx = endAnyIdx
                    } else {
                        onlyAny = false
                        break
                    }
                }
            }
            if onlyAny {
                startSearch = scanIdx
            } else {
                startSearch = range.upperBound
            }
        }
        return result
    }

    // 21. stripInvalidAnyPrefixes: removes 'any' keyword before concrete types
    func stripInvalidAnyPrefixes(concreteTypes: Set<String>) -> String {
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
                let isIdentChar = char.isLetter || char.isNumber || char == "_" || char == "$"
                if isIdentChar {
                    scanIdx = result.index(after: scanIdx)
                } else {
                    break
                }
            }
            
            let typeNameRange = range.upperBound..<scanIdx
            let fullType = String(result[typeNameRange])
            
            if !fullType.isEmpty {
                var baseType = fullType
                if let underscoreIdx = fullType.firstIndex(of: "_") {
                    baseType = String(fullType[result.index(after: underscoreIdx)...])
                }
                
                if concreteTypes.contains(baseType) || concreteTypes.contains(fullType) {
                    result.replaceSubrange(range, with: "")
                    startSearch = range.lowerBound
                    continue
                }
            }
            startSearch = range.upperBound
        }
        return result
    }

    // 22. applyDiscoveredGenerics: appends generic placeholders to types found in flatGenerics/shortGenerics
    func applyDiscoveredGenerics(flatGenerics: [String: Int], shortGenerics: [String: Int]) -> String {
        var result = self
        var startSearch = result.startIndex
        while startSearch < result.endIndex {
            var idx = startSearch
            var matchFound = false
            var wordStart = idx
            var wordEnd = idx
            
            while idx < result.endIndex {
                let isStart = (idx == result.startIndex || (!result[result.index(before: idx)].isLetter && !result[result.index(before: idx)].isNumber && result[result.index(before: idx)] != "_" && result[result.index(before: idx)] != "$"))
                
                if isStart {
                    var scanIdx = idx
                    while scanIdx < result.endIndex && (result[scanIdx] == "_") {
                        scanIdx = result.index(after: scanIdx)
                    }
                    if scanIdx < result.endIndex && result[scanIdx].isUppercase {
                        wordStart = idx
                        while scanIdx < result.endIndex && (result[scanIdx].isLetter || result[scanIdx].isNumber || result[scanIdx] == "_" || result[scanIdx] == "$") {
                            scanIdx = result.index(after: scanIdx)
                        }
                        wordEnd = scanIdx
                        matchFound = true
                        break
                    }
                }
                idx = result.index(after: idx)
            }
            
            if matchFound {
                let wordRange = wordStart..<wordEnd
                let typeName = String(result[wordRange])
                
                let followedByGeneric = (wordEnd < result.endIndex && result[wordEnd] == "<")
                
                if !followedByGeneric {
                    var count = 0
                    if let cVal = flatGenerics[typeName] {
                        count = cVal
                    } else if let cVal = shortGenerics[typeName] {
                        count = cVal
                    }
                    
                    if count > 0 {
                        let placeholders = Array(repeating: "Any", count: count).joined(separator: ", ")
                        let replacement = "\(typeName)<\(placeholders)>"
                        result.replaceSubrange(wordRange, with: replacement)
                        startSearch = result.index(wordStart, offsetBy: replacement.count, limitedBy: result.endIndex) ?? result.endIndex
                        continue
                    }
                }
                startSearch = wordEnd
            } else {
                break
            }
        }
        return result
    }

    // 23. stripGenericFromTypealias: removes `<Any, Any>` from LHS of public typealias declarations
    func stripGenericFromTypealias() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: "public typealias ", range: startSearch..<result.endIndex) {
            let afterAliasIdx = range.upperBound
            if let eqRange = result[afterAliasIdx...].range(of: "=") {
                let leftHandSide = String(result[afterAliasIdx..<eqRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                if let openBracket = leftHandSide.firstIndex(of: "<"),
                   let closeBracket = leftHandSide.firstIndex(of: ">"),
                   openBracket < closeBracket {
                    let aliasName = String(leftHandSide[..<openBracket]).trimmingCharacters(in: .whitespaces)
                    let genericPart = String(leftHandSide[openBracket...closeBracket])
                    let cleanedGen = genericPart.replacingOccurrences(of: "<", with: "")
                                                .replacingOccurrences(of: ">", with: "")
                                                .replacingOccurrences(of: "Any", with: "")
                                                .replacingOccurrences(of: ",", with: "")
                                                .trimmingCharacters(in: .whitespaces)
                    if cleanedGen.isEmpty {
                        let replaceRange = afterAliasIdx..<eqRange.lowerBound
                        result.replaceSubrange(replaceRange, with: aliasName + " ")
                        startSearch = result.index(afterAliasIdx, offsetBy: aliasName.count + 1, limitedBy: result.endIndex) ?? result.endIndex
                        continue
                    }
                }
            }
            startSearch = range.upperBound
        }
        return result
    }

    // 24. stripGenericFromProtocol: removes `<Any, Any>` from LHS of protocol declarations
    func stripGenericFromProtocol() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: "protocol ", range: startSearch..<result.endIndex) {
            let afterProtoIdx = range.upperBound
            if let openBracket = result[afterProtoIdx...].firstIndex(of: "<") {
                let prefix = String(result[afterProtoIdx..<openBracket]).trimmingCharacters(in: .whitespaces)
                if !prefix.isEmpty && !prefix.contains(":") && !prefix.contains("{") {
                    var scanIdx = result.index(after: openBracket)
                    var onlyAny = true
                    while scanIdx < result.endIndex {
                        let char = result[scanIdx]
                        if char == ">" {
                            break
                        } else if char == "," || char.isWhitespace {
                            scanIdx = result.index(after: scanIdx)
                        } else {
                            let nextRange = result.index(scanIdx, offsetBy: 3, limitedBy: result.endIndex)
                            if let endAnyIdx = nextRange, result[scanIdx..<endAnyIdx] == "Any" {
                                scanIdx = endAnyIdx
                            } else {
                                onlyAny = false
                                break
                            }
                        }
                    }
                    if onlyAny && scanIdx < result.endIndex && result[scanIdx] == ">" {
                        result.replaceSubrange(openBracket...scanIdx, with: "")
                        startSearch = openBracket
                        continue
                    }
                }
            }
            startSearch = range.upperBound
        }
        return result
    }

    // 25. stripGenericFromView: replaces `.View<...>` with `.View`
    func stripGenericFromView() -> String {
        var result = self
        var startSearch = result.startIndex
        while let range = result.range(of: ".View<", range: startSearch..<result.endIndex) {
            var scanIdx = range.upperBound
            while scanIdx < result.endIndex && result[scanIdx] != ">" {
                scanIdx = result.index(after: scanIdx)
            }
            if scanIdx < result.endIndex && result[scanIdx] == ">" {
                result.replaceSubrange(range.lowerBound...scanIdx, with: ".View")
                startSearch = result.index(range.lowerBound, offsetBy: 5)
            } else {
                break
            }
        }
        return result
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
                                let params = String(chars[(i + 1)..<(j - 1)])
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
        let keywords: Set<String> = ["struct", "class", "enum", "protocol", "typealias"]
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

    // 31. scanReferencedTypes: returns array of (typeName, isProtocol, isGeneric)
    func scanReferencedTypes() -> [(typeName: String, isProtocol: Bool, isGeneric: Bool)] {
        var results: [(typeName: String, isProtocol: Bool, isGeneric: Bool)] = []
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
                        
                        var isGeneric = false
                        var nextIdx = i
                        while nextIdx < n && chars[nextIdx].isWhitespace {
                            nextIdx += 1
                        }
                        if nextIdx < n && chars[nextIdx] == "<" {
                            isGeneric = true
                        }
                        
                        results.append((typeName: word, isProtocol: isProtocol, isGeneric: isGeneric))
                    }
                }
            } else {
                i += 1
            }
        }
        return results
    }
}

import Foundation

public struct TreeNode {
    public let kind: String
    public let text: String?
    public let indent: Int
    
    public init(kind: String, text: String?, indent: Int) {
        self.kind = kind
        self.text = text
        self.indent = indent
    }
}

public class TreeNodeObj {
    public let kind: String
    public let text: String?
    public var children = [TreeNodeObj]()
    
    public init(kind: String, text: String?) {
        self.kind = kind
        self.text = text
    }
}

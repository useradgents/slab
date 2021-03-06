import Foundation

/// Placeholder text generator
public enum Lipsum {
    /// Generate a random number of words in the given word count range
    public static func words(_ count: ClosedRange<Int>) -> String {
        var remaining = count.randomElement() ?? 1
        var ret: [String] = []
        while remaining > 0 {
            let wordsFromPhrase = words.randomElement()!.prefix(remaining)
            remaining -= wordsFromPhrase.count
            ret += wordsFromPhrase
        }
        var words = ret.joined(separator: " ")
        while let last = words.last, !last.isLetter {
            words.removeLast()
        }
        return words
    }
    
    /// Generate a random number of phrases in the given phrase count range, specifying the separator between each phrase
    public static func phrases(_ count: ClosedRange<Int>, separator: String = "\n") -> String {
        let count = count.randomElement() ?? 1
        return (0..<count).map { _ in words.randomElement()!.joined(separator: " ") }.joined(separator: separator)
    }
    
    /// Generate a given number of words
    public static func words(_ count: Int) -> String { words(count...count) }
    
    /// Generate a random string of 1 to 3 words
    public static func fewWords() -> String { words(1...3) }
    
    /// Generate a random string of 3 to 8 words
    public static func someWords() -> String { words(3...8) }
    
    /// Generate a random string of 8 to 20 words
    public static func manyWords() -> String { words(8...20) }
    
    /// Generate a given number of phrases, specifying the separator between each phrase
    public static func phrases(_ count: Int, separator: String = "\n") -> String { phrases(count...count, separator: separator) }
    
    /// Generate a small (between 1 and 3) number of random phrases
    public static func fewPhrases(separator: String = "\n") -> String { phrases(1...3, separator: separator) }
    
    /// Generate an average (between 3 and 8) number of random phrases
    public static func somePhrases(separator: String = "\n") -> String { phrases(3...8, separator: separator) }
    
    /// Generate a large (between 8 and 20) number of random phrases
    public static func manyPhrases(separator: String = "\n") -> String { phrases(8...20, separator: separator) }
    
    static let words = [
        ["Lorem", "ipsum", "dolor", "sit", "amet,", "consectetur", "adipiscing", "elit,", "sed", "do", "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore", "magna", "aliqua."],
        ["Ut", "enim", "ad", "minim", "veniam,", "quis", "nostrud", "exercitation", "ullamco", "laboris", "nisi", "ut", "aliquip", "ex", "ea", "commodo", "consequat."],
        ["Duis", "aute", "irure", "dolor", "in", "reprehenderit", "in", "voluptate", "velit", "esse", "cillum", "dolore", "eu", "fugiat", "nulla", "pariatur."],
        ["Excepteur", "sint", "occaecat", "cupidatat", "non", "proident,", "sunt", "in", "culpa", "qui", "officia", "deserunt", "mollit", "anim", "id", "est", "laborum."],
        ["Sed", "ut", "perspiciatis", "unde", "omnis", "iste", "natus", "error", "sit", "voluptatem", "accusantium", "doloremque", "laudantium,", "totam", "rem", "aperiam,", "eaque", "ipsa", "quae", "ab", "illo", "inventore", "veritatis", "et", "quasi", "architecto", "beatae", "vitae", "dicta", "sunt", "explicabo."],
        ["Nemo", "enim", "ipsam", "voluptatem", "quia", "voluptas", "sit", "aspernatur", "aut", "odit", "aut", "fugit,", "sed", "quia", "consequuntur", "magni", "dolores", "eos", "qui", "ratione", "voluptatem", "sequi", "nesciunt."],
        ["Neque", "porro", "quisquam", "est,", "qui", "dolorem", "ipsum", "quia", "dolor", "sit", "amet,", "consectetur,", "adipisci", "velit,", "sed", "quia", "non", "numquam", "eius", "modi", "tempora", "incidunt", "ut", "labore", "et", "dolore", "magnam", "aliquam", "quaerat", "voluptatem."],
        ["Ut", "enim", "ad", "minima", "veniam,", "quis", "nostrum", "exercitationem", "ullam", "corporis", "suscipit", "laboriosam,", "nisi", "ut", "aliquid", "ex", "ea", "commodi", "consequatur?", "Quis", "autem", "vel", "eum", "iure", "reprehenderit", "qui", "in", "ea", "voluptate", "velit", "esse", "quam", "nihil", "molestiae", "consequatur,", "vel", "illum", "qui", "dolorem", "eum", "fugiat", "quo", "voluptas", "nulla", "pariatur?", "At", "vero", "eos", "et", "accusamus", "et", "iusto", "odio", "dignissimos", "ducimus", "qui", "blanditiis", "praesentium", "voluptatum", "deleniti", "atque", "corrupti", "quos", "dolores", "et", "quas", "molestias", "excepturi", "sint", "occaecati", "cupiditate", "non", "provident,", "similique", "sunt", "in", "culpa", "qui", "officia", "deserunt", "mollitia", "animi,", "id", "est", "laborum", "et", "dolorum", "fuga."],
        ["Et", "harum", "quidem", "rerum", "facilis", "est", "et", "expedita", "distinctio."],
        ["Nam", "libero", "tempore,", "cum", "soluta", "nobis", "est", "eligendi", "optio", "cumque", "nihil", "impedit", "quo", "minus", "id", "quod", "maxime", "placeat", "facere", "possimus,", "omnis", "voluptas", "assumenda", "est,", "omnis", "dolor", "repellendus."],
        ["Temporibus", "autem", "quibusdam", "et", "aut", "officiis", "debitis", "aut", "rerum", "necessitatibus", "saepe", "eveniet", "ut", "et", "voluptates", "repudiandae", "sint", "et", "molestiae", "non", "recusandae."],
        ["Itaque", "earum", "rerum", "hic", "tenetur", "a", "sapiente", "delectus,", "ut", "aut", "reiciendis", "voluptatibus", "maiores", "alias", "consequatur", "aut", "perferendis", "doloribus", "asperiores", "repellat."]
    ]
}

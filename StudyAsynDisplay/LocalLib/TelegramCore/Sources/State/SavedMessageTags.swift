import Foundation
import TelegramApi
import Postbox
import SwiftSignalKit

public final class SavedMessageTags: Equatable, Codable {
    public final class Tag: Equatable, Codable {
        private enum CodingKeys: String, CodingKey {
            case reaction
            case title
            case count
        }
        
        public let reaction: MessageReaction.Reaction
        public let title: String?
        public let count: Int
        
        public init(
            reaction: MessageReaction.Reaction,
            title: String?,
            count: Int
        ) {
            self.reaction = reaction
            self.title = title
            self.count = count
        }
        
        public static func ==(lhs: Tag, rhs: Tag) -> Bool {
            if lhs.reaction != rhs.reaction {
                return false
            }
            if lhs.title != rhs.title {
                return false
            }
            if lhs.count != rhs.count {
                return false
            }
            return true
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.reaction = try container.decode(MessageReaction.Reaction.self, forKey: .reaction)

            self.title = try container.decodeIfPresent(String.self, forKey: .title)
            self.count = Int(try container.decode(Int32.self, forKey: .count))
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(self.reaction, forKey: .reaction)
            try container.encodeIfPresent(self.title, forKey: .title)
            
            try container.encode(Int32(self.count), forKey: .count)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case newHash
        case tags
    }
    
    public let hash: Int64
    public let tags: [Tag]
    
    public init(
        hash: Int64,
        tags: [Tag]
    ) {
        self.hash = hash
        self.tags = tags
    }
    
    public static func ==(lhs: SavedMessageTags, rhs: SavedMessageTags) -> Bool {
        if lhs.hash != rhs.hash {
            return false
        }
        if lhs.tags != rhs.tags {
            return false
        }
        return true
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.hash = try container.decodeIfPresent(Int64.self, forKey: .newHash) ?? 0
        self.tags = try container.decode([Tag].self, forKey: .tags)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.hash, forKey: .newHash)
        try container.encode(self.tags, forKey: .tags)
    }
}

func _internal_savedMessageTags(postbox: Postbox) -> Signal<SavedMessageTags?, NoError> {
    return postbox.transaction { transaction -> SavedMessageTags? in
        return _internal_savedMessageTags(transaction: transaction)
    }
}

func _internal_savedMessageTagsCacheKey() -> ItemCacheEntryId {
    let key = ValueBoxKey(length: 8)
    key.setInt64(0, value: 0)
    
    return ItemCacheEntryId(collectionId: Namespaces.CachedItemCollection.savedMessageTags, key: key)
}

func _internal_savedMessageTags(transaction: Transaction) -> SavedMessageTags? {
    let key = ValueBoxKey(length: 8)
    key.setInt64(0, value: 0)
    
    let cached = transaction.retrieveItemCacheEntry(id: ItemCacheEntryId(collectionId: Namespaces.CachedItemCollection.savedMessageTags, key: key))?.get(SavedMessageTags.self)
    if let cached = cached {
        return cached
    } else {
        return nil
    }
}

func _internal_setSavedMessageTags(transaction: Transaction, savedMessageTags: SavedMessageTags) {
    let key = ValueBoxKey(length: 8)
    key.setInt64(0, value: 0)
    
    if let entry = CodableEntry(savedMessageTags) {
        transaction.putItemCacheEntry(id: ItemCacheEntryId(collectionId: Namespaces.CachedItemCollection.savedMessageTags, key: key), entry: entry)
    }
}

func _internal_setSavedMessageTagTitle(account: Account, reaction: MessageReaction.Reaction, title: String?) -> Signal<Never, NoError> {
    return account.postbox.transaction { transaction -> Void in
        let value = _internal_savedMessageTags(transaction: transaction) ?? SavedMessageTags(hash: 0, tags: [])
        var updatedTags = value.tags
        if let index = updatedTags.firstIndex(where: { $0.reaction == reaction }) {
            updatedTags[index] = SavedMessageTags.Tag(reaction: updatedTags[index].reaction, title: title, count: updatedTags[index].count)
        } else {
            updatedTags.append(SavedMessageTags.Tag(reaction: reaction, title: title, count: 0))
        }
        _internal_setSavedMessageTags(transaction: transaction, savedMessageTags: SavedMessageTags(hash: 0, tags: updatedTags))
    }
    |> mapToSignal { _ -> Signal<Never, NoError> in
        var flags: Int32 = 0
        if title != nil {
            flags |= 1 << 0
        }
        return account.network.request(Api.functions.messages.updateSavedReactionTag(flags: flags, reaction: reaction.apiReaction, title: title))
        |> `catch` { _ -> Signal<Api.Bool, NoError> in
            return .single(.boolFalse)
        }
        |> ignoreValues
    }
}

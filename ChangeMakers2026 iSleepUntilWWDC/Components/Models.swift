//
//  Models.swift
//  ChangeMakers2026 iSleepUntilWWDC
//
//  Created by Raymond Chavez on 10/04/26.
//

import Foundation
import SwiftUI

struct DailyQuest: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let type: QuestType
    var isCompleted: Bool
    
    enum QuestType {
        case learning
        case roleplay
        case forge
        
        var icon: String {
            switch self {
            case .learning: return "pencil"
            case .roleplay: return "person.2.fill"
            case .forge: return "hammer.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .learning: return Theme.Quest.learning
            case .roleplay: return Theme.Quest.roleplay
            case .forge: return Theme.Quest.forge
            }
        }
    }
}

struct Kana: Identifiable {
    let id = UUID()
    let character: String
    let romaji: String
    let group: String
    
    var isEmpty: Bool {
        character.isEmpty
    }
}

struct AdventureChatMessage: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let diceSummary: String?
}

struct LearningEntry: Identifiable, Hashable {
    enum Category: String, CaseIterable, Identifiable {
        case social = "Social"
        case context = "Context"
        case dnd = "DnD"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .social:
                return "person.2.fill"
            case .context:
                return "bubble.left.and.text.bubble.right.fill"
            case .dnd:
                return "shield.fill"
            }
        }
    }

    let id: String
    let kana: String
    let romaji: String
    let translation: String
    let usage: String
    let category: Category
    let groupLabel: String?
    let kindLabel: String?
}

struct CampaignObjective: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

struct ChecklistItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

struct CharacterAttack: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var attackBonus: String
    var damageType: String
    var isCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case attackBonus
        case damageType
        case isCompleted
    }

    init(
        id: UUID = UUID(),
        name: String = "",
        attackBonus: String = "",
        damageType: String = "",
        isCompleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.attackBonus = attackBonus
        self.damageType = damageType
        self.isCompleted = isCompleted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        attackBonus = try container.decodeIfPresent(String.self, forKey: .attackBonus) ?? ""
        damageType = try container.decodeIfPresent(String.self, forKey: .damageType) ?? ""
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
    }
}

struct CharacterSheet: Codable, Hashable {
    var characterName = ""
    var classAndLevel = ""
    var background = ""
    var playerName = ""
    var race = ""
    var alignment = ""
    var experiencePoints = ""

    var strength = "10"
    var dexterity = "10"
    var constitution = "10"
    var intelligence = "10"
    var wisdom = "10"
    var charisma = "10"

    var inspiration = ""
    var proficiencyBonus = ""
    var armorClass = ""
    var initiative = ""
    var speed = ""
    var hitPointMax = ""
    var currentHitPoints = ""
    var temporaryHitPoints = ""

    var personalityTraits = ""
    var ideals = ""
    var bonds = ""
    var flaws = ""

    var attacks: [CharacterAttack] = []
    var equipment: [ChecklistItem] = []
    var featuresAndTraits: [ChecklistItem] = []
    var proficienciesAndLanguages: [ChecklistItem] = []
}

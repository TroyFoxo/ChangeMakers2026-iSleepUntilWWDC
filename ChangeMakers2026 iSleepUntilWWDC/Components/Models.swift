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

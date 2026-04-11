import SwiftUI

enum WorldType: String, CaseIterable, Identifiable {
    case highFantasy = "High Fantasy"
    case darkFantasy = "Dark Fantasy"
    case steampunk = "Steampunk"
    case forestMystery = "Forest Mystery"
    case floatingIslands = "Floating Islands"

    var id: String { rawValue }
}

enum MainAdventure: String, CaseIterable, Identifiable {
    case rescueMission = "Rescue Mission"
    case lostArtifact = "Lost Artifact"
    case villageDefense = "Village Defense"
    case diplomaticQuest = "Diplomatic Quest"
    case dragonHunt = "Dragon Hunt"

    var id: String { rawValue }
}

enum EnvironmentTone: String, CaseIterable, Identifiable {
    case calm = "Calm"
    case magical = "Magical"
    case eerie = "Eerie"
    case heroic = "Heroic"
    case tense = "Tense"

    var id: String { rawValue }
}

struct WorldBuilderView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("world_name") private var worldName = ""
    @AppStorage("world_type") private var worldType = WorldType.highFantasy.rawValue
    @AppStorage("main_adventure") private var mainAdventure = MainAdventure.rescueMission.rawValue
    @AppStorage("environment_tone") private var environmentTone = EnvironmentTone.calm.rawValue
    @AppStorage("world_main_tasks_json") private var worldMainTasksJSON = ""
    @AppStorage("world_main_locations_json") private var worldMainLocationsJSON = ""
    @AppStorage("world_weather_items_json") private var worldWeatherItemsJSON = ""
    @AppStorage("world_factions_json") private var worldFactionsJSON = ""
    @AppStorage("world_social_rules_json") private var worldSocialRulesJSON = ""
    @AppStorage("world_special_places_json") private var worldSpecialPlacesJSON = ""
    @AppStorage("world_notes_items_json") private var worldNotesItemsJSON = ""

    @State private var newObjectiveTitle = ""
    @State private var objectives: [CampaignObjective] = []
    @State private var newMainLocation = ""
    @State private var mainLocations: [ChecklistItem] = []
    @State private var newWeatherItem = ""
    @State private var weatherItems: [ChecklistItem] = []
    @State private var newFaction = ""
    @State private var factions: [ChecklistItem] = []
    @State private var newSocialRule = ""
    @State private var socialRules: [ChecklistItem] = []
    @State private var newSpecialPlace = ""
    @State private var specialPlaces: [ChecklistItem] = []
    @State private var newWorldNote = ""
    @State private var worldNotes: [ChecklistItem] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("World Builder")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    Text("Create the DnD world, main adventure, and social environment for your campaign.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                }

                Group {
                    TextFieldSection(title: "World Name", text: $worldName, prompt: "Example: Whispering Vale")

                    pickerSection(
                        title: "Type of World",
                        selection: $worldType,
                        options: WorldType.allCases.map(\.rawValue)
                    )

                    pickerSection(
                        title: "Main Adventure",
                        selection: $mainAdventure,
                        options: MainAdventure.allCases.map(\.rawValue)
                    )

                    objectivesSection

                    pickerSection(
                        title: "Environment Tone",
                        selection: $environmentTone,
                        options: EnvironmentTone.allCases.map(\.rawValue)
                    )
                }

                Group {
                    stringListSection(
                        title: "Main Locations",
                        prompt: "Add a city, forest, tavern, castle, cave...",
                        newItemText: $newMainLocation,
                        items: $mainLocations,
                        saveAction: saveMainLocations
                    )

                    stringListSection(
                        title: "Weather and Atmosphere",
                        prompt: "Add weather, mood, or atmosphere details...",
                        newItemText: $newWeatherItem,
                        items: $weatherItems,
                        saveAction: saveWeatherItems
                    )

                    stringListSection(
                        title: "Factions and NPC Groups",
                        prompt: "Add guilds, guards, villages, dragons, schools...",
                        newItemText: $newFaction,
                        items: $factions,
                        saveAction: saveFactions
                    )

                    stringListSection(
                        title: "Social Rules and Comfort Notes",
                        prompt: "Add greeting rules, boundaries, safe spaces, teamwork notes...",
                        newItemText: $newSocialRule,
                        items: $socialRules,
                        saveAction: saveSocialRules
                    )

                    stringListSection(
                        title: "Special Places",
                        prompt: "Add temples, libraries, healing rooms, training halls...",
                        newItemText: $newSpecialPlace,
                        items: $specialPlaces,
                        saveAction: saveSpecialPlaces
                    )

                    stringListSection(
                        title: "Extra Notes",
                        prompt: "Add anything else about the campaign world...",
                        newItemText: $newWorldNote,
                        items: $worldNotes,
                        saveAction: saveWorldNotes
                    )
                }

                if !hasSavedWorld {
                    Button {
                        saveObjectives()
                        saveMainLocations()
                        saveWeatherItems()
                        saveFactions()
                        saveSocialRules()
                        saveSpecialPlaces()
                        saveWorldNotes()
                        dismiss()
                    } label: {
                        Text("Create World")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Theme.primary, Theme.primary.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Creates and saves the current world.")
                }

                if hasSavedWorld {
                    Button(role: .destructive) {
                        removeWorld()
                    } label: {
                        Label("Remove World", systemImage: "trash")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.8), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Deletes the current world and the current character.")
                }
            }
            .padding()
        }
        .background {
            GlobalBackground()
        }
        .navigationTitle("Create World")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadObjectives()
            mainLocations = loadChecklistItems(from: worldMainLocationsJSON)
            weatherItems = loadChecklistItems(from: worldWeatherItemsJSON)
            factions = loadChecklistItems(from: worldFactionsJSON)
            socialRules = loadChecklistItems(from: worldSocialRulesJSON)
            specialPlaces = loadChecklistItems(from: worldSpecialPlacesJSON)
            worldNotes = loadChecklistItems(from: worldNotesItemsJSON)
        }
    }

    private var hasSavedWorld: Bool {
        !worldName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !worldMainTasksJSON.isEmpty
            || !worldMainLocationsJSON.isEmpty
    }

    private func pickerSection(title: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection.wrappedValue = option
                    }
                }
            } label: {
                HStack {
                    Text(selection.wrappedValue)
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding()
                .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
        .glassCard(isPrimary: true, primaryColor: Theme.primary.opacity(0.85))
    }

    private var objectivesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Main Missions / Adventures")
                .font(.headline)
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                TextField("Add a main objective", text: $newObjectiveTitle)
                    .textFieldStyle(.roundedBorder)

                Button("Add") {
                    addObjective()
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.primary)
                .disabled(trimmedObjectiveTitle.isEmpty)
            }

            if objectives.isEmpty {
                Text("No objectives yet. Add the key adventures for this campaign.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
            } else {
                VStack(spacing: 10) {
                    ForEach($objectives) { $objective in
                        HStack(spacing: 12) {
                            Button {
                                objective.isCompleted.toggle()
                                saveObjectives()
                            } label: {
                                Image(systemName: objective.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(objective.isCompleted ? .green : .white.opacity(0.8))
                            }
                            .buttonStyle(.plain)

                            Text(objective.title)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
        }
        .glassCard(isPrimary: true, primaryColor: Theme.primary.opacity(0.85))
    }

    private var trimmedObjectiveTitle: String {
        newObjectiveTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func addObjective() {
        guard !trimmedObjectiveTitle.isEmpty else { return }
        objectives.append(CampaignObjective(title: trimmedObjectiveTitle))
        newObjectiveTitle = ""
        saveObjectives()
    }

    private func loadObjectives() {
        guard let data = worldMainTasksJSON.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([CampaignObjective].self, from: data) else {
            objectives = []
            return
        }
        objectives = decoded
    }

    private func saveObjectives() {
        guard let data = try? JSONEncoder().encode(objectives),
              let json = String(data: data, encoding: .utf8) else {
            return
        }
        worldMainTasksJSON = json
    }

    private func stringListSection(
        title: String,
        prompt: String,
        newItemText: Binding<String>,
        items: Binding<[ChecklistItem]>,
        saveAction: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                TextField(prompt, text: newItemText)
                    .textFieldStyle(.roundedBorder)

                Button("Add") {
                    let trimmed = newItemText.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    items.wrappedValue.append(ChecklistItem(title: trimmed))
                    newItemText.wrappedValue = ""
                    saveAction()
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.primary)
                .disabled(newItemText.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if items.wrappedValue.isEmpty {
                Text("No items yet.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(items.wrappedValue.indices), id: \.self) { index in
                        HStack(spacing: 12) {
                            Button {
                                items.wrappedValue[index].isCompleted.toggle()
                                saveAction()
                            } label: {
                                Image(systemName: items.wrappedValue[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(items.wrappedValue[index].isCompleted ? .green : .white.opacity(0.8))
                            }
                            .buttonStyle(.plain)

                            Text(items.wrappedValue[index].title)
                                .foregroundStyle(.white)
                                .strikethrough(items.wrappedValue[index].isCompleted, color: .white.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
        }
        .glassCard(isPrimary: true, primaryColor: Theme.primary.opacity(0.85))
    }

    private func loadChecklistItems(from json: String) -> [ChecklistItem] {
        guard let data = json.data(using: .utf8), !json.isEmpty else {
            return []
        }

        if let decoded = try? JSONDecoder().decode([ChecklistItem].self, from: data) {
            return decoded
        }

        if let legacy = try? JSONDecoder().decode([String].self, from: data) {
            return legacy.map { ChecklistItem(title: $0) }
        }

        return []
    }

    private func saveChecklistItems(_ items: [ChecklistItem], into storage: inout String) {
        guard let data = try? JSONEncoder().encode(items),
              let json = String(data: data, encoding: .utf8) else {
            return
        }
        storage = json
    }

    private func saveMainLocations() {
        saveChecklistItems(mainLocations, into: &worldMainLocationsJSON)
    }

    private func saveWeatherItems() {
        saveChecklistItems(weatherItems, into: &worldWeatherItemsJSON)
    }

    private func saveFactions() {
        saveChecklistItems(factions, into: &worldFactionsJSON)
    }

    private func saveSocialRules() {
        saveChecklistItems(socialRules, into: &worldSocialRulesJSON)
    }

    private func saveSpecialPlaces() {
        saveChecklistItems(specialPlaces, into: &worldSpecialPlacesJSON)
    }

    private func saveWorldNotes() {
        saveChecklistItems(worldNotes, into: &worldNotesItemsJSON)
    }

    private func removeWorld() {
        worldName = ""
        worldType = ""
        mainAdventure = ""
        environmentTone = ""
        worldMainTasksJSON = ""
        worldMainLocationsJSON = ""
        worldWeatherItemsJSON = ""
        worldFactionsJSON = ""
        worldSocialRulesJSON = ""
        worldSpecialPlacesJSON = ""
        worldNotesItemsJSON = ""
        removeCharacterSheet()
        dismiss()
    }

    private func removeCharacterSheet() {
        UserDefaults.standard.removeObject(forKey: "character_sheet_json")
    }
}

private struct TextFieldSection: View {
    let title: String
    @Binding var text: String
    let prompt: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            TextField(prompt, text: $text)
                .textFieldStyle(.roundedBorder)
        }
        .glassCard(isPrimary: true, primaryColor: Theme.primary.opacity(0.85))
    }
}

struct CharacterCreatorView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("character_sheet_json") private var characterSheetJSON = ""

    @State private var sheet = CharacterSheet()
    @State private var newEquipmentItem = ""
    @State private var newFeatureItem = ""
    @State private var newProficiencyItem = ""

    private let identityColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private let statColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                characterHeader
                identitySection
                abilityScoresSection
                combatSection
                roleplaySection
                attacksSection
                characterListSection(
                    title: "Proficiencies & Languages",
                    prompt: "Add a language, tool, or proficiency",
                    items: $sheet.proficienciesAndLanguages,
                    newItemText: $newProficiencyItem
                )
                characterListSection(
                    title: "Equipment",
                    prompt: "Add an item, weapon, potion, or gear",
                    items: $sheet.equipment,
                    newItemText: $newEquipmentItem
                )
                characterListSection(
                    title: "Features & Traits",
                    prompt: "Add a racial trait, class feature, or special ability",
                    items: $sheet.featuresAndTraits,
                    newItemText: $newFeatureItem
                )

                if !hasSavedCharacter {
                    Button {
                        saveCharacterSheet()
                        dismiss()
                    } label: {
                        Text("Create Character")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Theme.primary, Theme.primary.opacity(0.72)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Creates and saves the current character.")
                }

                if hasSavedCharacter {
                    Button(role: .destructive) {
                        removeCharacter()
                    } label: {
                        Label("Remove Character", systemImage: "trash")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.8), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Deletes the current character.")
                }
            }
            .padding()
        }
        .background {
            GlobalBackground()
        }
        .navigationTitle("Create Character")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadCharacterSheet)
        .onDisappear {
            if hasSavedCharacter {
                saveCharacterSheet()
            }
        }
    }

    private var hasSavedCharacter: Bool {
        !characterSheetJSON.isEmpty
    }

    private var characterHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Character Forge")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("Build a DnD character sheet with identity, stats, attacks, equipment, and roleplay details.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    private var identitySection: some View {
        LazyVGrid(columns: identityColumns, spacing: 12) {
            compactFieldCard(title: "Character Name", text: $sheet.characterName, prompt: "Akari")
            compactFieldCard(title: "Class & Level", text: $sheet.classAndLevel, prompt: "Wizard 3")
            compactFieldCard(title: "Background", text: $sheet.background, prompt: "Scholar")
            compactFieldCard(title: "Player Name", text: $sheet.playerName, prompt: "Your name")
            compactFieldCard(title: "Race", text: $sheet.race, prompt: "Elf")
            compactFieldCard(title: "Alignment", text: $sheet.alignment, prompt: "Neutral Good")
            compactFieldCard(title: "Experience", text: $sheet.experiencePoints, prompt: "900")
            compactFieldCard(title: "Inspiration", text: $sheet.inspiration, prompt: "1")
        }
    }

    private var abilityScoresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ability Scores")
                .font(.headline)
                .foregroundStyle(.white)

            LazyVGrid(columns: statColumns, spacing: 10) {
                abilityCard(title: "Strength", value: $sheet.strength)
                abilityCard(title: "Dexterity", value: $sheet.dexterity)
                abilityCard(title: "Constitution", value: $sheet.constitution)
                abilityCard(title: "Intelligence", value: $sheet.intelligence)
                abilityCard(title: "Wisdom", value: $sheet.wisdom)
                abilityCard(title: "Charisma", value: $sheet.charisma)
            }
        }
        .glassCard(isPrimary: true, primaryColor: Theme.primary.opacity(0.85))
    }

    private var combatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Combat")
                .font(.headline)
                .foregroundStyle(.white)

            LazyVGrid(columns: identityColumns, spacing: 12) {
                compactFieldCard(title: "Proficiency Bonus", text: $sheet.proficiencyBonus, prompt: "+2")
                compactFieldCard(title: "Armor Class", text: $sheet.armorClass, prompt: "14")
                compactFieldCard(title: "Initiative", text: $sheet.initiative, prompt: "+1")
                compactFieldCard(title: "Speed", text: $sheet.speed, prompt: "30 ft")
                compactFieldCard(title: "Hit Point Max", text: $sheet.hitPointMax, prompt: "24")
                compactFieldCard(title: "Current HP", text: $sheet.currentHitPoints, prompt: "24")
                compactFieldCard(title: "Temporary HP", text: $sheet.temporaryHitPoints, prompt: "0")
            }
        }
        .glassCard(isPrimary: true, primaryColor: Theme.primary.opacity(0.85))
    }

    private var roleplaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Roleplay Details")
                .font(.headline)
                .foregroundStyle(.white)

            LazyVGrid(columns: identityColumns, spacing: 12) {
                multilineCard(title: "Personality Traits", text: $sheet.personalityTraits, prompt: "How does your character usually act?")
                multilineCard(title: "Ideals", text: $sheet.ideals, prompt: "What principles guide them?")
                multilineCard(title: "Bonds", text: $sheet.bonds, prompt: "Who or what matters most?")
                multilineCard(title: "Flaws", text: $sheet.flaws, prompt: "What causes trouble?")
            }
        }
    }

    private var attacksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Attacks & Spellcasting")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    sheet.attacks.append(CharacterAttack())
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                        .font(.footnote.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.primary)
            }

            if sheet.attacks.isEmpty {
                Text("Add weapons, cantrips, spells, or special actions.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.72))
            } else {
                VStack(spacing: 10) {
                    ForEach($sheet.attacks) { $attack in
                        VStack(spacing: 10) {
                            HStack {
                                Button {
                                    attack.isCompleted.toggle()
                                } label: {
                                    Image(systemName: attack.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(attack.isCompleted ? .green : .white.opacity(0.8))
                                }
                                .buttonStyle(.plain)

                                Text("Attack")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.85))

                                Spacer()
                            }

                            TextField("Name", text: $attack.name)
                                .textFieldStyle(.roundedBorder)

                            HStack(spacing: 10) {
                                TextField("ATK Bonus", text: $attack.attackBonus)
                                    .textFieldStyle(.roundedBorder)

                                TextField("Damage / Type", text: $attack.damageType)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(attack.isCompleted ? Color.green.opacity(0.65) : Color.clear, lineWidth: 1.5)
                        )
                    }
                }
            }
        }
        .glassCard(isPrimary: true, primaryColor: Theme.primary.opacity(0.85))
    }

    private func compactFieldCard(title: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.75))

            TextField(prompt, text: text)
                .textFieldStyle(.roundedBorder)
        }
        .glassCard(isPrimary: true, primaryColor: Theme.primary.opacity(0.7))
    }

    private func abilityCard(title: String, value: Binding<String>) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.75))

            TextField("10", text: value)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numbersAndPunctuation)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    private func multilineCard(title: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.08))

                if text.wrappedValue.isEmpty {
                    Text(prompt)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.35))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                }

                TextEditor(text: text)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(.white)
                    .frame(minHeight: 110)
                    .padding(8)
            }
        }
        .glassCard(isPrimary: true, primaryColor: Theme.primary.opacity(0.85))
    }

    private func characterListSection(
        title: String,
        prompt: String,
        items: Binding<[ChecklistItem]>,
        newItemText: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                TextField(prompt, text: newItemText)
                    .textFieldStyle(.roundedBorder)

                Button("Add") {
                    let trimmed = newItemText.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    items.wrappedValue.append(ChecklistItem(title: trimmed))
                    newItemText.wrappedValue = ""
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.primary)
                .disabled(newItemText.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if items.wrappedValue.isEmpty {
                Text("No items yet.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.72))
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(items.wrappedValue.indices), id: \.self) { index in
                        HStack(spacing: 12) {
                            Button {
                                items.wrappedValue[index].isCompleted.toggle()
                            } label: {
                                Image(systemName: items.wrappedValue[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(items.wrappedValue[index].isCompleted ? .green : .white.opacity(0.8))
                            }
                            .buttonStyle(.plain)

                            Text(items.wrappedValue[index].title)
                                .foregroundStyle(.white)
                                .strikethrough(items.wrappedValue[index].isCompleted, color: .white.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
        }
        .glassCard(isPrimary: true, primaryColor: Theme.primary.opacity(0.85))
    }

    private func loadCharacterSheet() {
        guard let data = characterSheetJSON.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(CharacterSheet.self, from: data) else {
            migrateLegacyCharacterListsIfNeeded()
            return
        }
        sheet = decoded
    }

    private func saveCharacterSheet() {
        guard let data = try? JSONEncoder().encode(sheet),
              let json = String(data: data, encoding: .utf8) else {
            return
        }
        characterSheetJSON = json
    }

    private func removeCharacter() {
        characterSheetJSON = ""
        sheet = CharacterSheet()
        dismiss()
    }

    private func migrateLegacyCharacterListsIfNeeded() {
        guard let data = characterSheetJSON.data(using: .utf8),
              let legacy = try? JSONDecoder().decode(LegacyCharacterSheet.self, from: data) else {
            return
        }

        sheet = CharacterSheet(
            characterName: legacy.characterName,
            classAndLevel: legacy.classAndLevel,
            background: legacy.background,
            playerName: legacy.playerName,
            race: legacy.race,
            alignment: legacy.alignment,
            experiencePoints: legacy.experiencePoints,
            strength: legacy.strength,
            dexterity: legacy.dexterity,
            constitution: legacy.constitution,
            intelligence: legacy.intelligence,
            wisdom: legacy.wisdom,
            charisma: legacy.charisma,
            inspiration: legacy.inspiration,
            proficiencyBonus: legacy.proficiencyBonus,
            armorClass: legacy.armorClass,
            initiative: legacy.initiative,
            speed: legacy.speed,
            hitPointMax: legacy.hitPointMax,
            currentHitPoints: legacy.currentHitPoints,
            temporaryHitPoints: legacy.temporaryHitPoints,
            personalityTraits: legacy.personalityTraits,
            ideals: legacy.ideals,
            bonds: legacy.bonds,
            flaws: legacy.flaws,
            attacks: legacy.attacks,
            equipment: legacy.equipment.map { ChecklistItem(title: $0) },
            featuresAndTraits: legacy.featuresAndTraits.map { ChecklistItem(title: $0) },
            proficienciesAndLanguages: legacy.proficienciesAndLanguages.map { ChecklistItem(title: $0) }
        )
        saveCharacterSheet()
    }
}

private struct LegacyCharacterSheet: Codable {
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
    var equipment: [String] = []
    var featuresAndTraits: [String] = []
    var proficienciesAndLanguages: [String] = []
}

struct FormsNivelView: View {
    var body: some View {
        WorldBuilderView()
    }
}

#Preview {
    NavigationStack {
        WorldBuilderView()
    }
}

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @AppStorage("world_name") private var worldName = ""
    @AppStorage("world_type") private var worldType = ""
    @AppStorage("main_adventure") private var mainAdventure = ""
    @AppStorage("environment_tone") private var environmentTone = ""
    @AppStorage("world_main_tasks_json") private var worldMainTasksJSON = ""
    @AppStorage("world_main_locations_json") private var worldMainLocationsJSON = ""
    @AppStorage("world_weather_items_json") private var worldWeatherItemsJSON = ""
    @AppStorage("world_factions_json") private var worldFactionsJSON = ""
    @AppStorage("world_social_rules_json") private var worldSocialRulesJSON = ""
    @AppStorage("world_special_places_json") private var worldSpecialPlacesJSON = ""
    @AppStorage("world_notes_items_json") private var worldNotesItemsJSON = ""
    @AppStorage("character_sheet_json") private var characterSheetJSON = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Campaña Actual")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("El Despertar de los Kana")
                        .font(.title.bold())
                }
                .padding(.horizontal)
                .padding(.top, 10)

                if hasWorld {
                    NavigationLink {
                        WorldBuilderView()
                    } label: {
                        statusCard(
                            title: "World Created",
                            subtitle: "Your world is saved. Tap to review it or remove it from the end of that page.",
                            icon: "map.circle.fill",
                            primaryColor: .orange
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                } else {
                    NavigationLink {
                        WorldBuilderView()
                    } label: {
                        creationCard(
                            title: "Create World",
                            subtitle: "Choose the setting, main adventure, and DnD environment.",
                            icon: "map.circle.fill"
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }

                if hasCharacter {
                    NavigationLink {
                        CharacterCreatorView()
                    } label: {
                        statusCard(
                            title: "Character Created",
                            subtitle: "Your character sheet is saved. Tap to review it or remove it from the end of that page.",
                            icon: "person.crop.rectangle.stack.fill",
                            primaryColor: .orange
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                } else {
                    NavigationLink {
                        CharacterCreatorView()
                    } label: {
                        creationCard(
                            title: "Create Character",
                            subtitle: "Build a DnD sheet with stats, attacks, equipment, and story details.",
                            icon: "person.crop.rectangle.stack.fill"
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    .disabled(!hasWorld)
                    .opacity(hasWorld ? 1 : 0.45)
                }
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Misiones de Hoy")
                            .font(.title2.bold())
                        
                        Text("Completa tus misiones en orden")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        viewModel.resetDailyTaskProgress()
                    } label: {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(0.1), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Reset daily tasks")
                    .accessibilityHint("Resets the daily task progress without deleting learned content.")
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(viewModel.todayQuests.enumerated()), id: \.element.id) { index, quest in
                            QuestCardView(
                                quest: quest,
                                isPrimary: viewModel.isPrimary(index: index)
                            ) {}
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                GlobalBackground()
            }
            .navigationTitle("Home")
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                viewModel.refreshQuestProgress()
            }
        }
    }

    private var hasWorld: Bool {
        !worldName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !worldMainTasksJSON.isEmpty
            || !worldMainLocationsJSON.isEmpty
    }

    private var hasCharacter: Bool {
        !characterSheetJSON.isEmpty
    }

    private func creationCard(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundStyle(Theme.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.72))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.7))
        }
        .glassCard(isPrimary: true, primaryColor: Theme.primary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }

    private func statusCard(title: String, subtitle: String, icon: String, primaryColor: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundStyle(primaryColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.72))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.7))
        }
        .glassCard(isPrimary: true, primaryColor: primaryColor)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }
}

#Preview {
    HomeView()
}

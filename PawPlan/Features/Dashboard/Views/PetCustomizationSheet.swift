import SwiftUI
import PawPlanShared

// MARK: - PetCustomizationSheet
// A bottom sheet allowing users to rename their pet, change species,
// and select a head accessory.

public struct PetCustomizationSheet: View {
    @ObservedObject var viewModel: DashboardViewModel

    @State private var petName: String = ""
    @State private var selectedSpecies: PetSpecies = .cat
    @State private var selectedAccessory: String? = nil

    private let accessories: [(key: String, emoji: String, label: String)] = [
        ("none", "✨", "Tidak Ada"),
        ("crown", "👑", "Mahkota"),
        ("sunglasses", "🕶️", "Kacamata"),
        ("headphones", "🎧", "Headphone"),
        ("tophat", "🎩", "Topi Tinggi"),
        ("ribbon", "🎀", "Pita")
    ]

    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // Preview
                    previewCard

                    // Name field
                    nameSection

                    // Species picker
                    speciesSection

                    // Accessory picker
                    accessorySection

                    // Save button
                    saveButton
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .navigationTitle("Kustomisasi Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        viewModel.closeCustomization()
                    }
                }
            }
        }
        .onAppear {
            if let profile = viewModel.petProfile {
                petName = profile.name
                selectedSpecies = profile.species
                selectedAccessory = profile.selectedAccessory
            }
        }
    }

    // MARK: - Preview Card

    private var previewCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hue: 0.50, saturation: 0.55, brightness: 0.72),
                            Color(hue: 0.54, saturation: 0.60, brightness: 0.58)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 130)

            VStack(spacing: 4) {
                ZStack {
                    Text(speciesEmoji(for: selectedSpecies))
                        .font(.system(size: 64))

                    if let accessory = selectedAccessory, accessory != "none" {
                        Text(accessoryEmoji(for: accessory))
                            .font(.system(size: 30))
                            .offset(y: -32)
                    }
                }
                Text(petName.isEmpty ? "PawPaw" : petName)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Name Section

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Nama Pet", systemImage: "pencil")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)

            TextField("Nama pet kamu", text: $petName)
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .accessibilityIdentifier("pet_name_field")
        }
    }

    // MARK: - Species Section

    private var speciesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Jenis Hewan", systemImage: "pawprint")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 10) {
                ForEach(PetSpecies.allCases, id: \.self) { species in
                    SpeciesChip(
                        emoji: speciesEmoji(for: species),
                        label: species.displayName,
                        isSelected: selectedSpecies == species
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedSpecies = species
                        }
                    }
                }
            }
        }
    }

    // MARK: - Accessory Section

    private var accessorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Aksesoris", systemImage: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
                ForEach(accessories, id: \.key) { item in
                    AccessoryChip(
                        emoji: item.emoji,
                        label: item.label,
                        isSelected: (selectedAccessory ?? "none") == item.key
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedAccessory = item.key == "none" ? nil : item.key
                        }
                    }
                }
            }
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            let name = petName.trimmingCharacters(in: .whitespaces)
            viewModel.savePetCustomization(
                name: name.isEmpty ? "PawPaw" : name,
                species: selectedSpecies,
                accessory: selectedAccessory
            )
        } label: {
            Label("Simpan", systemImage: "checkmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hue: 0.50, saturation: 0.70, brightness: 0.80),
                            Color(hue: 0.54, saturation: 0.75, brightness: 0.65)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
        }
        .accessibilityIdentifier("pet_save_button")
    }

    // MARK: - Helpers

    private func speciesEmoji(for species: PetSpecies) -> String {
        switch species {
        case .cat: return "🐱"
        case .dog: return "🐶"
        case .bunny: return "🐰"
        }
    }

    private func accessoryEmoji(for key: String) -> String {
        switch key {
        case "crown": return "👑"
        case "sunglasses": return "🕶️"
        case "headphones": return "🎧"
        case "tophat": return "🎩"
        case "ribbon": return "🎀"
        default: return ""
        }
    }
}

// MARK: - SpeciesChip

private struct SpeciesChip: View {
    let emoji: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 32))
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                isSelected
                ? Color(hue: 0.50, saturation: 0.65, brightness: 0.72)
                : Color(.secondarySystemBackground)
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color(hue: 0.50, saturation: 0.65, brightness: 0.72) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - AccessoryChip

private struct AccessoryChip: View {
    let emoji: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 26))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                isSelected
                ? Color(hue: 0.50, saturation: 0.65, brightness: 0.72)
                : Color(.secondarySystemBackground)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

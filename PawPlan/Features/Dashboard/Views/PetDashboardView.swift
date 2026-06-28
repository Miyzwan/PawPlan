import SwiftUI
import PawPlanShared

// MARK: - PetDashboardView
// The interactive pet card displayed at the top of the Dashboard.
// Features floating animation, tap-to-teleport, speech bubble,
// XP/Level/Energy HUD, and quick action buttons.

public struct PetDashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    // Animation state
    @State private var floatOffset: CGFloat = 0
    @State private var petXOffset: CGFloat = 0
    @State private var petScale: CGFloat = 1.0
    @State private var speechVisible: Bool = true

    // Layout constants
    @State private var frameWidth: CGFloat = 350
    private let frameHeight: CGFloat = 220

    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 12) {
            petPlayground
            quickActions
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { frameWidth = geo.size.width }
            }
        )
        .onAppear {
            startFloatAnimation()
        }
    }

    // MARK: - Pet Playground

    private var petPlayground: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: playgroundGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: frameHeight)

            // Glassmorphism inner layer
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.12))
                .padding(6)
                .frame(height: frameHeight)

            VStack(spacing: 0) {
                // HUD row — Level/XP + Streak
                hudRow
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                Spacer()

                // Pet sprite + speech bubble
                ZStack(alignment: .top) {
                    if speechVisible, let dialogue = viewModel.dialogueText {
                        SpeechBubble(text: dialogue)
                            .offset(x: petXOffset, y: -50)
                            .transition(.scale.combined(with: .opacity))
                    }

                    petSprite
                        .offset(x: petXOffset, y: floatOffset)
                        .scaleEffect(petScale)
                        .onTapGesture {
                            handleTap()
                        }
                }
                .frame(height: 100)

                Spacer()

                // Energy bar
                energyBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
            }
            .frame(height: frameHeight)
        }
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
    }

    // MARK: - Pet Sprite

    private var petSprite: some View {
        ZStack {
            Text(speciesEmoji)
                .font(.system(size: 64))

            if let accessory = viewModel.petProfile?.selectedAccessory {
                Text(accessoryEmoji(for: accessory))
                    .font(.system(size: 28))
                    .offset(y: -30)
            }
        }
        .accessibilityLabel("Pet \(viewModel.petProfile?.name ?? "PawPaw")")
        .accessibilityHint("Ketuk untuk berinteraksi dengan hewan peliharaan")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - HUD

    private var hudRow: some View {
        HStack {
            // Level & XP
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text("Lv.\(viewModel.petProfile?.level ?? 1)")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text(viewModel.petProfile?.name ?? "PawPaw")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                }
                xpBar
            }

            Spacer()

            // Streak badge
            streakBadge
        }
    }

    private var xpBar: some View {
        let xp = viewModel.petProfile?.experiencePoints ?? 0
        let level = viewModel.petProfile?.level ?? 1
        let xpForCurrentLevel = (level - 1) * 100
        let xpInLevel = xp - xpForCurrentLevel
        let progress = min(1.0, CGFloat(xpInLevel) / 100.0)

        return VStack(alignment: .leading, spacing: 3) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.25))
                        .frame(height: 5)
                    Capsule()
                        .fill(Color.yellow)
                        .frame(width: geo.size.width * progress, height: 5)
                        .animation(.spring(response: 0.4), value: progress)
                }
            }
            .frame(width: 100, height: 5)

            Text("\(xpInLevel)/100 XP")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.75))
        }
    }

    private var streakBadge: some View {
        let streak = viewModel.petProfile?.streakCount ?? 0
        return HStack(spacing: 3) {
            Text("🔥")
                .font(.system(size: 14))
            Text("\(streak)")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text("hari")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.white.opacity(0.2))
        .clipShape(Capsule())
    }

    private var energyBar: some View {
        let energy = viewModel.petProfile?.energyLevel ?? 100
        let progress = CGFloat(energy) / 100.0
        let energyColor: Color = energy > 50 ? .green : energy > 20 ? .yellow : .red

        return HStack(spacing: 6) {
            Text("⚡")
                .font(.system(size: 10))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.25))
                        .frame(height: 5)
                    Capsule()
                        .fill(energyColor)
                        .frame(width: geo.size.width * progress, height: 5)
                        .animation(.spring(response: 0.4), value: progress)
                }
            }
            .frame(height: 5)
            Text("\(energy)%")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
        }
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        HStack(spacing: 10) {
            QuickActionButton(
                icon: "🍕",
                label: "Makan",
                accessibilityId: "pet_action_feed"
            ) {
                viewModel.feedPet()
            }

            QuickActionButton(
                icon: "🧸",
                label: "Main",
                accessibilityId: "pet_action_play"
            ) {
                viewModel.playWithPet()
            }

            QuickActionButton(
                icon: "⚙️",
                label: "Ubah Pet",
                accessibilityId: "pet_action_customize"
            ) {
                viewModel.openCustomization()
            }
        }
    }

    // MARK: - Helpers

    private var speciesEmoji: String {
        switch viewModel.petProfile?.species {
        case .cat: return "🐱"
        case .dog: return "🐶"
        case .bunny: return "🐰"
        case nil: return "🐱"
        }
    }

    private var playgroundGradient: [Color] {
        switch viewModel.petProfile?.currentMood {
        case .sleeping:
            return [Color(hue: 0.63, saturation: 0.45, brightness: 0.55),
                    Color(hue: 0.70, saturation: 0.50, brightness: 0.45)]
        case .alert, .concerned:
            return [Color(hue: 0.05, saturation: 0.70, brightness: 0.85),
                    Color(hue: 0.08, saturation: 0.65, brightness: 0.70)]
        case .focused:
            return [Color(hue: 0.55, saturation: 0.65, brightness: 0.70),
                    Color(hue: 0.60, saturation: 0.70, brightness: 0.55)]
        case .happy, .excited:
            return [Color(hue: 0.12, saturation: 0.75, brightness: 0.90),
                    Color(hue: 0.07, saturation: 0.80, brightness: 0.80)]
        default:
            return [Color(hue: 0.50, saturation: 0.55, brightness: 0.72),
                    Color(hue: 0.54, saturation: 0.60, brightness: 0.58)]
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

    // MARK: - Animations

    private func startFloatAnimation() {
        withAnimation(
            .easeInOut(duration: 1.8)
            .repeatForever(autoreverses: true)
        ) {
            floatOffset = -8
        }
    }

    private func handleTap() {
        // Scale down
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            petScale = 0.75
        }
        // Teleport to random X position within frame bounds
        let maxOffset = frameWidth / 2 - 50
        let newX = CGFloat.random(in: -maxOffset...maxOffset)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            petXOffset = newX
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                petScale = 1.05
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.spring(response: 0.3)) {
                    petScale = 1.0
                }
            }
        }

        // Update speech bubble
        withAnimation(.easeOut(duration: 0.15)) {
            speechVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.teleportPet()
            withAnimation(.spring(response: 0.35)) {
                speechVisible = true
            }
        }
    }
}

// MARK: - SpeechBubble

private struct SpeechBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
            )
            .overlay(alignment: .bottom) {
                Triangle()
                    .fill(.white)
                    .frame(width: 12, height: 7)
                    .offset(y: 6)
                    .shadow(color: .black.opacity(0.06), radius: 1)
            }
            .frame(maxWidth: 180)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - QuickActionButton

private struct QuickActionButton: View {
    let icon: String
    let label: String
    let accessibilityId: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.2)) {
                    isPressed = false
                }
            }
            action()
        }) {
            VStack(spacing: 4) {
                Text(icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityId)
    }
}

import Foundation
import Combine
import SwiftUI
import PawPlanShared

// MARK: - View Data

public struct DashboardViewData: Equatable {
    public let upcomingEvents: [CalendarEvent]
    public let todayEventsCount: Int

    public init(upcomingEvents: [CalendarEvent], todayEventsCount: Int) {
        self.upcomingEvents = upcomingEvents
        self.todayEventsCount = todayEventsCount
    }
}

// MARK: - View State

public enum DashboardViewState: Equatable {
    case loading
    case empty
    case loaded(DashboardViewData)
    case error(AppError)
}

// MARK: - ViewModel

@MainActor
public final class DashboardViewModel: ObservableObject {
    @Published public private(set) var state: DashboardViewState = .loading
    @Published public private(set) var petProfile: PetProfile?
    @Published public private(set) var dialogueText: String?
    @Published public var showCustomizationSheet: Bool = false
    @Published public private(set) var liveActivityError: String? = nil

    // MARK: - Dependencies

    private let eventRepository: EventRepositoryProtocol
    private let dateProvider: DateProviderProtocol
    private let calendarProvider: CalendarProviderProtocol
    private let petRepository: PetRepositoryProtocol
    private let petStateEngine: PetStateEngineProtocol
    private let liveActivityManager: LiveActivityManagerProtocol
    private let liveActivityEventResolver: LiveActivityEventResolver
    private var loadTask: Task<Void, Never>?

    // MARK: - Init

    public init(
        eventRepository: EventRepositoryProtocol,
        dateProvider: DateProviderProtocol,
        calendarProvider: CalendarProviderProtocol,
        petRepository: PetRepositoryProtocol = DummyPetRepository(),
        petStateEngine: PetStateEngineProtocol = DummyPetStateEngine(),
        liveActivityManager: LiveActivityManagerProtocol = DummyLiveActivityManager(),
        liveActivityEventResolver: LiveActivityEventResolver = LiveActivityEventResolver()
    ) {
        self.eventRepository = eventRepository
        self.dateProvider = dateProvider
        self.calendarProvider = calendarProvider
        self.petRepository = petRepository
        self.petStateEngine = petStateEngine
        self.liveActivityManager = liveActivityManager
        self.liveActivityEventResolver = liveActivityEventResolver
    }

    // MARK: - Public Interface

    public func loadDashboard() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task {
            do {
                if Task.isCancelled { return }

                // Load events and pet profile concurrently
                async let eventsResult = eventRepository.fetchEvents()
                async let petResult = petRepository.fetchPetProfile()

                let allEvents = try await eventsResult
                var fetchedPet = try await petResult

                let now = dateProvider.now

                // Resolve pet mood from current event context
                let activeEvent = allEvents.first {
                    $0.startDate <= now && $0.endDate >= now && $0.status == .upcoming
                }
                let nextEvent = allEvents
                    .filter { $0.startDate > now && $0.status == .upcoming }
                    .min(by: { $0.startDate < $1.startDate })

                if var pet = fetchedPet {
                    let resolvedMood = petStateEngine.resolveMood(
                        activeEvent: activeEvent,
                        nextEvent: nextEvent,
                        currentDate: now
                    )
                    if pet.currentMood != resolvedMood {
                        pet.currentMood = resolvedMood
                        try await petRepository.savePetProfile(pet)
                        fetchedPet = pet
                    }
                }

                if Task.isCancelled { return }

                self.petProfile = fetchedPet
                self.dialogueText = moodDialogue(for: fetchedPet?.currentMood ?? .idle, nextEvent: nextEvent)

                let todayEvents = allEvents.filter {
                    calendarProvider.isDate($0.startDate, inSameDayAs: now)
                }
                let upcoming = allEvents
                    .filter { $0.startDate >= now && $0.status == .upcoming }
                    .prefix(3)

                if allEvents.isEmpty {
                    self.state = .empty
                } else {
                    self.state = .loaded(DashboardViewData(
                        upcomingEvents: Array(upcoming),
                        todayEventsCount: todayEvents.count
                    ))
                }
            } catch {
                if !Task.isCancelled {
                    self.state = .error(.unknown(error.localizedDescription))
                }
            }
        }
    }

    public func cancelTasks() {
        loadTask?.cancel()
    }

    // MARK: - Live Activity

    /// Manually triggers a Live Activity for the next upcoming event.
    /// Called when user taps "Tampilkan di Dynamic Island" in the dashboard.
    public func showNextEventLiveActivity() {
        Task {
            do {
                let allEvents = try await eventRepository.fetchEvents()
                guard let event = liveActivityEventResolver.resolveEvent(from: allEvents) else {
                    liveActivityError = "Tidak ada event yang bisa ditampilkan."
                    return
                }
                guard let pet = petProfile else {
                    liveActivityError = "Profil pet belum tersedia."
                    return
                }

                let contentState = liveActivityEventResolver.buildContentState(event: event, pet: pet)
                let attrs = liveActivityEventResolver.buildAttributes(for: event)

                try await liveActivityManager.startActivity(
                    eventId: attrs.eventId,
                    eventTitle: attrs.eventTitle,
                    eventCategorySymbol: attrs.eventCategorySymbol,
                    deepLinkURL: attrs.deepLinkURL,
                    contentState: contentState
                )
                liveActivityError = nil
                dialogueText = "Live Activity aktif di Dynamic Island! 🏝️"
            } catch {
                liveActivityError = "Gagal menampilkan Live Activity: \(error.localizedDescription)"
            }
        }
    }

    /// Ends all active Live Activities.
    public func stopLiveActivity() {
        Task {
            await liveActivityManager.endAllActivities()
            dialogueText = "Dynamic Island dinonaktifkan."
        }
    }

    // MARK: - Pet Interactions

    public func feedPet() {
        guard var pet = petProfile else { return }
        let (updated, dialogue) = petStateEngine.feedPet(pet)
        pet = updated
        persistPet(pet)
        dialogueText = dialogue
    }

    public func playWithPet() {
        guard var pet = petProfile else { return }
        let (updated, dialogue) = petStateEngine.playWithPet(pet)
        pet = updated
        persistPet(pet)
        dialogueText = dialogue
    }

    public func teleportPet() {
        guard var pet = petProfile else { return }
        let (updated, dialogue) = petStateEngine.interact(action: .teleport, with: pet)
        pet = updated
        persistPet(pet)
        dialogueText = dialogue
    }

    public func openCustomization() {
        showCustomizationSheet = true
    }

    public func closeCustomization() {
        showCustomizationSheet = false
    }

    public func savePetCustomization(name: String, species: PetSpecies, accessory: String?) {
        guard var pet = petProfile else { return }
        pet.name = name
        pet.species = species
        pet.selectedAccessory = accessory
        persistPet(pet)
        showCustomizationSheet = false
        dialogueText = "Haii! Aku \(name)! 🐾"
    }

    // MARK: - Private Helpers

    private func persistPet(_ pet: PetProfile) {
        petProfile = pet
        Task {
            try? await petRepository.savePetProfile(pet)
        }
    }

    private func moodDialogue(for mood: PetMood, nextEvent: CalendarEvent?) -> String {
        switch mood {
        case .sleeping:
            return "Zzz... tidak ada agenda. Waktu tidur! 💤"
        case .relaxed:
            return "Santai dulu~ Tidak ada agenda dalam waktu dekat 😌"
        case .idle:
            return "Halo! Ada yang bisa aku bantu? 🐾"
        case .alert:
            let title = nextEvent?.title ?? "agenda"
            return "⚠️ \"\(title)\" sebentar lagi! Ayo siapkan diri!"
        case .focused:
            return "Ssst! Sedang fokus! Tetap semangat! 🧠"
        case .excited:
            return "Waaah! Aku semangat! 🎉"
        case .happy:
            return "Yeay! Kerja bagus! ✨"
        case .concerned:
            return "Hm... ada agenda yang terlewat. Jangan lupa ya! 😟"
        }
    }
}

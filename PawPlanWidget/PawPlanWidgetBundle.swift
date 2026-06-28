import WidgetKit
import SwiftUI

// MARK: - PawPlanWidgetBundle
// Entry point for the PawPlan Widget Extension.
// Registers the PetLiveActivityWidget which handles all
// Lock Screen and Dynamic Island Live Activity layouts.

@main
struct PawPlanWidgetBundle: WidgetBundle {
    var body: some Widget {
        PetLiveActivityWidget()
    }
}

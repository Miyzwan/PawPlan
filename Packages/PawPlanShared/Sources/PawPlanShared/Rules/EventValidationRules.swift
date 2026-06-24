import Foundation

public struct EventValidationRules {
    public static func validate(title: String, startDate: Date, endDate: Date) -> Result<Void, AppError> {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            return .failure(.validationFailed("Judul event tidak boleh kosong."))
        }
        if endDate <= startDate {
            return .failure(.validationFailed("Waktu selesai harus setelah waktu mulai."))
        }
        return .success(())
    }
}

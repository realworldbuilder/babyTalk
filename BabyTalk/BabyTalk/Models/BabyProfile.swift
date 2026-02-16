import Foundation

@Observable
class BabyProfile: Codable, Identifiable {
    var id = UUID()
    var name: String
    var birthDate: Date
    var createdAt: Date
    
    init(name: String, birthDate: Date) {
        self.name = name
        self.birthDate = birthDate
        self.createdAt = Date()
    }
    
    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
    }
    
    var ageInWeeks: Int {
        ageInDays / 7
    }
    
    var ageDescription: String {
        if ageInDays < 14 {
            return "\(ageInDays) day\(ageInDays == 1 ? "" : "s") old"
        } else {
            let weeks = ageInWeeks
            let days = ageInDays % 7
            if days == 0 {
                return "\(weeks) week\(weeks == 1 ? "" : "s") old"
            } else {
                return "\(weeks) week\(weeks == 1 ? "" : "s"), \(days) day\(days == 1 ? "" : "s") old"
            }
        }
    }
}
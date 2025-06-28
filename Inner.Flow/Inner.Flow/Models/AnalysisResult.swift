import Foundation
import FirebaseFirestore

struct AnalysisResult: Identifiable, Codable {
    let id: String
    let userId: String
    let analysisType: AnalysisType
    let content: String
    let dateRange: DateRange
    let createdAt: Date
    
    enum AnalysisType: String, Codable, CaseIterable {
        case weekly = "weekly"
        case monthly = "monthly"
        
        var displayName: String {
            switch self {
            case .weekly:
                return "Weekly Insights"
            case .monthly:
                return "Monthly Insights"
            }
        }
    }
    
    struct DateRange: Codable {
        let start: String
        let end: String
        
        var formattedRange: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            guard let startDate = dateFormatter.date(from: start),
                  let endDate = dateFormatter.date(from: end) else {
                return "\(start) - \(end)"
            }
            
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            
            return "\(displayFormatter.string(from: startDate)) - \(displayFormatter.string(from: endDate))"
        }
    }
    
    init(id: String, userId: String, analysisType: AnalysisType, content: String, dateRange: DateRange, createdAt: Date) {
        self.id = id
        self.userId = userId
        self.analysisType = analysisType
        self.content = content
        self.dateRange = dateRange
        self.createdAt = createdAt
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        let id = document.documentID
        let userId = data["userId"] as? String ?? ""
        let analysisTypeString = data["analysisType"] as? String ?? ""
        let content = data["content"] as? String ?? ""
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        
        guard let analysisType = AnalysisType(rawValue: analysisTypeString) else { return nil }
        
        let dateRangeData = data["dateRange"] as? [String: Any] ?? [:]
        let start = dateRangeData["start"] as? String ?? ""
        let end = dateRangeData["end"] as? String ?? ""
        let dateRange = DateRange(start: start, end: end)
        
        self.init(id: id, userId: userId, analysisType: analysisType, content: content, dateRange: dateRange, createdAt: createdAt)
    }
} 
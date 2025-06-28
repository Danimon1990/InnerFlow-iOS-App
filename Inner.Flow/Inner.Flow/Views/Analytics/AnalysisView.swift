import SwiftUI

struct AnalysisView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedAnalysisType: AnalysisResult.AnalysisType = .weekly
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with analysis type selector
                VStack(spacing: 16) {
                    Text("Flow Insights")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("AI-powered wellness analysis from your data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Analysis type picker
                    Picker("Analysis Type", selection: $selectedAnalysisType) {
                        ForEach(AnalysisResult.AnalysisType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Content
                if isLoading {
                    Spacer()
                    ProgressView("Loading insights...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else if dataManager.analysisResults.isEmpty {
                    emptyStateView
                } else {
                    analysisListView
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadAnalysisResults()
            }
            .onChange(of: selectedAnalysisType) {
                loadAnalysisResults()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(.purple.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Insights Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Your personalized wellness insights will appear here once you have enough data and our AI has analyzed your patterns.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                loadAnalysisResults()
            }) {
                Text("Refresh")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var analysisListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredAnalysisResults) { analysis in
                    AnalysisCardView(analysis: analysis)
                }
            }
            .padding()
        }
    }
    
    private var filteredAnalysisResults: [AnalysisResult] {
        dataManager.analysisResults.filter { $0.analysisType == selectedAnalysisType }
    }
    
    private func loadAnalysisResults() {
        guard let userId = authManager.user?.uid else { return }
        
        isLoading = true
        Task {
            await dataManager.fetchAnalysisResults(for: userId)
            isLoading = false
        }
    }
}

struct AnalysisCardView: View {
    let analysis: AnalysisResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(analysis.analysisType.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(analysis.dateRange.formattedRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: analysis.analysisType == .weekly ? "calendar.badge.clock" : "calendar.badge.plus")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
            
            Divider()
            
            // Content
            Text(analysis.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            // Footer
            HStack {
                Text("Generated by Flow")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(analysis.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    AnalysisView()
        .environmentObject(DataManager())
        .environmentObject(AuthenticationManager())
} 
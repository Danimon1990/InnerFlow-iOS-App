export interface DailyLog {
  id: string;
  userId: string;
  date: string;
  mood: number;
  energy: number;
  sleep: number;
  activities: string[];
  notes: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface UserProfile {
  id: string;
  email: string;
  name: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface AnalysisResult {
  id: string;
  userId: string;
  analysisType: 'weekly' | 'monthly';
  content: string;
  dateRange: {
    start: string;
    end: string;
  };
  createdAt: Date;
}

export interface LLMResponse {
  content: string;
  analysisType: 'weekly' | 'monthly';
} 
import * as admin from 'firebase-admin';
import { DailyLog, UserProfile, AnalysisResult } from '../types';

const db = admin.firestore();

export class DataService {
  // Get all users for batch processing
  static async getAllUsers(): Promise<UserProfile[]> {
    try {
      const usersSnapshot = await db.collection('users').get();
      return usersSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as UserProfile[];
    } catch (error) {
      console.error('Error fetching users:', error);
      throw error;
    }
  }

  // Get specific users by ID
  static async getUsersByIds(userIds: string[]): Promise<UserProfile[]> {
    try {
      const users: UserProfile[] = [];
      
      for (const userId of userIds) {
        const userDoc = await db.collection('users').doc(userId).get();
        if (userDoc.exists) {
          users.push({
            id: userDoc.id,
            ...userDoc.data()
          } as UserProfile);
        }
      }
      
      return users;
    } catch (error) {
      console.error('Error fetching users by IDs:', error);
      throw error;
    }
  }

  // Get daily logs for a user within a date range
  static async getUserDailyLogs(userId: string, startDate: string, endDate: string): Promise<DailyLog[]> {
    try {
      const logsSnapshot = await db
        .collection('dailyLogs')
        .where('userId', '==', userId)
        .where('date', '>=', startDate)
        .where('date', '<=', endDate)
        .orderBy('date', 'asc')
        .get();

      return logsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as DailyLog[];
    } catch (error) {
      console.error(`Error fetching daily logs for user ${userId}:`, error);
      throw error;
    }
  }

  // Save analysis result to Firestore
  static async saveAnalysisResult(analysis: Omit<AnalysisResult, 'id' | 'createdAt'>): Promise<void> {
    try {
      const analysisData = {
        ...analysis,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      };

      await db.collection('analysisResults').add(analysisData);
      console.log(`Analysis saved for user ${analysis.userId}`);
    } catch (error) {
      console.error('Error saving analysis result:', error);
      throw error;
    }
  }

  // Get the latest analysis for a user
  static async getLatestAnalysis(userId: string, analysisType: 'weekly' | 'monthly'): Promise<AnalysisResult | null> {
    try {
      const analysisSnapshot = await db
        .collection('analysisResults')
        .where('userId', '==', userId)
        .where('analysisType', '==', analysisType)
        .orderBy('createdAt', 'desc')
        .limit(1)
        .get();

      if (analysisSnapshot.empty) {
        return null;
      }

      const doc = analysisSnapshot.docs[0];
      return {
        id: doc.id,
        ...doc.data()
      } as AnalysisResult;
    } catch (error) {
      console.error(`Error fetching latest analysis for user ${userId}:`, error);
      throw error;
    }
  }

  // Check if user has enough data for analysis (at least 3 days for weekly, 10 days for monthly)
  static async hasEnoughData(userId: string, daysRequired: number): Promise<boolean> {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      
      const logsSnapshot = await db
        .collection('dailyLogs')
        .where('userId', '==', userId)
        .where('date', '>=', thirtyDaysAgo.toISOString().split('T')[0])
        .get();

      return logsSnapshot.size >= daysRequired;
    } catch (error) {
      console.error(`Error checking data sufficiency for user ${userId}:`, error);
      return false;
    }
  }
} 
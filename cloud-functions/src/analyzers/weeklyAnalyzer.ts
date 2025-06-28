import { DataService } from '../utils/dataService';
import { LLMService } from '../utils/llmService';
import { UserProfile } from '../types';

export async function analyzeWeeklyData(specificUserIds?: string[]): Promise<void> {
  try {
    // Get users to analyze
    let users: UserProfile[];
    if (specificUserIds) {
      users = await DataService.getUsersByIds(specificUserIds);
    } else {
      users = await DataService.getAllUsers();
    }

    console.log(`Starting weekly analysis for ${users.length} users`);

    // Calculate date range for the past week (Sunday to Saturday)
    const endDate = new Date();
    endDate.setHours(23, 59, 59, 999); // End of today
    
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 6); // 7 days ago
    startDate.setHours(0, 0, 0, 0); // Start of that day

    const startDateStr = startDate.toISOString().split('T')[0];
    const endDateStr = endDate.toISOString().split('T')[0];

    console.log(`Analyzing data from ${startDateStr} to ${endDateStr}`);

    // Process each user
    for (const user of users) {
      try {
        console.log(`Processing weekly analysis for user: ${user.id}`);

        // Check if user has enough data for analysis (at least 3 days)
        const hasEnoughData = await DataService.hasEnoughData(user.id, 3);
        if (!hasEnoughData) {
          console.log(`User ${user.id} doesn't have enough data for weekly analysis (need at least 3 days)`);
          continue;
        }

        // Get user's daily logs for the past week
        const dailyLogs = await DataService.getUserDailyLogs(user.id, startDateStr, endDateStr);
        
        if (dailyLogs.length === 0) {
          console.log(`No daily logs found for user ${user.id} in the specified date range`);
          continue;
        }

        console.log(`Found ${dailyLogs.length} daily logs for user ${user.id}`);

        // Generate analysis using LLM
        const analysisContent = await LLMService.analyzeWeeklyData(dailyLogs);

        // Save analysis result
        await DataService.saveAnalysisResult({
          userId: user.id,
          analysisType: 'weekly',
          content: analysisContent,
          dateRange: {
            start: startDateStr,
            end: endDateStr
          }
        });

        console.log(`Weekly analysis completed for user ${user.id}`);

      } catch (error) {
        console.error(`Error processing weekly analysis for user ${user.id}:`, error);
        // Continue with other users even if one fails
        continue;
      }
    }

    console.log('Weekly analysis completed for all users');
  } catch (error) {
    console.error('Error in weekly analysis:', error);
    throw error;
  }
} 
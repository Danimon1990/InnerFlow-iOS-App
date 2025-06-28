import express, { Request, Response } from 'express';
import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Initialize Express app
const app = express();
app.use(express.json());

// Import analysis functions
import { analyzeWeeklyData } from './analyzers/weeklyAnalyzer';
import { analyzeMonthlyData } from './analyzers/monthlyAnalyzer';

// Simple health check endpoint
app.get('/', (req: Request, res: Response) => {
  res.status(200).json({ 
    success: true, 
    message: 'InnerFlow Cloud Functions API is running!',
    timestamp: new Date().toISOString(),
    endpoints: [
      '/test',
      '/weeklyAnalysis',
      '/monthlyAnalysis'
    ]
  });
});

// Simple test endpoint
app.post('/test', (req: Request, res: Response) => {
  res.status(200).json({ 
    success: true, 
    message: 'Test endpoint working!',
    data: req.body
  });
});

// Weekly analysis endpoint
app.post('/weeklyAnalysis', async (req: Request, res: Response) => {
  try {
    console.log('Weekly analysis endpoint hit');
    console.log('Starting weekly analysis for all users...');
    await analyzeWeeklyData();
    console.log('Weekly analysis completed successfully');
    res.status(200).json({ 
      success: true, 
      message: 'Weekly analysis completed successfully' 
    });
  } catch (error) {
    console.error('Error in weekly analysis:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Weekly analysis failed',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// Monthly analysis endpoint
app.post('/monthlyAnalysis', async (req: Request, res: Response) => {
  try {
    console.log('Monthly analysis endpoint hit');
    console.log('Starting monthly analysis for all users...');
    await analyzeMonthlyData();
    console.log('Monthly analysis completed successfully');
    res.status(200).json({ 
      success: true, 
      message: 'Monthly analysis completed successfully' 
    });
  } catch (error) {
    console.error('Error in monthly analysis:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Monthly analysis failed',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// Export the single API function
export const api = onRequest({
  region: 'us-central1',
  timeoutSeconds: 300, // 5 minutes
  memory: '256MiB',
}, app); 
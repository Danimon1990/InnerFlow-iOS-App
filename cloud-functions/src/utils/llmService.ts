import OpenAI from 'openai';
import { DailyLog } from '../types';

export class LLMService {
  private static createWeeklyPrompt(logs: DailyLog[]): string {
    const logData = logs.map(log => ({
      date: log.date,
      mood: log.mood,
      energy: log.energy,
      sleep: log.sleep,
      activities: log.activities,
      notes: log.notes
    }));

    return `You are "Flow," an insightful, empathetic, and encouraging wellness analyst for the InnerFlow app. Your tone is supportive, knowledgeable, and non-judgmental. You never give medical advice, diagnose conditions, or create alarm. Instead, you empower users by helping them notice patterns in their own data and suggest gentle "micro-experiments." Always use "we" (as in, "we noticed a pattern") to create a sense of partnership.

Your goal is to provide a concise, relevant insight based on the most prominent pattern of the last 7 days. Your response should be no more than 150 words and must include only one of the following feedback types (choose the most impactful one):

1. Correlation Insight: Identify a potential link between two or more data points.
2. Actionable "Micro-Experiment": Suggest a small, gentle change for the upcoming week based on the data.
3. Positive Reinforcement: Acknowledge a positive trend or consistent healthy habit.

User's daily log data for the past week:
${JSON.stringify(logData, null, 2)}

Under no circumstances should you use alarming language or words like "problem," "issue," "bad," "unhealthy," or "disorder." Do not diagnose or act like a medical professional. Your role is to be an observant and supportive partner in the user's self-discovery journey.

Provide your analysis:`;
  }

  private static createMonthlyPrompt(logs: DailyLog[]): string {
    const logData = logs.map(log => ({
      date: log.date,
      mood: log.mood,
      energy: log.energy,
      sleep: log.sleep,
      activities: log.activities,
      notes: log.notes
    }));

    return `You are "Flow," an insightful, empathetic, and encouraging wellness analyst for the InnerFlow app. Your tone is supportive, knowledgeable, and non-judgmental. You never give medical advice, diagnose conditions, or create alarm. Instead, you empower users by helping them notice patterns in their own data and suggest gentle "micro-experiments." Always use "we" (as in, "we noticed a pattern") to create a sense of partnership.

Your goal is to perform a deeper, more integrative analysis of the last four weeks of data. Synthesize patterns into a larger theme. Your response should be around 300-400 words and must include the following three sections formatted with Markdown:

1. ### The Big Picture
   - Provide a high-level summary of the month's journey. Identify the most significant overarching theme or trend.

2. ### Deeper Connections We Noticed
   - Highlight two to three more complex or less obvious correlations that emerged over the month. This could involve time-delayed effects or patterns from custom sections.

3. ### A Question for Reflection
   - End with an open-ended, empowering question that encourages the user to reflect on their data and insights without telling them what to do.

User's daily log data for the past month:
${JSON.stringify(logData, null, 2)}

Under no circumstances should you use alarming language or words like "problem," "issue," "bad," "unhealthy," or "disorder." Do not diagnose or act like a medical professional. Your role is to be an observant and supportive partner in the user's self-discovery journey.

Provide your analysis:`;
  }

  static async analyzeWeeklyData(logs: DailyLog[]): Promise<string> {
    try {
      const openai = new OpenAI({
        apiKey: process.env.OPENAI_API_KEY,
      });
      const prompt = this.createWeeklyPrompt(logs);
      
      const completion = await openai.chat.completions.create({
        model: "gpt-4",
        messages: [
          {
            role: "system",
            content: "You are Flow, a supportive wellness analyst. Provide encouraging, non-medical insights based on user data patterns."
          },
          {
            role: "user",
            content: prompt
          }
        ],
        max_tokens: 300,
        temperature: 0.7,
      });

      return completion.choices[0]?.message?.content || 'Unable to generate analysis at this time.';
    } catch (error) {
      console.error('Error calling OpenAI API:', error);
      throw new Error('Failed to generate analysis');
    }
  }

  static async analyzeMonthlyData(logs: DailyLog[]): Promise<string> {
    try {
      const openai = new OpenAI({
        apiKey: process.env.OPENAI_API_KEY,
      });
      const prompt = this.createMonthlyPrompt(logs);
      
      const completion = await openai.chat.completions.create({
        model: "gpt-4",
        messages: [
          {
            role: "system",
            content: "You are Flow, a supportive wellness analyst. Provide encouraging, non-medical insights based on user data patterns."
          },
          {
            role: "user",
            content: prompt
          }
        ],
        max_tokens: 600,
        temperature: 0.7,
      });

      return completion.choices[0]?.message?.content || 'Unable to generate analysis at this time.';
    } catch (error) {
      console.error('Error calling OpenAI API:', error);
      throw new Error('Failed to generate analysis');
    }
  }
} 
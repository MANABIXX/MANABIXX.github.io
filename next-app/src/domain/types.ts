export type Subject = "science" | "social" | "english";
export type Category =
  | "physics" | "biology" | "chemistry" | "earth"
  | "civics" | "history" | "vocabulary" | "grammar";
export type MasteryLevel = "unlearned" | "weak" | "learning" | "mastered";

export interface Question {
  id: string;
  subject: Subject;
  category: Category;
  unit: string;
  tags: string[];
  mode: "vocabulary" | "grammar" | "general";
  prompt: string;
  choices: [string, string, string, string];
  correctIndex: 0 | 1 | 2 | 3;
  explanation: string;
  audioText?: string;
  imageUrl?: string;
}

export interface AnswerLog {
  questionId: string;
  selectedIndex: number;
  isCorrect: boolean;
  responseTimeMs: number;
  answeredAt: number;
}

export interface QuestionProgress {
  questionId: string;
  mastery: MasteryLevel;
  intervalDays: number;
  repetition: number;
  easeFactor: number;
  nextReviewAt: number;
  correctCount: number;
  incorrectCount: number;
}

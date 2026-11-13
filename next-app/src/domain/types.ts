export type Subject = "english" | "math" | "japanese" | "science" | "social";
export type Category =
  | "physics" | "biology" | "chemistry" | "earth" | "geography"
  | "civics" | "history" | "vocabulary" | "grammar" | "algebra" | "geometry" | "reading" | "classics";
export type MasteryLevel = "unlearned" | "weak" | "learning" | "mastered";

export type QuestionDifficulty = "basic" | "standard" | "advanced";
export type QuestionFormat =
  | "choice"
  | "application"
  | "short-answer"
  | "proof"
  | "essay"
  | "data-interpretation";

export interface SolutionStep {
  title: string;
  body: string;
}

export interface ScoringCriterion {
  criterion: string;
  points: number;
}

export interface QuestionSource {
  kind: "original" | "official-past-paper" | "adapted";
  year?: number;
  label?: string;
}

export interface Question {
  id: string;
  subject: Subject;
  category: Category;
  unit: string;
  tags: string[];
  mode: "vocabulary" | "grammar" | "general";
  question: string;
  choices: [string, string, string, string];
  answerIndex: 0 | 1 | 2 | 3;
  explanation: string;

  // Optional extension fields preserve compatibility with the existing question bank.
  difficulty?: QuestionDifficulty;
  format?: QuestionFormat;
  solutionSteps?: SolutionStep[];
  scoringCriteria?: ScoringCriterion[];
  modelAnswer?: string;
  commonMistakes?: string[];
  source?: QuestionSource;

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
  lastAnsweredAt: number;
}

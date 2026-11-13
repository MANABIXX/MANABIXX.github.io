export type CodeLanguage = 'typescript' | 'python';

export interface CodeExample {
  label: string;
  source: string;
}

export const codeExamples: Record<CodeLanguage, CodeExample> = {
  typescript: {
    label: 'TypeScript',
    source: `type Learner = {
  name: string;
  completed: number;
};

const learner: Learner = {
  name: "MANABIXX",
  completed: 12,
};

const message: string =
  \`\u{1F4DA} \${learner.name} は今日 \${learner.completed} 問に取り組みました\`;

console.log(message);`,
  },
  python: {
    label: 'Python',
    source: `# Pythonで最初のプログラム
name = "MANABIXX"
completed = 12

for number in range(1, 4):
    print(f"{name}: 今日の学習 {completed + number} 問目！")`,
  },
};

export function normalizeCodeLanguage(value: string): CodeLanguage {
  return value === 'python' ? 'python' : 'typescript';
}

export function getCodeLanguageLabel(language: CodeLanguage): string {
  return codeExamples[language].label;
}

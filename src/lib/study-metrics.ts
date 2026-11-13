export function formatStudyCount(value: number): string {
  return new Intl.NumberFormat('ja-JP').format(Math.max(0, Math.trunc(value || 0)));
}

export function calculateAccuracy(correct: number, answered: number): number {
  return answered > 0 ? Math.round((correct / answered) * 100) : 0;
}

export function calculateCompletion(completed: number, total: number): number {
  return total > 0 ? Math.min(100, Math.max(0, Math.round((completed / total) * 100))) : 0;
}

// Only datasets used by current Flutter routes may enter the public Pages artifact.
// Legacy/private-labelled datasets remain in source storage and are not copied.
export const FLUTTER_PUBLIC_DATA_FILES = Object.freeze([
  'foundation-training.json',
  'knowledge-base.json',
  'kosen-math-section-1.json',
  'kosen-questions.json',
  'mock-exams.json',
  'public-exam.json',
  'questions.json',
  'summary-foundation.json',
  'to-you.json',
]);

export const FLUTTER_PUBLIC_DATA_URLS = Object.freeze(
  FLUTTER_PUBLIC_DATA_FILES.map((name) => '/data/' + name)
);

//! Shared learning-domain primitives for Flutter, Leptos and future clients.

use serde::{Deserialize, Serialize};
use thiserror::Error;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Question {
    pub id: String,
    pub subject: String,
    #[serde(alias = "field")]
    pub topic: String,
    pub level: String,
    #[serde(alias = "question")]
    pub prompt: String,
    #[serde(alias = "choices")]
    pub options: [String; 4],
    #[serde(alias = "answerIndex")]
    pub correct: u8,
    pub explanation: String,
    #[serde(default, alias = "sourceNote")]
    pub source_note: Option<String>,
    #[serde(default, alias = "sourceRef")]
    pub source_ref: Option<String>,
}

impl Question {
    pub fn validate(&self) -> Result<(), DomainError> {
        if self.id.trim().is_empty() { return Err(DomainError::EmptyId); }
        if self.prompt.trim().is_empty() { return Err(DomainError::EmptyPrompt); }
        if self.options.iter().any(|choice| choice.trim().is_empty()) {
            return Err(DomainError::EmptyChoice);
        }
        if self.correct > 3 { return Err(DomainError::InvalidAnswerIndex(self.correct)); }
        if self.explanation.trim().is_empty() { return Err(DomainError::EmptyExplanation); }
        Ok(())
    }

    pub fn is_correct(&self, selected: u8) -> bool { selected == self.correct }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct AnswerAttempt {
    pub question_id: String,
    pub selected: u8,
    pub correct: bool,
    pub elapsed_ms: u32,
    pub answered_at_ms: i64,
}

impl AnswerAttempt {
    pub fn from_answer(question: &Question, selected: u8, elapsed_ms: u32, answered_at_ms: i64) -> Result<Self, DomainError> {
        question.validate()?;
        if selected > 3 { return Err(DomainError::InvalidAnswerIndex(selected)); }
        Ok(Self {
            question_id: question.id.clone(),
            selected,
            correct: question.is_correct(selected),
            elapsed_ms,
            answered_at_ms,
        })
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Mastery {
    pub question_id: String,
    pub repetitions: u32,
    pub interval_days: u32,
    pub ease_factor: f32,
    pub due_at_ms: i64,
    pub correct_count: u32,
    pub incorrect_count: u32,
}

impl Mastery {
    pub fn new(question_id: impl Into<String>) -> Self {
        Self { question_id: question_id.into(), repetitions: 0, interval_days: 0,
            ease_factor: 2.5, due_at_ms: 0, correct_count: 0, incorrect_count: 0 }
    }

    pub fn record(&mut self, correct: bool, now_ms: i64) {
        if correct {
            self.correct_count += 1;
            self.repetitions += 1;
            self.interval_days = match self.repetitions {
                1 => 1,
                2 => 3,
                _ => ((self.interval_days as f32 * self.ease_factor).round() as u32).max(1),
            };
            self.ease_factor = (self.ease_factor + 0.05).min(3.0);
        } else {
            self.incorrect_count += 1;
            self.repetitions = 0;
            self.interval_days = 0;
            self.ease_factor = (self.ease_factor - 0.2).max(1.3);
        }
        self.due_at_ms = now_ms + i64::from(self.interval_days) * 86_400_000;
    }
}

#[derive(Debug, Error, PartialEq, Eq)]
pub enum DomainError {
    #[error("question id is empty")] EmptyId,
    #[error("question prompt is empty")] EmptyPrompt,
    #[error("one or more answer choices are empty")] EmptyChoice,
    #[error("answer index {0} is outside the four-choice range")] InvalidAnswerIndex(u8),
    #[error("question explanation is empty")] EmptyExplanation,
}

#[cfg(test)]
mod tests {
    use super::*;
    fn sample() -> Question {
        Question { id: "sci-001".into(), subject: "science".into(), topic: "physics".into(),
            level: "basic".into(), prompt: "水は何度で凍る？".into(),
            options: ["0℃".into(), "10℃".into(), "50℃".into(), "100℃".into()],
            correct: 0, explanation: "標準気圧では0℃です。".into(),
            source_note: None, source_ref: None }
    }
    #[test]
    fn accepts_valid_four_choice_question() { assert!(sample().validate().is_ok()); }
    #[test]
    fn rejects_out_of_range_answer() {
        let mut q = sample(); q.correct = 4;
        assert_eq!(q.validate(), Err(DomainError::InvalidAnswerIndex(4)));
    }
    #[test]
    fn reads_existing_flutter_json_field_names() {
        let raw = r#"{"id":"sci-001","subject":"science","topic":"physics","level":"basic","prompt":"Q","options":["A","B","C","D"],"correct":1,"explanation":"why","sourceNote":"book","sourceRef":"p1"}"#;
        let q: Question = serde_json::from_str(raw).unwrap();
        assert_eq!(q.correct, 1);
        assert_eq!(q.source_ref.as_deref(), Some("p1"));
    }
    #[test]
    fn answer_attempt_and_mastery_are_deterministic() {
        let q = sample();
        let attempt = AnswerAttempt::from_answer(&q, 0, 1200, 10_000).unwrap();
        assert!(attempt.correct);
        let mut mastery = Mastery::new(q.id);
        mastery.record(true, 10_000);
        assert_eq!(mastery.interval_days, 1);
        mastery.record(false, 20_000);
        assert_eq!(mastery.repetitions, 0);
        assert_eq!(mastery.incorrect_count, 1);
    }
}

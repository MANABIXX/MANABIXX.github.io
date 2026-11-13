export type ExamDefinition = {
  id: "seiran" | "tochigi";
  name: string;
  detail: string;
  date: string; // YYYY-MM-DD（現地時間）
  startDate: string; // 進捗バーの起点
  dailyTarget: number;
  provisional: boolean;
};

export const EXAMS: ExamDefinition[] = [
  {
    id: "seiran",
    name: "青藍泰斗高校",
    detail: "私立入試",
    date: "2027-01-06",
    startDate: "2026-11-13",
    dailyTarget: 30,
    provisional: true,
  },
  {
    id: "tochigi",
    name: "栃木県立高校入試",
    detail: "一般選抜",
    date: "2027-03-04",
    startDate: "2026-11-13",
    dailyTarget: 30,
    provisional: true,
  },
];

export const PHASE_MESSAGES = {
  foundation: [
    "今は基礎を固める時期。今日覚えた1つが、本番の1点になる。",
    "焦って難問に飛びつかなくていい。取れる問題を確実に取ろう。",
    "昨日できなかった問題を今日できるようにする。それが実力。",
  ],
  practice: [
    "知識を得点に変える時期。解いた後の解き直しまでが演習。",
    "正解した数より、間違いから何を回収したか。",
    "本番と同じつもりで1問に向き合おう。",
  ],
  sprint: [
    "新しいことを増やしすぎず、取れる問題を落とさない。",
    "ここまで積み上げた自分を信じて、いつも通り解こう。",
    "最後の1日まで伸びる。睡眠も実力のうち。",
  ],
  streak: [
    "続けた日数は、簡単には裏切らない。",
    "今日も机に向かった。それだけで昨日より前進している。",
    "小さくても継続。積み重ねは本番で力になる。",
  ],
} as const;

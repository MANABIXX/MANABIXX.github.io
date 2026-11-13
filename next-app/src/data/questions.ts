import type { Question } from "@/domain/types";

export const questions: Question[] = [
  { id: "sci-001", subject: "science", category: "physics", unit: "運動とエネルギー", tags: ["仕事", "エネルギー"], mode: "general", prompt: "物体に力を加えて、その力の向きに物体を動かしたとき、力が物体にした仕事を表す式はどれ？", choices: ["力 ÷ 距離", "力 × 距離", "質量 × 速さ", "質量 ÷ 体積"], correctIndex: 1, explanation: "仕事[J] ＝ 力[N] × 力の向きに動いた距離[m]。力の向きに動かなければ仕事は0です。" },
  { id: "sci-002", subject: "science", category: "biology", unit: "生命の連続性", tags: ["遺伝", "DNA"], mode: "general", prompt: "遺伝子の本体であり、遺伝情報を記録している物質は何？", choices: ["タンパク質", "デンプン", "DNA", "脂肪"], correctIndex: 2, explanation: "DNA（デオキシリボ核酸）の塩基配列に遺伝情報が記録されています。" },
  { id: "sci-003", subject: "science", category: "chemistry", unit: "化学変化とイオン", tags: ["電解質", "イオン"], mode: "general", prompt: "水に溶けると電流を流す物質を何という？", choices: ["非電解質", "電解質", "単体", "混合物"], correctIndex: 1, explanation: "電解質は水溶液中で電離してイオンになり、電流を流します。食塩や塩酸などが例です。" },
  { id: "sci-004", subject: "science", category: "earth", unit: "地球と宇宙", tags: ["天体", "月"], mode: "general", prompt: "月が太陽の光を反射して光って見えることから、月自身は何をしている？", choices: ["光をつくっている", "熱を出している", "光を反射している", "電気を帯びている"], correctIndex: 2, explanation: "月は自ら光を出さず、太陽の光を反射して輝いて見えます。" },
  { id: "soc-001", subject: "social", category: "civics", unit: "日本国憲法と人権", tags: ["基本的人権", "憲法"], mode: "general", prompt: "日本国憲法第13条で、個人として尊重されることを基本に保障される権利は？", choices: ["請願権", "幸福追求権", "参政権", "請求権"], correctIndex: 1, explanation: "第13条は個人の尊重と幸福追求権を定めています。新しい人権を考える際の根拠にもなります。" },
  { id: "soc-002", subject: "social", category: "history", unit: "近現代史", tags: ["日本史", "明治維新"], mode: "general", prompt: "明治政府が1871年に藩を廃止して府・県を置いた改革は？", choices: ["地租改正", "廃藩置県", "版籍奉還", "文明開化"], correctIndex: 1, explanation: "廃藩置県によって中央政府が地方を直接治める中央集権体制を整えました。" },
  { id: "eng-001", subject: "english", category: "vocabulary", unit: "高校入試重要英単語", tags: ["動詞", "重要語"], mode: "vocabulary", prompt: "「〜を解決する」に最も近い英単語は？", choices: ["solve", "borrow", "invite", "arrive"], correctIndex: 0, explanation: "solve は「問題などを解決する」。solve a problem（問題を解決する）の形で覚えよう。", audioText: "solve" },
  { id: "eng-002", subject: "english", category: "grammar", unit: "現在完了", tags: ["現在完了", "経験"], mode: "grammar", prompt: "「私は3回京都を訪れたことがあります。」空欄に入る語句は？ I (　　　) Kyoto three times.", choices: ["visit", "visited", "have visited", "will visit"], correctIndex: 2, explanation: "経験を表す現在完了は have/has + 過去分詞。three times が経験の回数を示しています。" }
];

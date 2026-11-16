use leptos::prelude::*;
use serde::Deserialize;

const SOURCE: &str = include_str!("../../data/knowledge-base.json");

#[derive(Clone, Deserialize, Default)]
struct Entry {
    #[serde(default)] id: String,
    #[serde(default)] subject: String,
    #[serde(default)] field: String,
    #[serde(default)] title: String,
    #[serde(default)] explanation: Option<String>,
    #[serde(default)] status: String,
    #[serde(default)] grade: Option<u8>,
}

#[derive(Deserialize, Default)]
struct Database {
    #[serde(default, rename = "topicRecords")] topics: Vec<Entry>,
    #[serde(default, rename = "authoredModules")] modules: Vec<Entry>,
}

#[component]
fn App() -> impl IntoView {
    let data = serde_json::from_str::<Database>(SOURCE).unwrap_or_default();
    let mut entries = data.topics;
    entries.extend(data.modules);
    entries.sort_by(|a, b| a.subject.cmp(&b.subject).then(a.field.cmp(&b.field)).then(a.title.cmp(&b.title)));
    let total = entries.len();
    let authored = entries.iter().filter(|e| e.status == "authored").count();
    let (records, _) = signal(entries);
    let (query, set_query) = signal(String::new());
    let (subject, set_subject) = signal(String::from("all"));

    let filtered = move || {
        let q = query.get().trim().to_lowercase();
        let s = subject.get();
        records.get().into_iter().filter(|entry| {
            let subject_ok = s == "all" || entry.subject == s;
            let haystack = format!("{} {} {} {}", entry.title, entry.field, entry.explanation.clone().unwrap_or_default(), entry.id).to_lowercase();
            subject_ok && (q.is_empty() || haystack.contains(&q))
        }).collect::<Vec<_>>()
    };

    view! {
        <main class="shell">
            <header class="topbar">
                <a class="brand" href="https://manabixx.github.io/">MANABIXX</a>
                <a class="back" href="https://manabixx.github.io/">"← 学習アプリへ戻る"</a>
            </header>
            <section class="hero">
                <div class="eyebrow">KNOWLEDGE LIBRARY / RUST + LEPTOS</div>
                <h1>"知識を、つなげて理解する。"</h1>
                <p>"理科・社会の重要事項を分野別に整理したナレッジベース。単元名や用語から検索して、必要な知識にすばやくアクセスできます。"</p>
            </section>
            <section class="stats">
                <div class="stat"><strong>{total}</strong>"登録項目"</div>
                <div class="stat"><strong>{authored}</strong>"解説あり"</div>
                <div class="stat"><strong>{total.saturating_sub(authored)}</strong>"基礎項目"</div>
            </section>
            <section>
                <div class="controls">
                    <input class="search" type="search" placeholder="単元・用語・キーワードで検索…" on:input=move |ev| set_query.set(event_target_value(&ev)) />
                    <button class="filter" class:active=move || subject.get() == "all" on:click=move |_| set_subject.set("all".to_string())>"すべて"</button>
                    <button class="filter" class:active=move || subject.get() == "science" on:click=move |_| set_subject.set("science".to_string())>"理科"</button>
                    <button class="filter" class:active=move || subject.get() == "social" on:click=move |_| set_subject.set("social".to_string())>"社会"</button>
                </div>
                <div class="results-head"><span>"検索結果"</span><span>{move || format!("{} 件", filtered().len())}</span></div>
                <div class="grid">
                    <For
                        each=filtered
                        key=|entry| entry.id.clone()
                        children=move |entry| {
                            let title = if entry.title.is_empty() { entry.id.clone() } else { entry.title.clone() };
                            let explanation = entry.explanation.clone().unwrap_or_else(|| "この項目の詳しい解説は準備中です。".to_string());
                            let subject_label = if entry.subject == "social" { "社会" } else { "理科" };
                            let status = if entry.status == "authored" { "解説あり" } else { "基礎項目" };
                            let grade = entry.grade.map(|g| format!("中{}年", g)).unwrap_or_else(|| "学年共通".to_string());
                            view! {
                                <article class="entry">
                                    <div class="entry-top"><span class="tag">{format!("{} · {}", subject_label, entry.field)}</span><span class="grade">{grade}</span></div>
                                    <h2>{title}</h2>
                                    <p>{explanation}</p>
                                    <div class="entry-top" style="margin-top:14px"><span class="grade">{status}</span><span class="grade">{entry.id}</span></div>
                                </article>
                            }
                        }
                    />
                </div>
                <Show when=move || filtered().is_empty()>
                    <div class="empty">"一致する項目がありません。別のキーワードを試してください。"</div>
                </Show>
            </section>
            <footer class="footer">"MANABIXX Knowledge Library · Built with Rust and Leptos"</footer>
        </main>
    }
}

fn main() {
    mount_to_body(App);
}

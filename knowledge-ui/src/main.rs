use leptos::prelude::*;
use serde::Deserialize;
use wasm_bindgen::prelude::*;
use wasm_bindgen_futures::JsFuture;

#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = window, js_name = searchKnowledge)]
    fn search_knowledge(query: &str, subject: &str) -> js_sys::Promise;
}

#[derive(Clone, Deserialize)]
struct Entry {
    id: String,
    subject: String,
    field: String,
    title: String,
    explanation: Option<String>,
    status: String,
    grade: Option<u8>,
}

#[component]
fn KnowledgeApp() -> impl IntoView {
    let (records, set_records) = signal(Vec::<Entry>::new());
    let (query, set_query) = signal(String::new());
    let (subject, set_subject) = signal(String::from("all"));
    let (loading, set_loading) = signal(true);
    let (error, set_error) = signal(String::new());

    Effect::new(move |_| {
        let q = query.get();
        let s = subject.get();
        set_loading.set(true);
        set_error.set(String::new());
        leptos::task::spawn_local(async move {
            match JsFuture::from(search_knowledge(&q, &s)).await {
                Ok(value) => match serde_wasm_bindgen::from_value::<Vec<Entry>>(value) {
                    Ok(items) => set_records.set(items),
                    Err(_) => set_error.set("検索結果を読み込めませんでした。".to_string()),
                },
                Err(_) => set_error.set("SQLiteデータベースを初期化できませんでした。".to_string()),
            }
            set_loading.set(false);
        });
    });

    let result_count = move || records.get().len();
    let authored_count = move || records.get().iter().filter(|e| e.status == "authored").count();

    view! {
        <main class="shell">
            <header class="topbar">
                <a class="brand" href="https://manabixx.github.io/">MANABIXX</a>
                <a class="back" href="https://manabixx.github.io/">"← 学習アプリへ戻る"</a>
            </header>
            <section class="hero">
                <div class="eyebrow">KNOWLEDGE LIBRARY / RUST + LEPTOS + SQLITE WASM</div>
                <h1>"知識を、つなげて理解する。"</h1>
                <p>"理科・社会の重要事項を分野別に整理したナレッジベース。SQLiteをブラウザ内で動かし、単元名・重要語句・解説から検索できます。"</p>
            </section>
            <section class="stats">
                <div class="stat"><strong>{result_count}</strong>"検索結果"</div>
                <div class="stat"><strong>{authored_count}</strong>"解説あり"</div>
                <div class="stat"><strong>{move || result_count().saturating_sub(authored_count())}</strong>"基礎項目"</div>
            </section>
            <section>
                <div class="controls">
                    <input class="search" type="search" placeholder="単元・用語・キーワードで検索…" on:input=move |ev| set_query.set(event_target_value(&ev)) />
                    <button class="filter" class:active=move || subject.get() == "all" on:click=move |_| set_subject.set("all".to_string())>"すべて"</button>
                    <button class="filter" class:active=move || subject.get() == "science" on:click=move |_| set_subject.set("science".to_string())>"理科"</button>
                    <button class="filter" class:active=move || subject.get() == "social" on:click=move |_| set_subject.set("social".to_string())>"社会"</button>
                </div>
                <div class="results-head"><span>"知識データベース"</span><span>{move || if loading.get() { "検索中…".to_string() } else { format!("{} 件", result_count()) }}</span></div>
                <Show when=move || !error.get().is_empty()>
                    <div class="empty">{move || error.get()}</div>
                </Show>
                <Show when=move || !loading.get() && error.get().is_empty() && records.get().is_empty()>
                    <div class="empty">"一致する項目がありません。別のキーワードを試してください。"</div>
                </Show>
                <div class="grid">
                    <For
                        each=move || records.get()
                        key=|entry| entry.id.clone()
                        children=move |entry| {
                            let title = entry.title.clone();
                            let explanation = entry.explanation.clone().unwrap_or_else(|| "詳しい解説は準備中です。登録済みの学習範囲を確認できます。".to_string());
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
            </section>
            <footer class="footer">"MANABIXX Knowledge Library · Rust / Leptos / SQLite WebAssembly"</footer>
        </main>
    }
}

#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = window, js_name = isBlogView)]
    fn is_blog_view() -> bool;
}

#[component]
fn BlogApp() -> impl IntoView {
    view! {
        <main class="shell">
            <header class="topbar">
                <a class="brand" href="https://manabixx.github.io/">MANABIXX</a>
                <a class="back" href="https://manabixx.github.io/">"← 学習アプリへ戻る"</a>
            </header>
            <section class="hero">
                <div class="eyebrow">MANABIXX / BLOG · RUST + LEPTOS</div>
                <h1>"学びを続けるための読みもの。"</h1>
                <p>"学習習慣・勉強法・モチベーションの記事を、MANABIXXブログで。"</p>
            </section>
            <section class="entry">
                <h2>"MANABIXXブログ"</h2>
                <p>"学習を続けるヒントや、日々の学びに役立つ記事を掲載しています。"</p>
                <a class="filter active" href="https://manabixx.github.io/blog/" target="_blank" rel="noopener noreferrer">"MANABIXXブログを開く ↗"</a>
            </section>
            <footer class="footer">"MANABIXX BLOG · Rust / Leptos"</footer>
        </main>
    }
}

#[component]
fn App() -> impl IntoView {
    if is_blog_view() {
        view! { <BlogApp/> }.into_view()
    } else {
        view! { <KnowledgeApp/> }.into_view()
    }
}

fn main() {
    mount_to_body(App);
}

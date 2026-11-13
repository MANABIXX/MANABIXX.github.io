<script>import {ArrowLeft,ArrowUpRight,Sparkles,Layers3,Target,BookOpen,Smartphone} from 'lucide-svelte';</script>
<svelte:head><title>更新履歴 — MANABIXX Study</title><meta name="description" content="MANABIXX Studyの機能追加・改善履歴。"/></svelte:head>
<main>
  <a href="/" class="back"><ArrowLeft size={16}/> Studyホームへ戻る</a>
  <header><div class="eyebrow"><Sparkles size={14}/> PRODUCT CHANGELOG</div><h1>進化の記録<span>.</span></h1><p>MANABIXX Studyに加わった、新しい機能と改善。</p></header>
  <article class="release">
    <div class="release-meta"><span class="version">DESIGN UPDATE</span><time>2026.11.13</time><span class="latest">LATEST</span></div>
    <h2>Studyを、ゼロから再設計。</h2>
    <p class="lead">旧Studyの見た目を引き継ぐのではなく、MANABIXX独自の学習ワークスペースとしてホーム画面を全面的に作り直しました。</p>
    <div class="change-grid">
      <div><span class="change-icon"><Layers3 size={18}/></span><strong>新しいダッシュボード</strong><p>ワイドなナビゲーション、学習状況、演習への導線を再構成。</p></div>
      <div><span class="change-icon"><Target size={18}/></span><strong>Practice Lab</strong><p>教科・分野・難易度を選び、学習セッションを組み立てる画面に刷新。</p></div>
      <div><span class="change-icon"><BookOpen size={18}/></span><strong>教材へのアクセス</strong><p>ライブラリ、要点まとめ、入試問題、模試を独立した入口として整理。</p></div>
      <div><span class="change-icon"><Smartphone size={18}/></span><strong>モバイル体験</strong><p>スマートフォン用の下部ナビゲーションと、画面幅に応じたレイアウトを実装。</p></div>
    </div>
    <div class="release-note"><strong>学習機能はそのまま継続</strong><p>問題データ、回答判定、解説表示、苦手問題、ブックマーク、学習記録は維持しています。</p></div>
  </article>
  <footer><a href="/">MANABIXX<span>.</span></a><span>BUILDING BETTER LEARNING.</span></footer>
</main>
<style>
  :global(body){background:var(--bg);color:var(--ink)}
  main{max-width:920px;margin:auto;padding:38px 24px 50px}
  .back{display:inline-flex;align-items:center;gap:8px;color:var(--muted);font-size:10px;font-weight:700}
  header{padding:70px 0 34px}.eyebrow{display:flex;align-items:center;gap:8px;color:var(--brand);font-size:8px;letter-spacing:1.8px;font-weight:850}
  h1{font-size:clamp(36px,6vw,58px);letter-spacing:-2px;margin:15px 0 8px}h1 span,footer a span{color:var(--brand)}
  header>p{font-size:11px;color:var(--muted)}
  .release{padding:clamp(20px,4vw,38px);border:1px solid var(--line);border-radius:18px;background:var(--surface);box-shadow:var(--shadow)}
  .release-meta{display:flex;align-items:center;gap:12px;font-size:8px;color:var(--muted);letter-spacing:1px}
  .version{color:var(--brand);font-weight:900}.latest{margin-left:auto;padding:5px 8px;background:var(--brand-soft);border-radius:5px;color:var(--brand);font-weight:900}
  h2{font-size:clamp(22px,3vw,30px);letter-spacing:-.8px;margin:22px 0 9px}
  .lead{font-size:11px;line-height:2;color:var(--text-soft);max-width:680px}
  .change-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:11px;margin-top:26px}
  .change-grid>div{padding:18px;border:1px solid var(--line);border-radius:11px;background:var(--bg)}
  .change-icon{width:34px;height:34px;border-radius:9px;background:var(--brand-soft);color:var(--brand);display:grid;place-items:center}
  .change-grid strong{display:block;font-size:11px;margin-top:13px}.change-grid p,.release-note p{font-size:9px;line-height:1.8;color:var(--muted);margin:6px 0 0}
  .release-note{margin-top:15px;padding:16px 18px;border-left:3px solid var(--brand);background:var(--brand-soft);border-radius:0 9px 9px 0}
  .release-note strong{font-size:10px}
  footer{display:flex;justify-content:space-between;align-items:center;border-top:1px solid var(--line);margin-top:35px;padding-top:18px;color:var(--muted);font-size:7px;letter-spacing:1.2px}
  footer a{font-size:13px;font-weight:950;color:var(--ink)}
  @media(max-width:560px){main{padding:24px 16px 40px}header{padding:52px 0 26px}.change-grid{grid-template-columns:1fr}.release{padding:19px}.release-meta{gap:8px}}
</style>
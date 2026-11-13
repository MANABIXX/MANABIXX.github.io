<script>
  import { onMount } from 'svelte';
  import {
    ArrowRight, ArrowUpRight, Atom, BarChart3, Bookmark, BookOpen, Check,
    ChevronDown, ChevronLeft, CircleHelp, Clock3, Compass, Flame, GraduationCap,
    Layers3, LibraryBig, Menu, Moon, Search, Settings2, Sparkles, Sun, Target,
    Trophy, X, RotateCcw, Zap
  } from 'lucide-svelte';
  import { toast } from 'svelte-sonner';

  let bank = $state([]);
  let loading = $state(true);
  let loadError = $state('');
  let screen = $state('home');
  let subject = $state('all');
  let topic = $state('all');
  let level = $state('all');
  let amount = $state('10');
  let query = $state('');
  let pool = $state([]);
  let index = $state(0);
  let selected = $state(null);
  let score = $state(0);
  let answered = $state(0);
  let correctTotal = $state(0);
  let wrongIds = $state([]);
  let bookmarks = $state([]);
  let theme = $state('light');
  let mobileMenu = $state(false);
  let q = $derived(pool[index]);
  let topics = $derived([...new Set(bank.filter(x => subject === 'all' || x.subject === subject).map(x => x.topic).filter(Boolean))].sort((a,b) => a.localeCompare(b,'ja')));
  let filtered = $derived(bank.filter(x =>
    (subject === 'all' || x.subject === subject) &&
    (topic === 'all' || x.topic === topic) &&
    (level === 'all' || (x.level || '基礎') === level) &&
    (!query || (x.prompt || '').toLowerCase().includes(query.toLowerCase()) || (x.topic || '').toLowerCase().includes(query.toLowerCase()))
  ));
  let scienceCount = $derived(bank.filter(x => x.subject === 'science').length);
  let socialCount = $derived(bank.filter(x => x.subject === 'social').length);
  let accuracy = $derived(answered ? Math.round(correctTotal / answered * 100) : 0);
  let completion = $derived(bank.length ? Math.min(100, Math.round(answered / bank.length * 100)) : 0);

  onMount(async () => {
    try {
      const response = await fetch('/data/questions.json');
      if (!response.ok) throw new Error('問題データを読み込めませんでした');
      const payload = await response.json();
      bank = Array.isArray(payload) ? payload : (payload.questions || []);
      const saved = JSON.parse(localStorage.getItem('manabixx-study-v3') || '{}');
      answered = saved.answered || 0;
      correctTotal = saved.correct || 0;
      wrongIds = saved.wrong || [];
      bookmarks = saved.bookmarks || [];
      theme = localStorage.getItem('manabixx-theme') || 'light';
      document.documentElement.dataset.theme = theme;
    } catch (error) {
      loadError = error.message || '読み込みに失敗しました';
    } finally {
      loading = false;
    }
  });

  function persist() {
    localStorage.setItem('manabixx-study-v3', JSON.stringify({ answered, correct: correctTotal, wrong: wrongIds, bookmarks }));
  }
  function begin(mode = 'normal') {
    let list = [...filtered];
    if (mode === 'wrong') list = list.filter(x => wrongIds.includes(x.id));
    if (mode === 'bookmarks') list = list.filter(x => bookmarks.includes(x.id));
    for (let i = list.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [list[i], list[j]] = [list[j], list[i]];
    }
    if (amount !== 'all' && mode === 'normal') list = list.slice(0, Number(amount));
    if (!list.length) { toast.error('この条件に合う問題がありません'); return; }
    pool = list; index = 0; selected = null; score = 0; screen = 'quiz'; mobileMenu = false;
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
  function choose(i) {
    if (selected !== null) return;
    selected = i;
    const item = pool[index];
    const ok = i === item.correct;
    answered += 1;
    if (ok) { score += 1; correctTotal += 1; wrongIds = wrongIds.filter(id => id !== item.id); }
    else if (!wrongIds.includes(item.id)) wrongIds = [...wrongIds, item.id];
    persist();
  }
  function next() {
    if (index === pool.length - 1) { screen = 'result'; return; }
    index += 1; selected = null;
  }
  function toggleBookmark() {
    const id = q.id;
    bookmarks = bookmarks.includes(id) ? bookmarks.filter(x => x !== id) : [...bookmarks, id];
    persist();
    toast.success(bookmarks.includes(id) ? '復習リストに保存しました' : '保存を解除しました');
  }
  function toggleTheme() {
    theme = theme === 'light' ? 'dark' : 'light';
    document.documentElement.dataset.theme = theme;
    localStorage.setItem('manabixx-theme', theme);
  }
  function resetFilters() { subject = 'all'; topic = 'all'; level = 'all'; amount = '10'; query = ''; }
  function backHome() { screen = 'home'; window.scrollTo({ top: 0, behavior: 'smooth' }); }
</script>

<svelte:head>
  <title>Study — MANABIXX</title>
  <meta name="description" content="学習を設計し、理解を積み上げる。MANABIXX Study."/>
  <meta name="theme-color" content="#10131d"/>
  <link rel="manifest" href="/manifest.webmanifest"/>
  <link rel="icon" href="/assets/study-icon.svg" type="image/svg+xml"/>
</svelte:head>

{#if screen === 'home'}
  <div class="app-shell">
    <aside class:open={mobileMenu} class="sidebar">
      <a class="brand" href="/" aria-label="MANABIXX Study"><span class="brand-mark">M<span>.</span></span><span class="brand-name">MANABIXX<small>LEARNING PLATFORM</small></span></a>
      <div class="side-label">WORKSPACE</div>
      <nav class="side-nav">
        <a class="nav-item active" href="/"><Layers3 size={18}/><span>ホーム</span><kbd>01</kbd></a>
        <button class="nav-item" onclick={() => document.getElementById('practice')?.scrollIntoView({behavior:'smooth'})}><Target size={18}/><span>問題演習</span><kbd>02</kbd></button>
        <a class="nav-item" href="/library/"><LibraryBig size={18}/><span>教材ライブラリ</span><kbd>03</kbd></a>
        <a class="nav-item" href="/summary/"><BookOpen size={18}/><span>要点まとめ</span></a>
        <a class="nav-item" href="/exam/"><GraduationCap size={18}/><span>入試問題</span></a>
        <a class="nav-item" href="/mock-exam/"><BarChart3 size={18}/><span>模試・予想問題</span></a>
      </nav>
      <div class="sidebar-bottom">
        <div class="side-label">YOUR SPACE</div>
        <a class="nav-item" href="/releases/"><Sparkles size={18}/><span>アップデート</span></a>
        <button class="nav-item" onclick={toggleTheme}>{#if theme === 'light'}<Moon size={18}/>{:else}<Sun size={18}/>{/if}<span>表示テーマ</span></button>
        <div class="profile-card"><div class="profile-avatar">M</div><div><strong>My learning</strong><small>Personal workspace</small></div><Settings2 size={16}/></div>
      </div>
    </aside>

    <main class="main-area">
      <header class="topbar">
        <button class="mobile-menu" onclick={() => mobileMenu = !mobileMenu} aria-label="メニュー">{#if mobileMenu}<X size={20}/>{:else}<Menu size={20}/>{/if}</button>
        <div class="breadcrumb"><span>MANABIXX</span><i>/</i> Study</div>
        <div class="topbar-right"><span class="status-pill"><i></i> SYSTEM ONLINE</span><button class="icon-button" onclick={toggleTheme} aria-label="テーマ切替">{#if theme === 'light'}<Moon size={17}/>{:else}<Sun size={17}/>{/if}</button><div class="top-avatar">M</div></div>
      </header>

      <div class="content">
        <section class="welcome-row">
          <div><div class="overline"><span></span> YOUR LEARNING OVERVIEW <span class="date-label">/ STUDY DESK</span></div><h1>学びを、<em>自分の武器に。</em></h1><p>今日やることを決めて、ひとつずつ理解に変えていこう。</p></div>
          <div class="welcome-actions"><span class="edition">MANABIXX <b>STUDY</b> / 02</span><button class="primary-button" onclick={() => document.getElementById('practice')?.scrollIntoView({behavior:'smooth'})}>学習をはじめる <ArrowRight size={17}/></button></div>
        </section>

        <section class="hero-grid">
          <div class="hero-main">
            <div class="hero-no">01 <span>—</span> DAILY SESSION</div>
            <div class="hero-copy"><span class="hero-chip"><Sparkles size={13}/> YOUR NEXT STEP STARTS HERE</span><h2>「わかった」を、<br/><strong>積み重ねよう。</strong></h2><p>理解できた瞬間を増やす。<br/>今日の自分に必要な問題から始めよう。</p><button onclick={() => document.getElementById('practice')?.scrollIntoView({behavior:'smooth'})}>今日の学習を設計する <ArrowUpRight size={17}/></button></div>
            <div class="hero-orbit orbit-one"></div><div class="hero-orbit orbit-two"></div><div class="hero-core"><span>MX</span><small>LEARN<br/>BETTER</small></div>
            <div class="hero-foot"><span>FOCUS ON PROGRESS</span><span>01 / 04</span></div>
          </div>
          <div class="insight-column">
            <div class="insight-card">
              <div class="card-kicker">YOUR PERFORMANCE <BarChart3 size={16}/></div>
              <div class="accuracy-number">{accuracy}<small>%</small></div><div class="accuracy-label">累計正答率</div>
              <div class="mini-bars"><i style="height:{Math.max(10,accuracy * .78)}%"></i><i style="height:{Math.max(12,accuracy * .91)}%"></i><i style="height:{Math.max(8,accuracy * .62)}%"></i><i style="height:{Math.max(15,accuracy * .84)}%"></i><i style="height:{Math.max(10,accuracy)}%"></i><i style="height:{Math.max(12,accuracy * .73)}%"></i><i style="height:{Math.max(15,accuracy * .95)}%"></i></div>
              <div class="insight-foot"><span>KEEP BUILDING</span><span>{answered.toLocaleString('ja-JP')} ANSWERS</span></div>
            </div>
            <div class="quick-stats">
              <div><span class="quick-icon violet"><Zap size={16}/></span><div><strong>{answered.toLocaleString('ja-JP')}</strong><small>解いた問題</small></div></div>
              <div><span class="quick-icon cyan"><Bookmark size={16}/></span><div><strong>{bookmarks.length}</strong><small>保存した問題</small></div></div>
              <div><span class="quick-icon orange"><Flame size={16}/></span><div><strong>{wrongIds.length}</strong><small>復習が必要</small></div></div>
            </div>
          </div>
        </section>

        <section class="metric-strip">
          <div><span>QUESTION DATABASE</span><strong>{loading ? '—' : bank.length.toLocaleString('ja-JP')}<small>問</small></strong><i>収録問題</i></div>
          <div><span>SCIENCE</span><strong>{loading ? '—' : scienceCount.toLocaleString('ja-JP')}<small>問</small></strong><i>理科</i></div>
          <div><span>SOCIAL STUDIES</span><strong>{loading ? '—' : socialCount.toLocaleString('ja-JP')}<small>問</small></strong><i>社会</i></div>
          <div class="metric-progress"><div><span>YOUR COLLECTION</span><b>{completion}%</b></div><div class="progress-line"><i style="width:{completion}%"></i></div><small>学習記録の蓄積率</small></div>
        </section>

        <section class="practice-section" id="practice">
          <div class="section-title"><div><div class="overline">02 / PRACTICE LAB</div><h2>今日のトレーニング</h2><p>教科・単元・難易度を選んで、今の自分に合った演習を。</p></div><span class="section-side-note">BUILD YOUR SKILLS <Target size={16}/></span></div>
          {#if loading}
            <div class="loading-panel"><div class="spinner"></div><span>学習データを準備しています…</span></div>
          {:else if loadError}
            <div class="loading-panel error-panel"><CircleHelp size={22}/>{loadError}</div>
          {:else}
            <div class="practice-layout">
              <div class="practice-main">
                <div class="subject-grid">
                  <button class:chosen={subject === 'all'} class="subject-card subject-all" onclick={() => {subject='all';topic='all';}}><span class="subject-top">ALL SUBJECTS <ArrowUpRight size={16}/></span><strong>理科 <i>+</i> 社会</strong><small>{(scienceCount + socialCount).toLocaleString('ja-JP')} QUESTIONS</small><div class="subject-watermark">01</div></button>
                  <button class:chosen={subject === 'science'} class="subject-card subject-science" onclick={() => {subject='science';topic='all';}}><span class="subject-top">SCIENCE <Atom size={17}/></span><strong>理科</strong><small>{scienceCount.toLocaleString('ja-JP')} QUESTIONS</small><div class="subject-watermark">02</div></button>
                  <button class:chosen={subject === 'social'} class="subject-card subject-social" onclick={() => {subject='social';topic='all';}}><span class="subject-top">SOCIAL STUDIES <Compass size={17}/></span><strong>社会</strong><small>{socialCount.toLocaleString('ja-JP')} QUESTIONS</small><div class="subject-watermark">03</div></button>
                </div>
                <div class="filter-card">
                  <div class="filter-heading"><div><span>CREATE A SESSION</span><h3>演習内容をカスタマイズ</h3></div><button onclick={resetFilters}><RotateCcw size={14}/> リセット</button></div>
                  <label class="search-field"><Search size={17}/><input bind:value={query} placeholder="問題文・単元名を検索"/><kbd>⌘ K</kbd></label>
                  <div class="filter-fields">
                    <label><span>単元・分野</span><div><select bind:value={topic}><option value="all">すべての分野</option>{#each topics as t}<option value={t}>{t}</option>{/each}</select><ChevronDown size={15}/></div></label>
                    <label><span>難易度</span><div><select bind:value={level}><option value="all">すべて</option><option value="基礎">基礎</option><option value="標準">標準</option><option value="応用">応用</option></select><ChevronDown size={15}/></div></label>
                    <label><span>出題数</span><div><select bind:value={amount}><option value="10">10問</option><option value="20">20問</option><option value="30">30問</option><option value="50">50問</option><option value="all">全問</option></select><ChevronDown size={15}/></div></label>
                  </div>
                  <div class="filter-footer"><div><strong>{filtered.length.toLocaleString('ja-JP')}</strong><span>問が対象です</span></div><button class="start-button" onclick={() => begin()}>この条件でスタート <ArrowRight size={17}/></button></div>
                </div>
              </div>
              <aside class="review-column">
                <div class="review-card"><div class="review-top">REVIEW QUEUE <RotateCcw size={16}/></div><strong>{wrongIds.length.toString().padStart(2,'0')}</strong><h3>苦手を、残さない。</h3><p>間違えた問題を集めて、理解できるまで繰り返そう。</p><button onclick={() => begin('wrong')}>復習をはじめる <ArrowRight size={15}/></button></div>
                <div class="bookmark-card"><div class="bookmark-top">SAVED FOR LATER <Bookmark size={16}/></div><strong>{bookmarks.length.toString().padStart(2,'0')}<small> ITEMS</small></strong><p>あとで解き直したい問題</p><button onclick={() => begin('bookmarks')}>保存リストを開く <ArrowUpRight size={15}/></button></div>
              </aside>
            </div>
          {/if}
        </section>

        <section class="resources-section">
          <div class="section-title"><div><div class="overline">03 / KNOWLEDGE BASE</div><h2>学びを広げる</h2><p>演習だけで終わらせない。知識を整理し、実戦につなげる。</p></div><a href="/library/">すべての教材 <ArrowUpRight size={16}/></a></div>
          <div class="resource-grid">
            <a href="/library/" class="resource-card resource-library"><div class="resource-card-top"><span>01 / DISCOVER</span><LibraryBig size={18}/></div><div class="resource-symbol"><LibraryBig size={24}/></div><h3>学習ライブラリ</h3><p>単元・用語・資料を横断して探す。</p><span>ライブラリを開く <ArrowUpRight size={15}/></span></a>
            <a href="/summary/" class="resource-card resource-summary"><div class="resource-card-top"><span>02 / UNDERSTAND</span><BookOpen size={18}/></div><div class="resource-symbol"><BookOpen size={24}/></div><h3>要点まとめ</h3><p>重要事項を整理し、知識をつなげる。</p><span>要点を確認する <ArrowUpRight size={15}/></span></a>
            <a href="/exam/" class="resource-card resource-exam"><div class="resource-card-top"><span>03 / APPLY</span><GraduationCap size={18}/></div><div class="resource-symbol"><GraduationCap size={24}/></div><h3>公立入試問題</h3><p>実際の出題形式で、実戦力を磨く。</p><span>過去問に挑戦 <ArrowUpRight size={15}/></span></a>
            <a href="/mock-exam/" class="resource-card resource-mock"><div class="resource-card-top"><span>04 / MEASURE</span><BarChart3 size={18}/></div><div class="resource-symbol"><BarChart3 size={24}/></div><h3>模試・予想問題</h3><p>今の実力を確かめ、次の課題を見つける。</p><span>実力をチェック <ArrowUpRight size={15}/></span></a>
          </div>
        </section>

        <footer class="footer"><a href="/" class="footer-brand">MANABIXX<span>.</span></a><span>DESIGNED FOR BETTER LEARNING.</span><a href="/releases/">リリースノート <ArrowUpRight size={14}/></a></footer>
      </div>
    </main>
    <nav class="mobile-dock"><a class="selected" href="/"><Layers3 size={18}/><span>ホーム</span></a><button onclick={() => document.getElementById('practice')?.scrollIntoView({behavior:'smooth'})}><Target size={18}/><span>演習</span></button><a href="/library/"><LibraryBig size={18}/><span>教材</span></a><button onclick={toggleTheme}>{#if theme === 'light'}<Moon size={18}/>{:else}<Sun size={18}/>{/if}<span>テーマ</span></button></nav>
  </div>
{:else if screen === 'quiz'}
  <main class="quiz-shell">
    <header class="quiz-header"><button onclick={backHome}><ChevronLeft size={18}/> 学習画面へ戻る</button><a href="/" class="quiz-brand">MANABIXX<span>.</span> <small>FOCUS MODE</small></a><div class="quiz-counter">{String(index + 1).padStart(2,'0')} <i>/ {String(pool.length).padStart(2,'0')}</i></div></header>
    <div class="quiz-progress"><i style="width:{(index + 1) / pool.length * 100}%"></i></div>
    {#if q}
      <section class="quiz-content">
        <div class="quiz-meta"><span>{q.subject === 'science' ? 'SCIENCE / 理科' : 'SOCIAL / 社会'}</span><span>{q.topic}</span><span>{q.level || '基礎'}</span></div>
        <div class="quiz-label">QUESTION <b>{String(index + 1).padStart(2,'0')}</b></div>
        <h1>{q.prompt}</h1>
        <div class="answer-list">{#each q.options as option, i}<button class:correct={selected !== null && i === q.correct} class:incorrect={selected === i && selected !== q.correct} class:muted={selected !== null && i !== selected && i !== q.correct} disabled={selected !== null} onclick={() => choose(i)}><span>{String(i + 1).padStart(2,'0')}</span><b>{option}</b>{#if selected !== null && i === q.correct}<Check size={19}/>{/if}</button>{/each}</div>
        {#if selected !== null}<div class:good={selected === q.correct} class:bad={selected !== q.correct} class="explanation"><strong>{selected === q.correct ? '正解。いい調子。' : 'ここを確認しよう。'}</strong><p>{q.explanation}</p>{#if q.sourceNote}<small>{q.sourceNote}</small>{/if}</div>{/if}
        <div class="quiz-actions"><button class="save-button" onclick={toggleBookmark}><Bookmark size={16}/>{bookmarks.includes(q.id) ? '保存済み' : 'あとで復習'}</button><button class="next-button" disabled={selected === null} onclick={next}>{index === pool.length - 1 ? '結果を見る' : '次の問題へ'} <ArrowRight size={17}/></button></div>
      </section>
    {/if}
    <footer class="quiz-footer"><span>ONE QUESTION AT A TIME.</span><span>MANABIXX / STUDY</span></footer>
  </main>
{:else}
  <main class="result-shell"><div class="result-mark"><Trophy size={30}/></div><div class="overline">SESSION COMPLETE</div><h1>今日の一歩、完了。</h1><p>積み重ねた時間は、ちゃんと力になっている。</p><div class="result-card"><span>YOUR SCORE</span><strong>{score}<small> / {pool.length}</small></strong><div class="result-track"><i style="width:{pool.length ? score / pool.length * 100 : 0}%"></i></div><b>正答率 {pool.length ? Math.round(score / pool.length * 100) : 0}%</b></div><button class="next-button" onclick={() => {screen='home';begin();}}>もう一度演習する <ArrowRight size={17}/></button><button class="result-back" onclick={backHome}>ホームに戻る</button></main>
{/if}

<style>
  :global(body){margin:0;background:#f4f6fb;color:#202438;font-family:Inter,'DM Sans','Noto Sans JP',sans-serif}
  :global(:root[data-theme='dark']){color-scheme:dark;--bg:#0d1019;--surface:#151a27;--surface2:#1c2333;--ink:#f2f4fb;--muted:#9aa4ba;--line:#293247;--brand:#9a8cff;--brand-soft:#292545;--cyan:#68d8e8;--text-soft:#b4bdd0}
  :global(:root:not([data-theme='dark'])){--bg:#f4f6fb;--surface:#fff;--surface2:#f0f2f8;--ink:#202438;--muted:#7e879d;--line:#e4e8f0;--brand:#6658e8;--brand-soft:#eeecff;--cyan:#0fa8bd;--text-soft:#68738a}
  .app-shell{min-height:100vh;background:var(--bg);color:var(--ink);display:flex}
  .sidebar{position:fixed;inset:0 auto 0 0;width:246px;background:#111522;color:#e9ecf8;padding:27px 18px 18px;display:flex;flex-direction:column;z-index:40;border-right:1px solid #252b3c}
  .brand{display:flex;align-items:center;gap:11px;padding:0 9px 36px}.brand-mark{width:39px;height:39px;border-radius:12px;background:linear-gradient(145deg,#897bff,#5548d6);display:grid;place-items:center;font-size:20px;font-weight:900;color:white;box-shadow:0 7px 22px #6556e94a;letter-spacing:-2px}.brand-mark span{color:#b8f5ff}.brand-name{font-size:13px;letter-spacing:1.2px;font-weight:900}.brand-name small{display:block;font-size:7px;letter-spacing:1.8px;color:#79849d;margin-top:4px;font-weight:700}.side-label{font-size:8px;letter-spacing:1.8px;font-weight:800;color:#65718a;padding:0 12px 11px}.side-nav{display:grid;gap:5px}.nav-item{width:100%;height:45px;border:0;background:transparent;color:#a4aec4;display:flex;align-items:center;gap:13px;padding:0 12px;border-radius:9px;text-align:left;font-size:11px;font-weight:650;transition:.18s}.nav-item:hover{background:#1b2233;color:#fff}.nav-item.active{background:linear-gradient(100deg,#5146c8,#685be7);color:white;box-shadow:0 7px 20px #5146c833}.nav-item kbd{margin-left:auto;font-size:8px;color:#77829a;background:#20283a;padding:3px 5px;border-radius:4px}.nav-item.active kbd{background:#ffffff22;color:#e6e2ff}.sidebar-bottom{margin-top:auto}.sidebar-bottom>.side-label{padding-top:16px}.profile-card{margin-top:20px;padding:12px 10px;border:1px solid #2a3245;background:#171e2d;border-radius:11px;display:flex;align-items:center;gap:9px}.profile-avatar,.top-avatar{width:30px;height:30px;border-radius:9px;background:#2d3650;color:#c8c2ff;display:grid;place-items:center;font-size:11px;font-weight:900}.profile-card strong{display:block;font-size:9px}.profile-card small{display:block;color:#7f8ba5;font-size:8px;margin-top:3px}.profile-card>svg{margin-left:auto;color:#77839d}
  .main-area{margin-left:246px;min-width:0;flex:1}.topbar{height:70px;border-bottom:1px solid var(--line);display:flex;align-items:center;justify-content:space-between;padding:0 clamp(22px,4vw,60px);background:var(--surface)}.breadcrumb{font-size:11px;font-weight:750}.breadcrumb span{color:var(--muted)}.breadcrumb i{font-style:normal;color:#b6bdcc;margin:0 10px}.topbar-right{display:flex;align-items:center;gap:17px}.status-pill{font-size:8px;letter-spacing:1.2px;font-weight:800;color:var(--muted)}.status-pill i{display:inline-block;width:6px;height:6px;border-radius:50%;background:#36c69a;margin-right:7px;box-shadow:0 0 0 4px #36c69a18}.icon-button{width:34px;height:34px;border:1px solid var(--line);border-radius:9px;background:var(--surface);color:var(--ink);display:grid;place-items:center}.top-avatar{border-radius:50%;background:var(--brand-soft);color:var(--brand)}.mobile-menu{display:none}
  .content{max-width:1540px;margin:auto;padding:36px clamp(22px,4vw,60px) 30px}.welcome-row{display:flex;align-items:end;justify-content:space-between;gap:20px;margin-bottom:25px}.overline{font-size:8px;letter-spacing:1.8px;font-weight:850;color:var(--brand)}.overline>span:first-child{display:inline-block;width:17px;height:2px;background:var(--brand);vertical-align:middle;margin-right:8px}.date-label{color:var(--muted);margin-left:5px}.welcome-row h1{font-size:clamp(27px,3vw,39px);letter-spacing:-1.7px;margin:11px 0 7px;font-weight:850}.welcome-row h1 em{font-style:normal;color:var(--brand)}.welcome-row p{font-size:11px;color:var(--muted);margin:0}.welcome-actions{display:flex;align-items:center;gap:18px}.edition{font-size:8px;letter-spacing:1px;color:var(--muted);font-weight:800;white-space:nowrap}.edition b{color:var(--brand)}.primary-button,.start-button,.next-button{height:43px;border:0;border-radius:8px;background:linear-gradient(105deg,#6456e7,#8173fa);color:white;padding:0 17px;display:flex;align-items:center;justify-content:center;gap:20px;font-size:10px;font-weight:800;box-shadow:0 8px 20px #6658e82b;transition:transform .18s,box-shadow .18s}.primary-button:hover,.start-button:hover,.next-button:hover{transform:translateY(-2px);box-shadow:0 12px 26px #6658e83b}
  .hero-grid{display:grid;grid-template-columns:minmax(0,1.65fr) minmax(250px,.85fr);gap:15px}.hero-main{min-height:300px;position:relative;overflow:hidden;border-radius:16px;padding:26px 31px;background:radial-gradient(circle at 82% 45%,#4e4aa0 0,#292d59 27%,#1c2341 59%,#171d32 100%);color:#f5f5ff}.hero-no{font-size:8px;letter-spacing:1.8px;font-weight:800;color:#9fa9d0}.hero-no span{color:#68739d;margin:0 6px}.hero-copy{position:relative;z-index:2;margin-top:24px}.hero-chip{display:inline-flex;align-items:center;gap:6px;border:1px solid #ffffff27;background:#ffffff0d;padding:6px 9px;border-radius:30px;font-size:7px;letter-spacing:1.1px;color:#c9d2f6}.hero-chip svg{color:#9e92ff}.hero-copy h2{font-size:clamp(28px,3vw,39px);line-height:1.32;letter-spacing:-1.8px;margin:14px 0 9px}.hero-copy h2 strong{color:#b9b0ff}.hero-copy p{font-size:10px;line-height:1.9;color:#bac3df;margin:0 0 17px}.hero-copy button{height:38px;padding:0 13px;border:1px solid #ffffff32;border-radius:7px;background:#ffffff12;color:white;display:flex;align-items:center;gap:23px;font-size:9px;font-weight:750}.hero-orbit{position:absolute;border:1px solid #b9b1ff24;border-radius:50%;pointer-events:none}.orbit-one{width:280px;height:280px;right:5%;top:10px}.orbit-two{width:205px;height:205px;right:calc(5% + 38px);top:48px;border-style:dashed;animation:spin 45s linear infinite}.hero-core{position:absolute;right:calc(5% + 83px);top:100px;width:115px;height:115px;border-radius:50%;background:linear-gradient(145deg,#a89dff,#5e54d4);box-shadow:0 0 0 14px #9b90ff12,0 0 60px #8c80ff55;display:flex;flex-direction:column;align-items:center;justify-content:center;transform:rotate(-9deg)}.hero-core span{font-size:36px;font-weight:950;letter-spacing:-4px}.hero-core small{font-size:6px;letter-spacing:1.8px;text-align:center;line-height:1.4}.hero-foot{position:absolute;bottom:17px;left:31px;right:31px;display:flex;justify-content:space-between;font-size:7px;letter-spacing:1.5px;color:#7e89b2}
  .insight-column{display:grid;grid-template-rows:1fr auto;gap:12px}.insight-card{background:var(--surface);border:1px solid var(--line);border-radius:15px;padding:19px 20px;box-shadow:0 8px 26px #252d4a08;position:relative;overflow:hidden}.card-kicker{display:flex;justify-content:space-between;align-items:center;font-size:8px;letter-spacing:1.3px;font-weight:850;color:var(--muted)}.card-kicker svg{color:var(--brand)}.accuracy-number{font-size:42px;font-weight:850;letter-spacing:-2px;margin-top:16px}.accuracy-number small{font-size:16px;color:var(--muted);margin-left:3px}.accuracy-label{font-size:9px;color:var(--muted)}.mini-bars{position:absolute;right:20px;bottom:43px;height:75px;display:flex;align-items:end;gap:6px}.mini-bars i{width:8px;border-radius:5px 5px 2px 2px;background:linear-gradient(0deg,#6759e9,#a69dff);opacity:.9}.insight-foot{border-top:1px solid var(--line);margin-top:20px;padding-top:11px;display:flex;justify-content:space-between;font-size:7px;letter-spacing:1px;color:var(--muted);font-weight:750}.quick-stats{display:grid;grid-template-columns:repeat(3,1fr);gap:8px}.quick-stats>div{border:1px solid var(--line);border-radius:11px;background:var(--surface);padding:10px 9px;display:flex;align-items:center;gap:8px;min-width:0}.quick-icon{width:28px;height:28px;display:grid;place-items:center;border-radius:8px;flex:none}.quick-icon.violet{background:#eeecff;color:#6759e9}.quick-icon.cyan{background:#e3f8fb;color:#149eb3}.quick-icon.orange{background:#fff0e5;color:#e78a3d}.quick-stats strong{display:block;font-size:15px;line-height:1.1}.quick-stats small{display:block;font-size:7px;color:var(--muted);margin-top:4px;white-space:nowrap}
  .metric-strip{display:grid;grid-template-columns:repeat(3,1fr) 1.5fr;gap:0;margin-top:16px;padding:17px 0;border-bottom:1px solid var(--line);border-top:1px solid var(--line)}.metric-strip>div{padding:0 20px;border-right:1px solid var(--line)}.metric-strip>div:first-child{padding-left:0}.metric-strip>div:last-child{border:0;padding-right:0}.metric-strip span{display:block;font-size:7px;letter-spacing:1.3px;color:var(--muted);font-weight:850}.metric-strip strong{display:block;font-size:23px;letter-spacing:-1px;margin-top:4px}.metric-strip strong small{font-size:10px;color:var(--muted);margin-left:3px}.metric-strip i{font-style:normal;font-size:8px;color:var(--muted)}.metric-progress>div:first-child{display:flex;align-items:center;justify-content:space-between}.metric-progress>div:first-child b{font-size:11px;color:var(--brand)}.progress-line{height:5px;border-radius:9px;background:var(--surface2);margin:12px 0 7px;overflow:hidden}.progress-line i{display:block;height:100%;border-radius:9px;background:linear-gradient(90deg,#6255e5,#9c91ff)}.metric-progress>small{font-size:8px;color:var(--muted)}
  .practice-section,.resources-section{padding-top:38px}.section-title{display:flex;align-items:end;justify-content:space-between;margin-bottom:18px}.section-title h2{font-size:22px;letter-spacing:-.8px;margin:7px 0 5px}.section-title p{font-size:10px;color:var(--muted);margin:0}.section-side-note,.section-title>a{display:flex;align-items:center;gap:8px;font-size:8px;letter-spacing:1px;color:var(--muted);font-weight:800}.section-side-note svg{color:var(--brand)}.section-title>a{color:var(--brand)}
  .practice-layout{display:grid;grid-template-columns:minmax(0,1fr) 250px;gap:13px}.practice-main{min-width:0}.subject-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:9px}.subject-card{height:125px;border:1px solid var(--line);border-radius:12px;text-align:left;padding:14px 15px;position:relative;overflow:hidden;background:var(--surface);color:var(--ink);transition:.18s}.subject-card:hover{transform:translateY(-3px);box-shadow:var(--shadow)}.subject-card.chosen{border-color:var(--brand);box-shadow:inset 0 0 0 1px var(--brand),0 7px 18px #6658e814}.subject-top{display:flex;justify-content:space-between;align-items:center;font-size:7px;letter-spacing:1.1px;color:var(--muted);font-weight:850}.subject-top svg{color:var(--brand)}.subject-card>strong{display:block;font-size:22px;letter-spacing:-.8px;margin-top:16px;position:relative;z-index:1}.subject-card>strong i{font-style:normal;color:var(--brand)}.subject-card>small{display:block;font-size:7px;letter-spacing:1px;color:var(--muted);margin-top:3px;position:relative;z-index:1}.subject-watermark{position:absolute;right:8px;bottom:-21px;font-size:77px;font-weight:950;letter-spacing:-7px;color:var(--surface2)}.subject-science{background:linear-gradient(140deg,var(--surface),#eaf7f7)}:root[data-theme='dark'] .subject-science{background:linear-gradient(140deg,var(--surface),#1c3039)}.subject-social{background:linear-gradient(140deg,var(--surface),#f1edff)}:root[data-theme='dark'] .subject-social{background:linear-gradient(140deg,var(--surface),#282440)}
  .filter-card{margin-top:11px;border:1px solid var(--line);background:var(--surface);border-radius:13px;padding:19px 20px;box-shadow:0 8px 26px #252d4a06}.filter-heading{display:flex;justify-content:space-between;align-items:start}.filter-heading span{font-size:7px;letter-spacing:1.5px;color:var(--muted);font-weight:850}.filter-heading h3{font-size:14px;margin:5px 0 0}.filter-heading button{border:0;background:transparent;color:var(--muted);font-size:9px;display:flex;align-items:center;gap:5px}.search-field{height:42px;margin-top:17px;border:1px solid var(--line);border-radius:8px;display:flex;align-items:center;gap:10px;padding:0 11px;color:var(--muted)}.search-field:focus-within{border-color:var(--brand);box-shadow:0 0 0 3px var(--brand-soft)}.search-field input{flex:1;min-width:0;border:0;outline:0;background:transparent;color:var(--ink);font-size:10px}.search-field kbd{font-size:7px;border:1px solid var(--line);border-radius:4px;padding:4px 6px;color:var(--muted)}.filter-fields{display:grid;grid-template-columns:repeat(3,1fr);gap:9px;margin-top:13px}.filter-fields label>span{display:block;font-size:8px;color:var(--muted);font-weight:750;margin-bottom:6px}.filter-fields label>div{position:relative}.filter-fields select{appearance:none;width:100%;height:38px;border:1px solid var(--line);border-radius:7px;background:var(--bg);color:var(--ink);padding:0 28px 0 9px;font-size:9px}.filter-fields svg{position:absolute;right:9px;top:11px;color:var(--muted);pointer-events:none}.filter-footer{display:flex;align-items:center;justify-content:space-between;border-top:1px solid var(--line);margin-top:16px;padding-top:14px}.filter-footer>div{display:flex;align-items:baseline;gap:7px}.filter-footer strong{font-size:19px}.filter-footer span{font-size:8px;color:var(--muted)}.start-button{height:39px;border-radius:7px;font-size:9px;gap:16px;padding:0 13px}
  .review-column{display:flex;flex-direction:column;gap:10px}.review-card{background:linear-gradient(150deg,#222849,#171d32);color:white;border-radius:13px;padding:17px;display:flex;flex-direction:column;min-height:190px}.review-top,.bookmark-top{display:flex;align-items:center;justify-content:space-between;font-size:7px;letter-spacing:1.3px;font-weight:850;color:#aab5d7}.review-top svg{color:#a69cff}.review-card>strong{font-size:41px;letter-spacing:-2px;color:#c1baff;margin-top:20px}.review-card h3{font-size:13px;margin:3px 0 5px}.review-card p{font-size:8px;line-height:1.8;color:#b2bdd7;margin:0 0 14px}.review-card button{margin-top:auto;border:0;border-top:1px solid #ffffff22;background:none;color:#c3bcff;display:flex;justify-content:space-between;align-items:center;padding:11px 0 0;font-size:8px;font-weight:800}.bookmark-card{border:1px solid var(--line);background:var(--surface);border-radius:12px;padding:15px 16px}.bookmark-top{color:var(--muted)}.bookmark-top svg{color:var(--brand)}.bookmark-card>strong{display:block;font-size:29px;margin-top:14px;letter-spacing:-1px}.bookmark-card>strong small{font-size:7px;letter-spacing:1px;color:var(--muted)}.bookmark-card p{font-size:8px;color:var(--muted);margin:3px 0 12px}.bookmark-card button{width:100%;border:0;border-top:1px solid var(--line);padding:10px 0 0;background:transparent;display:flex;align-items:center;justify-content:space-between;font-size:8px;font-weight:800;color:var(--ink)}
  .resources-section{padding-top:42px}.resource-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:10px}.resource-card{min-height:170px;border:1px solid var(--line);border-radius:12px;background:var(--surface);padding:15px;display:flex;flex-direction:column;transition:transform .18s,border-color .18s,box-shadow .18s}.resource-card:hover{transform:translateY(-4px);border-color:var(--brand);box-shadow:var(--shadow)}.resource-card-top{display:flex;align-items:center;justify-content:space-between;font-size:7px;letter-spacing:1px;color:var(--muted);font-weight:850}.resource-card-top svg{color:var(--brand)}.resource-symbol{width:37px;height:37px;border-radius:10px;background:var(--brand-soft);color:var(--brand);display:grid;place-items:center;margin-top:18px}.resource-card h3{font-size:13px;margin:11px 0 4px}.resource-card p{font-size:8px;color:var(--muted);line-height:1.7;margin:0}.resource-card>span:last-child{display:flex;align-items:center;justify-content:space-between;margin-top:auto;padding-top:12px;font-size:8px;color:var(--brand);font-weight:800}.resource-summary .resource-symbol{background:#e5f7f7;color:#149eb3}.resource-exam .resource-symbol{background:#fff0e6;color:#e28b49}.resource-mock .resource-symbol{background:#e9e8ff;color:#6c5de6}
  .footer{margin-top:46px;border-top:1px solid var(--line);padding:18px 0;display:flex;align-items:center;justify-content:space-between;color:var(--muted);font-size:7px;letter-spacing:1.2px}.footer-brand{font-size:13px;font-weight:950;letter-spacing:-.5px;color:var(--ink)}.footer-brand span,.quiz-brand span{color:var(--brand)}.footer>a:last-child{display:flex;align-items:center;gap:5px;color:var(--ink);font-weight:800}
  .loading-panel{min-height:150px;border:1px dashed var(--line);border-radius:12px;display:flex;align-items:center;justify-content:center;gap:12px;color:var(--muted);font-size:10px}.error-panel{color:#d45b68}.spinner{width:21px;height:21px;border:2px solid var(--line);border-top-color:var(--brand);border-radius:50%;animation:spin .8s linear infinite}@keyframes spin{to{transform:rotate(360deg)}}
  .mobile-dock{display:none}
  .quiz-shell{--quiz-bg:#101522;min-height:100vh;background:#101522;color:#f2f4fb;display:flex;flex-direction:column;padding:0 24px}.quiz-header{height:72px;max-width:1120px;width:100%;margin:auto;display:grid;grid-template-columns:1fr 1fr 1fr;align-items:center;border-bottom:1px solid #2b3347}.quiz-header>button{justify-self:start;display:flex;align-items:center;gap:5px;background:none;border:0;color:#aab4ca;font-size:10px}.quiz-brand{justify-self:center;font-size:13px;font-weight:900;letter-spacing:.5px}.quiz-brand small{display:block;font-size:7px;letter-spacing:2px;color:#8793b0;text-align:center;margin-top:3px}.quiz-counter{justify-self:end;font-size:14px;font-weight:850;color:#aaa0ff}.quiz-counter i{font-style:normal;color:#8793b0;font-size:10px}.quiz-progress{height:3px;max-width:1120px;width:100%;margin:0 auto;background:#293149}.quiz-progress i{display:block;height:100%;background:linear-gradient(90deg,#6558e8,#72dce8);transition:width .2s}.quiz-content{width:100%;max-width:720px;margin:57px auto 40px}.quiz-meta{display:flex;flex-wrap:wrap;gap:7px}.quiz-meta span{font-size:8px;color:#aab4ca;border:1px solid #3a455e;border-radius:5px;padding:6px 9px}.quiz-label{font-size:9px;letter-spacing:2px;color:#8793b0;margin-top:35px}.quiz-label b{color:#aaa0ff;margin-left:7px}.quiz-content h1{font-size:clamp(21px,3vw,29px);line-height:1.8;margin:16px 0 27px;font-weight:650}.answer-list{display:grid;gap:9px}.answer-list button{min-height:61px;border:1px solid #35405a;border-radius:9px;background:#171e2f;color:#f0f2fa;display:flex;align-items:center;gap:17px;text-align:left;padding:12px 17px;transition:.15s}.answer-list button:hover:not(:disabled){border-color:#a99fff;background:#1d2440}.answer-list button>span{font-size:9px;color:#929fbd;letter-spacing:1px}.answer-list button>b{font-size:12px;font-weight:500}.answer-list button svg{margin-left:auto;color:#76d7bd}.answer-list button.correct{background:#1d342f;border-color:#48b99c}.answer-list button.incorrect{background:#38272d;border-color:#d17b86}.answer-list button.muted{opacity:.42}.explanation{margin-top:17px;padding:17px 19px;border:1px solid #3b4760;border-radius:9px;background:#1a2235}.explanation.good{border-left:3px solid #53c7a8}.explanation.bad{border-left:3px solid #d17b86}.explanation strong{font-size:12px;color:#8de0c4}.explanation.bad strong{color:#f09ba6}.explanation p{font-size:11px;line-height:1.9;color:#c2cbe0;margin:7px 0 0}.explanation small{display:block;color:#929fbd;font-size:9px;margin-top:8px}.quiz-actions{display:flex;justify-content:space-between;align-items:center;margin-top:22px}.save-button{height:41px;padding:0 13px;background:transparent;border:1px solid #3b4760;border-radius:8px;color:#c0c9dd;display:flex;align-items:center;gap:8px;font-size:9px}.next-button{height:43px;padding:0 18px;border-radius:8px;gap:24px}.next-button:disabled{opacity:.35;cursor:not-allowed}.quiz-footer{max-width:1120px;width:100%;margin:auto auto 0;padding:19px 0;color:#74819e;display:flex;justify-content:space-between;font-size:7px;letter-spacing:1.5px}
  .result-shell{min-height:100vh;background:radial-gradient(circle at 50% 30%,#24264a,#101522 60%);color:#f2f4fb;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:25px;text-align:center}.result-mark{width:68px;height:68px;border:1px solid #655be1;border-radius:18px;color:#aaa0ff;display:grid;place-items:center;margin-bottom:22px;background:#6a5be51c}.result-shell .overline{color:#aaa0ff}.result-shell h1{font-size:34px;letter-spacing:-1.5px;margin:12px 0 5px}.result-shell>p{font-size:11px;color:#aab4ca}.result-card{width:min(100%,390px);padding:26px 28px;margin:24px 0;background:#1a2235;border:1px solid #35405a;border-radius:14px;display:flex;flex-direction:column;align-items:center;gap:9px}.result-card>span{font-size:8px;letter-spacing:1.5px;color:#8e9ab6}.result-card>strong{font-size:49px;letter-spacing:-3px;color:#b7afff}.result-card>strong small{font-size:15px;color:#aab4ca}.result-track{height:5px;width:100%;background:#35405a;margin:12px 0;border-radius:5px;overflow:hidden}.result-track i{display:block;height:100%;background:linear-gradient(90deg,#6558e8,#72dce8)}.result-card>b{font-size:9px;color:#aab4ca}.result-shell .next-button{margin-top:2px}.result-back{margin-top:15px;background:none;border:0;color:#aab4ca;font-size:10px}
  @media(max-width:1120px){.sidebar{width:218px}.main-area{margin-left:218px}.hero-grid{grid-template-columns:minmax(0,1.35fr) minmax(230px,.85fr)}.hero-core{right:calc(3% + 55px)}.orbit-one{right:2%}.orbit-two{right:calc(2% + 38px)}.practice-layout{grid-template-columns:minmax(0,1fr) 220px}.resource-grid{grid-template-columns:repeat(2,1fr)}}
  @media(max-width:820px){.sidebar{width:246px;transform:translateX(-100%);transition:transform .22s;box-shadow:20px 0 60px #080b1680}.sidebar.open{transform:translateX(0)}.main-area{margin-left:0}.mobile-menu{display:grid;place-items:center;width:34px;height:34px;border:0;background:transparent;color:var(--ink)}.topbar{justify-content:start;gap:12px;padding:0 17px}.topbar-right{margin-left:auto}.status-pill{display:none}.content{padding:26px 18px 25px}.welcome-row{align-items:start}.welcome-row h1{font-size:29px}.welcome-actions{flex-direction:column-reverse;align-items:end;gap:9px}.edition{font-size:7px}.primary-button{height:39px;font-size:9px;gap:10px;padding:0 11px}.hero-grid{grid-template-columns:1fr}.hero-main{min-height:280px}.insight-column{grid-template-columns:1fr 1fr;grid-template-rows:auto;gap:9px}.insight-card{min-height:160px}.quick-stats{grid-template-columns:1fr;gap:6px}.quick-stats>div{padding:7px}.metric-strip{grid-template-columns:repeat(3,1fr);row-gap:14px}.metric-progress{grid-column:1/-1;border:0!important;padding:0!important}.metric-strip>div:nth-child(3){border:0}.practice-layout{grid-template-columns:1fr}.review-column{display:grid;grid-template-columns:1fr 1fr}.review-card{min-height:180px}.resource-grid{grid-template-columns:repeat(2,1fr)}.section-title h2{font-size:20px}}
  @media(max-width:560px){.topbar{height:58px}.content{padding:22px 14px 95px}.welcome-row{display:block}.welcome-row h1{font-size:27px}.welcome-row p{font-size:9px}.welcome-actions{margin-top:15px;flex-direction:row-reverse;justify-content:space-between;align-items:center}.edition{font-size:7px}.hero-main{min-height:300px;padding:21px 19px}.hero-copy{margin-top:22px}.hero-copy h2{font-size:31px}.hero-copy p{font-size:9px}.hero-orbit{opacity:.55}.orbit-one{width:210px;height:210px;right:-45px;top:52px}.orbit-two{width:155px;height:155px;right:-17px;top:80px}.hero-core{width:85px;height:85px;right:20px;top:115px;opacity:.78}.hero-core span{font-size:27px}.hero-core small{font-size:5px}.hero-foot{left:19px;right:19px}.insight-column{grid-template-columns:1fr}.quick-stats{grid-template-columns:repeat(3,1fr)}.quick-stats>div{flex-direction:column;align-items:start;gap:6px}.quick-stats small{font-size:6px}.metric-strip{padding:14px 0;gap:10px 0}.metric-strip>div{padding:0 9px}.metric-strip>div:first-child{padding-left:0}.metric-strip strong{font-size:18px}.metric-strip span{font-size:6px;letter-spacing:.8px}.section-title{align-items:start}.section-title p{max-width:280px;font-size:9px;line-height:1.7}.section-side-note{display:none}.subject-grid{gap:6px}.subject-card{height:116px;padding:11px 9px}.subject-top{font-size:6px;letter-spacing:.6px}.subject-top svg{width:14px}.subject-card>strong{font-size:18px;margin-top:18px}.subject-card>small{font-size:5.5px;letter-spacing:.4px}.subject-watermark{font-size:60px;right:3px}.filter-card{padding:15px}.filter-heading h3{font-size:13px}.filter-fields{gap:6px}.filter-fields label>span{font-size:7px}.filter-fields select{font-size:8px;padding-left:6px}.filter-footer{gap:8px}.filter-footer strong{font-size:17px}.filter-footer span{font-size:7px}.start-button{font-size:8px;gap:8px;padding:0 9px}.review-column{gap:7px}.review-card,.bookmark-card{padding:13px}.review-card h3{font-size:11px}.review-card p{font-size:7px}.review-card>strong{font-size:34px}.bookmark-card>strong{font-size:24px}.bookmark-card p{font-size:7px}.resource-grid{gap:7px}.resource-card{min-height:160px;padding:11px}.resource-card h3{font-size:11px}.resource-card p{font-size:7px}.resource-symbol{width:32px;height:32px;margin-top:14px}.resource-card-top{font-size:6px}.resource-card>span:last-child{font-size:7px}.footer{font-size:6px}.footer-brand{font-size:11px}.mobile-dock{position:fixed;z-index:30;bottom:0;left:0;right:0;height:66px;padding-bottom:env(safe-area-inset-bottom);background:#111522;border-top:1px solid #2a3143;display:flex;align-items:center;justify-content:space-around}.mobile-dock a,.mobile-dock button{width:25%;height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:5px;border:0;background:transparent;color:#929db5;font-size:7px}.mobile-dock .selected{color:#b5adff}.quiz-shell{padding:0 15px}.quiz-header{height:60px}.quiz-content{margin:34px auto}.quiz-content h1{font-size:20px}.answer-list button{min-height:55px}.quiz-footer{font-size:6px}.result-shell h1{font-size:28px}}
  @media(max-width:370px){.welcome-row h1{font-size:24px}.hero-copy h2{font-size:27px}.filter-fields{grid-template-columns:1fr 1fr}.filter-fields label:last-child{grid-column:1/-1}.review-column{grid-template-columns:1fr}.review-card{min-height:160px}.resource-card{min-height:170px}}
</style>

<script>
  import { formatStudyCount } from '$lib/study-metrics';
  import { onMount } from 'svelte';
  import {
    ArrowUpRight, ArrowRight, Atom, Bookmark, BookOpen, Check, ChevronDown,
    ChevronLeft, CircleHelp, Clock3, Command, Flame, GraduationCap, Layers3,
    Menu, Moon, Search, Sparkles, Sun, Target, Trophy, X, RotateCcw,
    PanelLeftClose, LibraryBig, ChartNoAxesColumnIncreasing, Zap, Download, Code2
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
  let theme = $state('dark');
  let mobileMenu = $state(false);
  let installPrompt = $state(null);
  let isInstalled = $state(false);
  let installHelp = $state(false);
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
      theme = localStorage.getItem('manabixx-theme') || 'dark';
      document.documentElement.dataset.theme = theme;
      isInstalled = window.matchMedia('(display-mode: standalone)').matches;
      window.addEventListener('beforeinstallprompt', handleInstallAvailable);
      window.addEventListener('appinstalled', handleInstalled);
    } catch (error) {
      loadError = error.message || '読み込みに失敗しました';
    } finally {
      loading = false;
    }
  });

  function handleInstallAvailable(event) { event.preventDefault(); installPrompt = event; }
  function handleInstalled() { isInstalled = true; installPrompt = null; installHelp = false; }
  async function installApp() {
    if (isInstalled) return;
    if (!installPrompt) { installHelp = !installHelp; return; }
    installPrompt.prompt();
    const choice = await installPrompt.userChoice;
    if (choice?.outcome === 'accepted') isInstalled = true;
    installPrompt = null;
  }

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
    if (mode === 'foundation') {
      list = bank.filter(x =>
        (subject === 'all' || x.subject === subject) &&
        (topic === 'all' || x.topic === topic) &&
        (x.level || '基礎') === '基礎' &&
        (!query || (x.prompt || '').toLowerCase().includes(query.toLowerCase()) || (x.topic || '').toLowerCase().includes(query.toLowerCase()))
      );
      list = list.slice(0, 10);
    } else if (amount !== 'all' && mode === 'normal') {
      list = list.slice(0, Number(amount));
    }
    if (!list.length) { toast.error('この条件に合う問題がありません'); return; }
    pool = list;
    index = 0;
    selected = null;
    score = 0;
    screen = 'quiz';
    mobileMenu = false;
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
  function choose(i) {
    if (selected !== null) return;
    selected = i;
    const item = pool[index];
    const ok = i === item.correct;
    answered += 1;
    if (ok) {
      score += 1;
      correctTotal += 1;
      wrongIds = wrongIds.filter(id => id !== item.id);
    } else if (!wrongIds.includes(item.id)) {
      wrongIds = [...wrongIds, item.id];
    }
    persist();
  }
  function next() {
    if (index === pool.length - 1) { screen = 'result'; return; }
    index += 1;
    selected = null;
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
  function resetFilters() {
    subject = 'all'; topic = 'all'; level = 'all'; amount = '10'; query = '';
  }
  function backHome() {
    screen = 'home';
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
</script>

<svelte:head>
  <title>MANABIXX — 学習アプリ</title>
  <meta name="description" content="自分のペースで学び、理解を積み重ねる学習スペース。"/>
  <meta name="theme-color" content="#090b0a"/>
  <link rel="manifest" href="/manifest.webmanifest"/>
  <link rel="icon" href="/favicon.svg?v=20261113" type="image/svg+xml"/><link rel="apple-touch-icon" href="/favicon.svg?v=20261113"/>
</svelte:head>

{#if screen === 'home'}
  <div class="study-app">
    <aside class:menu-open={mobileMenu} class="rail">
      <a href="/" class="mark" aria-label="MANABIXX ホーム"><span>M</span><i></i></a>
      <div class="rail-links">
        <button class="rail-link selected" aria-label="ホーム"><Layers3 size={19}/></button>
        <button class="rail-link" aria-label="問題演習" onclick={() => document.getElementById('question-bank')?.scrollIntoView({behavior:'smooth'})}><Target size={19}/></button>
        <a class="rail-link" href="/library/" aria-label="教材ライブラリ"><LibraryBig size={19}/></a>
        <a class="rail-link" href="/summary/" aria-label="要点まとめ"><BookOpen size={19}/></a>
        <a class="rail-link" href="/exam/" aria-label="入試問題"><GraduationCap size={19}/></a>
        <a class="rail-link" href="/code-lab/" aria-label="プログラミングラボ"><Code2 size={19}/></a>
      </div>
      <div class="rail-bottom">
        <button class="rail-link" onclick={toggleTheme} aria-label="テーマ切替">{#if theme === 'light'}<Moon size={19}/>{:else}<Sun size={19}/>{/if}</button>
        <div class="rail-avatar">S</div>
      </div>
    </aside>

    <main class="workspace">
      <header class="topline">
        <button class="mobile-toggle" onclick={() => mobileMenu = !mobileMenu} aria-label="メニュー">{#if mobileMenu}<X size={20}/>{:else}<Menu size={20}/>{/if}</button>
        <div class="crumb"><span>MANABIXX</span><b>/</b> HOME</div>
        <div class="topline-right">
          <span class="live-dot">APP WORKSPACE</span>
          <button class="install-app" onclick={installApp} aria-label="アプリをインストール">{#if isInstalled}<Check size={15}/><span>インストール済み</span>{:else}<Download size={15}/><span>アプリ化</span>{/if}</button>
          <button class="theme-toggle" onclick={toggleTheme} aria-label="テーマ切替">{#if theme === 'light'}<Moon size={17}/>{:else}<Sun size={17}/>{/if}</button>
        </div>
      </header>

      <div class="page-wrap">
        <section class="intro">
          <div class="intro-copy">
            <div class="eyebrow"><span class="eyebrow-line"></span> YOUR PERSONAL LEARNING SPACE</div>
            <h1>学びを、<br/><em>積み上げる。</em></h1>
            <p>今日の一問が、明日の自信になる。<br/>自分のペースで、ひとつずつ。</p>
            <button class="intro-cta" onclick={() => document.getElementById('question-bank')?.scrollIntoView({behavior:'smooth'})}>学習をはじめる <ArrowUpRight size={17}/></button>
          </div>
          <div class="intro-art" aria-hidden="true">
            <div class="art-ring ring-a"></div><div class="art-ring ring-b"></div>
            <div class="art-center"><span>MX</span><small>KEEP<br/>LEARNING</small></div>
            <div class="art-tag tag-one"><Zap size={13}/> SMALL STEPS</div>
            <div class="art-tag tag-two"><span></span> PROGRESS IS PROGRESS</div>
            <div class="art-cross cross-one">✳</div><div class="art-cross cross-two">✳</div>
          </div>
          <div class="intro-index"><span>01</span><i></i><span>04</span></div>
        </section>

        <section class="stats-row">
          <div class="stats-lead"><span class="eyebrow">YOUR ACTIVITY</span><h2>学習の記録</h2></div>
          <div class="stat"><span>ANSWERED</span><strong>{formatStudyCount(answered)}<small>問</small></strong><i>累計回答数</i></div>
          <div class="stat"><span>ACCURACY</span><strong>{accuracy}<small>%</small></strong><i>累計正答率</i></div>
          <div class="stat"><span>REVIEW</span><strong>{wrongIds.length + bookmarks.length}<small>件</small></strong><i>復習リスト</i></div>
          <div class="stat-progress">
            <div class="progress-head"><span>QUESTION BANK</span><b>{bank.length.toLocaleString('ja-JP')}問</b></div>
            <div class="progress-track"><i style="width:{completion}%"></i></div>
            <small>学習記録の蓄積率 {completion}%</small>
          </div>
        </section>

        <section class="learning-hub" aria-label="学習機能">
          <div class="hub-heading"><span class="eyebrow">START HERE / LEARNING</span><h2>今日取り組む学習を選ぶ。</h2><p>目的に合わせて、2つの学習機能からスタート。</p></div>
          <div class="learning-feature-grid">
            <a class="learning-feature foundation-feature" href="#question-bank">
              <span class="feature-kicker">A / FOUNDATION</span>
              <div class="feature-symbol"><BookOpen size={25}/></div>
              <div class="feature-copy"><h3>基礎網羅問題</h3><p>重要な基礎を一問ずつ。知識の抜けをなくし、土台を固める。</p></div>
              <span class="feature-action">基礎網羅問題を解く <ArrowUpRight size={17}/></span>
              <span class="feature-watermark">A</span>
            </a>
            <a class="learning-feature entrance-feature" href="/exam/">
              <span class="feature-kicker">B / PUBLIC HIGH SCHOOL EXAM</span>
              <div class="feature-symbol"><GraduationCap size={26}/></div>
              <div class="feature-copy"><h3>公立高校入試問題</h3><p>実際の公立高校入試形式で演習。出題傾向と実戦力を身につける。</p></div>
              <span class="feature-action">入試問題に挑戦 <ArrowUpRight size={17}/></span>
              <span class="feature-watermark">B</span>
            </a>
          </div>
        </section>

        <section class="section-block" id="question-bank">
          <div class="section-heading">
            <div><span class="eyebrow">01 / FOUNDATION PRACTICE</span><h2>基礎網羅問題</h2><p>教科と分野を選んで、基礎から着実に理解を積み上げよう。</p></div>
            <span class="section-count">PICK YOUR FOCUS <ArrowUpRight size={15}/></span>
          </div>
          {#if loading}
            <div class="state-panel"><div class="spinner"></div><span>問題データを読み込んでいます</span></div>
          {:else if loadError}
            <div class="state-panel error-state"><CircleHelp size={22}/><span>{loadError}</span></div>
          {:else}
            <div class="training-layout">
              <div class="training-main">
                <div class="subject-picks">
                  <button class:active={subject === 'all'} class="subject-pick all-pick" onclick={() => {subject='all';topic='all';}}>
                    <div class="pick-top"><span>ALL SUBJECTS</span><ArrowUpRight size={16}/></div><div class="pick-name">理科 <i>+</i> 社会</div><div class="pick-foot">{(scienceCount + socialCount).toLocaleString('ja-JP')} QUESTIONS</div><div class="pick-index">01</div>
                  </button>
                  <button class:active={subject === 'science'} class="subject-pick science-pick" onclick={() => {subject='science';topic='all';}}>
                    <div class="pick-top"><span>SCIENCE</span><Atom size={18}/></div><div class="pick-name">理科</div><div class="pick-foot">{scienceCount.toLocaleString('ja-JP')} QUESTIONS</div><div class="pick-index">02</div>
                  </button>
                  <button class:active={subject === 'social'} class="subject-pick social-pick" onclick={() => {subject='social';topic='all';}}>
                    <div class="pick-top"><span>SOCIAL STUDIES</span><GraduationCap size={18}/></div><div class="pick-name">社会</div><div class="pick-foot">{socialCount.toLocaleString('ja-JP')} QUESTIONS</div><div class="pick-index">03</div>
                  </button>
                </div>
                <div class="filter-panel">
                  <div class="filter-top"><div><span class="eyebrow">MAKE IT YOURS</span><h3>演習をカスタマイズ</h3></div><button class="clear-filter" onclick={resetFilters}>リセット <RotateCcw size={13}/></button></div>
                  <label class="search-box"><Search size={17}/><input bind:value={query} placeholder="問題文・単元から検索"/><kbd>⌕</kbd></label>
                  <div class="filter-controls">
                    <label><span>分野</span><div class="select-shell"><select bind:value={topic}><option value="all">すべての分野</option>{#each topics as t}<option value={t}>{t}</option>{/each}</select><ChevronDown size={15}/></div></label>
                    <label><span>レベル</span><div class="select-shell"><select bind:value={level}><option value="all">すべて</option><option value="基礎">基礎</option><option value="標準">標準</option><option value="応用">応用</option></select><ChevronDown size={15}/></div></label>
                    <label><span>問題数</span><div class="select-shell"><select bind:value={amount}><option value="10">10問</option><option value="20">20問</option><option value="30">30問</option><option value="50">50問</option><option value="all">全問</option></select><ChevronDown size={15}/></div></label>
                  </div>
                  <div class="filter-bottom"><div><strong>{filtered.length.toLocaleString('ja-JP')}</strong><span>問が見つかりました</span></div><button class="launch-button" onclick={() => begin()}>演習をスタート <ArrowUpRight size={17}/></button></div>
                </div>
              </div>
              <aside class="training-side">
                <div class="review-tile">
                  <div class="tile-top"><span>REVIEW MODE</span><RotateCcw size={17}/></div>
                  <div class="tile-number">{wrongIds.length.toString().padStart(2,'0')}</div>
                  <h3>苦手を、得意に。</h3><p>間違えた問題だけを集めて、もう一度チャレンジ。</p>
                  <button onclick={() => begin('wrong')}>間違えた問題を解く <ArrowRight size={15}/></button>
                </div>
                <div class="saved-tile">
                  <div class="tile-top"><span>BOOKMARKS</span><Bookmark size={16}/></div>
                  <div class="saved-row"><strong>{bookmarks.length.toString().padStart(2,'0')}</strong><span>保存した問題</span></div>
                  <button onclick={() => begin('bookmarks')}>保存リストを開く <ArrowUpRight size={15}/></button>
                </div>
                <div class="foundation-tile">
                  <div class="tile-top"><span>FOUNDATION MODE</span><Sparkles size={16}/></div>
                  <div class="foundation-copy"><strong>下積みモード</strong><span>基礎10問を集中して積み上げる</span></div>
                  <button onclick={() => begin('foundation')}>基礎から取り組む <ArrowUpRight size={15}/></button>
                </div>
              </aside>
            </div>
          {/if}
        </section>
        {#if installHelp && !isInstalled}<div class="install-help"><div><strong>Studyをアプリとして使う</strong><p>ブラウザのメニューから「ホーム画面に追加」または「アプリをインストール」を選ぶと、次回からアプリのように起動できます。</p></div><button onclick={() => installHelp = false} aria-label="閉じる"><X size={16}/></button></div>{/if}

        <section class="section-block resources-block">
          <div class="section-heading compact-heading"><div><span class="eyebrow">02 / APP LIBRARY</span><h2>学習アプリ</h2></div><a href="/library/">すべての教材を見る <ArrowUpRight size={15}/></a></div>
          <div class="resource-grid">
            <a href="/summary/" class="resource-card resource-summary"><span class="resource-no">A / 01</span><div class="resource-icon"><BookOpen size={23}/></div><h3>要点まとめ</h3><p>重要事項を整理して、知識をつなげる。</p><span class="resource-link">EXPLORE <ArrowUpRight size={15}/></span></a>
            <div class="resource-card resource-exam"><a href="/exam/" class="resource-main"><span class="resource-no">B / 02</span><div class="resource-icon"><GraduationCap size={23}/></div><h3>公立入試問題</h3><p>実際の入試形式で、実戦力を磨く。</p><span class="resource-link">PRACTICE <ArrowUpRight size={15}/></span></a><a class="resource-extra" href="/legacy/private.html" rel="external"><span>⌘</span><b>秘密モード</b><small>CREATOR ONLY</small><ArrowUpRight size={14}/></a></div>
            <div class="resource-card resource-mock"><a href="/mock-exam/" class="resource-main"><span class="resource-no">C / 03</span><div class="resource-icon"><ChartNoAxesColumnIncreasing size={23}/></div><h3>模試・予想問題</h3><p>今の実力を確かめ、次の課題を見つける。</p><span class="resource-link">CHALLENGE <ArrowUpRight size={15}/></span></a><a class="resource-extra" href="/legacy/shitadumi/" rel="external"><span>↗</span><b>下積みモード</b><small>FOUNDATION FIRST</small><ArrowUpRight size={14}/></a></div>
            <a href="/kosen/" class="resource-card resource-kosen"><span class="resource-no">SPECIAL / EXAM TRACK</span><div class="resource-icon"><GraduationCap size={23}/></div><h3>高専専用モード</h3><p>数学・理科・英語を分野別に演習する。</p><span class="resource-link">START PRACTICE <ArrowUpRight size={15}/></span></a>
            <a href="/library/" class="resource-card resource-library"><span class="resource-no">D / 04 · REFERENCE</span><div class="resource-icon"><LibraryBig size={23}/></div><h3>学習ライブラリ</h3><p>単元・用語・資料をまとめて検索。</p><span class="resource-link">OPEN APP <ArrowUpRight size={15}/></span></a>
            <a href="/motivation/" class="resource-card resource-motivation"><span class="resource-no">E / 05 · MINDSET</span><div class="resource-icon"><Sparkles size={23}/></div><h3>モチベーション</h3><p>気持ちを切り替えて、次の一歩へ。</p><span class="resource-link">GET INSPIRED <ArrowUpRight size={15}/></span></a>
            <a href="/workspace/" class="resource-card resource-workspace"><span class="resource-no">G / 07 · PERSONAL TOOLS</span><div class="resource-icon"><Target size={23}/></div><h3>学習ワークスペース</h3><p>学習計画・集中タイマー・暗記カード・メモを一か所に。</p><span class="resource-link">OPEN WORKSPACE <ArrowUpRight size={15}/></span></a>
            <a href="/releases/" class="resource-card resource-updates"><span class="resource-no">F / 06 · WHAT'S NEW</span><div class="resource-icon"><Clock3 size={23}/></div><h3>アップデート</h3><p>新機能や教材の追加情報をチェック。</p><span class="resource-link">VIEW UPDATES <ArrowUpRight size={15}/></span></a>
          </div>
        </section>

        <footer class="site-footer"><a href="/" class="footer-logo">MANABIXX<span>.</span></a><span>MAKE PROGRESS, YOUR WAY.</span><a href="/releases/">更新履歴 <ArrowUpRight size={13}/></a></footer>
      </div>
    </main>
    <nav class="mobile-nav"><a class="on" href="/"><Layers3 size={18}/><span>ホーム</span></a><button onclick={() => document.getElementById('question-bank')?.scrollIntoView({behavior:'smooth'})}><Target size={18}/><span>演習</span></button><a href="/library/"><LibraryBig size={18}/><span>教材</span></a><button onclick={toggleTheme}>{#if theme === 'light'}<Moon size={18}/>{:else}<Sun size={18}/>{/if}<span>表示</span></button></nav>
  </div>
{:else if screen === 'quiz'}
  <main class="focus-screen">
    <header class="focus-header"><button class="exit-focus" onclick={backHome}><ChevronLeft size={18}/> 終了</button><a href="/" class="focus-brand">MANABIXX<span>.</span> <small>STUDY MODE</small></a><div class="focus-number">{String(index + 1).padStart(2,'0')} <i>/ {String(pool.length).padStart(2,'0')}</i></div></header>
    <div class="focus-progress"><i style="width:{(index + 1) / pool.length * 100}%"></i></div>
    {#if q}
      <section class="focus-content">
        <div class="focus-meta"><span>{q.subject === 'science' ? 'SCIENCE / 理科' : 'SOCIAL / 社会'}</span><span>{q.topic}</span><span>{q.level || '基礎'}</span></div>
        <div class="focus-label">QUESTION <b>{String(index + 1).padStart(2,'0')}</b></div>
        <h1>{q.prompt}</h1>
        <div class="focus-answers">{#each q.options as option, i}<button class:chosen-correct={selected !== null && i === q.correct} class:chosen-wrong={selected === i && selected !== q.correct} class:answer-muted={selected !== null && i !== selected && i !== q.correct} disabled={selected !== null} onclick={() => choose(i)}><span>{String(i + 1).padStart(2,'0')}</span><b>{option}</b>{#if selected !== null && i === q.correct}<Check size={19}/>{/if}</button>{/each}</div>
        {#if selected !== null}<div class:good={selected === q.correct} class:bad={selected !== q.correct} class="answer-explain"><div class="explain-heading">{selected === q.correct ? '正解。いい調子。' : 'ここを確認しよう。'}</div><p>{q.explanation}</p>{#if q.sourceNote}<small>{q.sourceNote}</small>{/if}</div>{/if}
        <div class="focus-actions"><button class="bookmark-action" onclick={toggleBookmark}><Bookmark size={16}/>{bookmarks.includes(q.id) ? '保存済み' : 'あとで復習'}</button><button class="next-action" disabled={selected === null} onclick={next}>{index === pool.length - 1 ? '結果を見る' : '次の問題へ'} <ArrowRight size={17}/></button></div>
      </section>
    {/if}
    <footer class="focus-footer"><span>ONE QUESTION AT A TIME.</span><span>MANABIXX / STUDY</span></footer>
  </main>
{:else}
  <main class="finish-screen"><div class="finish-symbol"><Trophy size={31}/></div><span class="eyebrow">SESSION COMPLETE</span><h1>よく取り組んだ。</h1><p>今日の積み重ねを、次の一歩につなげよう。</p><div class="finish-score"><strong>{score}<small> / {pool.length}</small></strong><span>正解数</span><div class="finish-track"><i style="width:{pool.length ? score / pool.length * 100 : 0}%"></i></div><b>正答率 {pool.length ? Math.round(score / pool.length * 100) : 0}%</b></div><button class="next-action" onclick={() => {screen='home';begin();}}>もう一度演習する <ArrowRight size={17}/></button><button class="finish-back" onclick={backHome}>ホームに戻る</button></main>
{/if}

<style>
  :global(body){margin:0;background:#f4f4ef;color:#191b18;font-family:'DM Sans','Noto Sans JP',sans-serif}
  :global(:root[data-theme='dark']) .study-app{--paper:#151713;--paper-2:#1e211c;--ink:#f1f2e9;--muted:#a2a797;--line:#34382f;--acid:#d5ff4f;--acid-ink:#1c2110;--tile:#20231e;--soft:#292d25}
  .study-app{--paper:#f4f4ef;--paper-2:#eaece4;--ink:#191b18;--muted:#777d70;--line:#dfe2d8;--acid:#c9f344;--acid-ink:#222b10;--tile:#fff;--soft:#edf0e7;min-height:100vh;background:var(--paper);color:var(--ink);transition:background .2s,color .2s}
  .rail{position:fixed;inset:0 auto 0 0;width:76px;background:#191c17;color:#f4f5ed;display:flex;align-items:center;flex-direction:column;padding:22px 0 18px;z-index:30}
  .mark{width:39px;height:39px;border:1px solid #59604e;border-radius:12px;display:grid;place-items:center;position:relative;color:#d6ff55;font-size:18px;font-weight:900;letter-spacing:-2px}.mark i{position:absolute;width:5px;height:5px;border-radius:50%;background:#d6ff55;right:7px;top:7px}
  .rail-links{display:flex;flex-direction:column;gap:12px;margin-top:66px}.rail-link{width:42px;height:42px;border:0;border-radius:12px;background:transparent;color:#8e9583;display:grid;place-items:center;transition:.18s}.rail-link:hover,.rail-link.selected{background:#d4fb4d;color:#202519}.rail-bottom{margin-top:auto;display:flex;flex-direction:column;align-items:center;gap:17px}.rail-avatar{width:32px;height:32px;border-radius:50%;background:#343a2d;color:#d8ff58;display:grid;place-items:center;font-size:11px;font-weight:800}
  .workspace{margin-left:76px;min-height:100vh}.topline{height:64px;border-bottom:1px solid var(--line);display:flex;align-items:center;justify-content:space-between;padding:0 clamp(22px,5vw,76px);background:var(--paper)}.crumb{font-size:10px;font-weight:800;letter-spacing:1.5px}.crumb span{color:var(--muted)}.crumb b{color:#b3b8aa;margin:0 10px}.topline-right{display:flex;align-items:center;gap:20px}.live-dot{font-size:8px;letter-spacing:1.7px;font-weight:800;color:var(--muted)}.live-dot:before{content:'';display:inline-block;width:6px;height:6px;border-radius:50%;background:#a9d735;margin:0 8px 1px 0}.theme-toggle{width:34px;height:34px;border:1px solid var(--line);border-radius:50%;background:transparent;color:var(--ink);display:grid;place-items:center}.mobile-toggle{display:none}
  .page-wrap{max-width:1440px;margin:auto;padding:0 clamp(22px,5vw,76px) 26px}.intro{min-height:370px;background:#20251d;color:#f4f5ed;margin-top:26px;border-radius:5px;position:relative;overflow:hidden;padding:53px 6.5%;display:flex;align-items:center;justify-content:space-between}.intro-copy{position:relative;z-index:2}.eyebrow{font-size:9px;letter-spacing:2px;font-weight:800;color:#8d9a7a;display:block}.eyebrow-line{display:inline-block;width:24px;height:2px;background:#d4fa4e;vertical-align:middle;margin-right:9px}.intro h1{font-size:clamp(44px,5.2vw,72px);line-height:1.16;letter-spacing:-3.5px;margin:24px 0 17px;font-weight:700}.intro h1 em{font-style:normal;color:#d3fb4c}.intro p{font-size:12px;line-height:2;color:#aeb5a4;margin:0 0 25px}.intro-cta{height:45px;padding:0 18px;background:#d2fa4b;border:0;color:#222719;border-radius:3px;display:flex;align-items:center;gap:30px;font-size:11px;font-weight:800}.intro-art{position:absolute;right:8%;top:50%;transform:translateY(-50%);width:370px;height:310px;display:grid;place-items:center}.art-ring{position:absolute;width:280px;height:280px;border:1px solid #535d47;border-radius:50%}.ring-b{width:210px;height:210px;border-style:dashed;border-color:#69745a;animation:rotate 38s linear infinite}.art-center{width:154px;height:154px;border-radius:50%;background:#d3fa4c;color:#20251d;display:flex;flex-direction:column;align-items:center;justify-content:center;transform:rotate(-9deg);box-shadow:0 0 0 16px #d3fa4c13,0 0 0 42px #d3fa4c09}.art-center span{font-size:52px;font-weight:900;letter-spacing:-5px}.art-center small{font-size:7px;letter-spacing:2px;font-weight:900;text-align:center;line-height:1.5}.art-tag{position:absolute;background:#30382a;color:#e1e8d7;padding:10px 13px;border:1px solid #4b5740;font-size:8px;font-weight:800;letter-spacing:1px;display:flex;align-items:center;gap:7px}.tag-one{top:36px;left:6px}.tag-one :global(svg){color:#d3fa4c}.tag-two{right:-6px;bottom:35px}.tag-two span{width:6px;height:6px;background:#d3fa4c;border-radius:50%}.art-cross{position:absolute;color:#d3fa4c;font-size:24px}.cross-one{right:38px;top:25px}.cross-two{left:35px;bottom:24px;font-size:15px}.intro-index{position:absolute;bottom:25px;right:31px;display:flex;align-items:center;gap:10px;font-size:9px;color:#8d9583}.intro-index span:first-child{color:#d3fa4c}.intro-index i{width:40px;height:1px;background:#59624e}
  .stats-row{display:grid;grid-template-columns:1.15fr repeat(3,.8fr) 1.4fr;align-items:center;border-bottom:1px solid var(--line);padding:29px 0 30px;gap:20px}.stats-lead h2{font-size:17px;margin:6px 0 0;letter-spacing:-.5px}.stats-lead .eyebrow{color:var(--muted)}.stat{border-left:1px solid var(--line);padding-left:20px}.stat>span,.progress-head span{display:block;font-size:8px;letter-spacing:1.5px;color:var(--muted);font-weight:800}.stat strong{display:block;font-size:27px;letter-spacing:-1.5px;margin:5px 0 0}.stat strong small{font-size:11px;margin-left:4px;color:var(--muted)}.stat>i{font-style:normal;font-size:9px;color:var(--muted)}.stat-progress{border-left:1px solid var(--line);padding-left:20px}.progress-head{display:flex;justify-content:space-between;align-items:center}.progress-head b{font-size:10px}.progress-track{height:5px;background:var(--line);margin:13px 0 8px;border-radius:5px;overflow:hidden}.progress-track i{display:block;height:100%;background:#a9d735}.stat-progress>small{font-size:8px;color:var(--muted)}
  .section-block{padding-top:52px}.section-heading{display:flex;align-items:end;justify-content:space-between;margin-bottom:22px}.section-heading .eyebrow{color:#879079}.section-heading h2{font-size:25px;letter-spacing:-1px;margin:7px 0 5px}.section-heading p{font-size:11px;color:var(--muted);margin:0}.section-count{display:flex;align-items:center;gap:9px;font-size:8px;letter-spacing:1.4px;font-weight:800;color:var(--muted);padding-bottom:5px}.training-layout{display:grid;grid-template-columns:minmax(0,1fr) 270px;gap:15px}.training-main{min-width:0}.subject-picks{display:grid;grid-template-columns:repeat(3,1fr);gap:10px}.subject-pick{height:150px;position:relative;overflow:hidden;border:1px solid var(--line);border-radius:4px;text-align:left;padding:16px 17px;background:var(--tile);color:var(--ink);transition:transform .18s,border-color .18s}.subject-pick:hover{transform:translateY(-3px)}.subject-pick.active{border:1.5px solid #9cbd36;box-shadow:inset 0 0 0 1px #9cbd36}.pick-top{display:flex;justify-content:space-between;align-items:center;font-size:8px;letter-spacing:1.3px;font-weight:800;color:var(--muted)}.pick-top :global(svg){color:#8c9a77}.pick-name{font-size:26px;font-weight:800;letter-spacing:-1px;margin-top:18px}.pick-name i{font-style:normal;color:#a9d735;margin:0 3px}.pick-foot{font-size:8px;letter-spacing:1px;color:var(--muted);margin-top:6px}.pick-index{position:absolute;right:10px;bottom:-18px;font-size:75px;font-weight:900;letter-spacing:-8px;color:var(--soft);line-height:1}.science-pick{background:#eaf0e3;color:#20271b}.social-pick{background:#e8ece9;color:#20271b}.science-pick .pick-top,.social-pick .pick-top,.science-pick .pick-foot,.social-pick .pick-foot{color:#66715e}.science-pick .pick-index,.social-pick .pick-index{color:#dce5d4}.filter-panel{margin-top:12px;padding:22px;background:var(--tile);border:1px solid var(--line);border-radius:4px}.filter-top{display:flex;justify-content:space-between;align-items:start}.filter-top .eyebrow{color:var(--muted)}.filter-top h3{font-size:15px;margin:5px 0 0}.clear-filter{display:flex;align-items:center;gap:6px;border:0;background:none;color:var(--muted);font-size:9px}.search-box{height:43px;margin-top:19px;border:1px solid var(--line);display:flex;align-items:center;gap:10px;padding:0 12px;color:var(--muted)}.search-box input{min-width:0;flex:1;border:0;outline:0;background:transparent;color:var(--ink);font-size:11px}.search-box kbd{font-size:11px;color:var(--muted);border:1px solid var(--line);padding:2px 6px}.filter-controls{display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px;margin-top:16px}.filter-controls label>span{display:block;font-size:9px;color:var(--muted);font-weight:700;margin-bottom:7px}.select-shell{position:relative}.select-shell select{appearance:none;width:100%;height:39px;border:1px solid var(--line);background:var(--paper);color:var(--ink);border-radius:2px;padding:0 31px 0 10px;font-size:10px}.select-shell :global(svg){position:absolute;right:10px;top:12px;color:var(--muted);pointer-events:none}.filter-bottom{display:flex;justify-content:space-between;align-items:center;border-top:1px solid var(--line);margin-top:18px;padding-top:16px}.filter-bottom>div{display:flex;align-items:baseline;gap:7px}.filter-bottom strong{font-size:19px}.filter-bottom span{font-size:9px;color:var(--muted)}.launch-button{height:42px;background:#cffa4d;border:0;color:#1e2516;padding:0 17px;display:flex;align-items:center;gap:24px;font-size:10px;font-weight:900;border-radius:2px}.training-side{display:flex;flex-direction:column;gap:12px}.review-tile{background:#20251d;color:#f1f3e9;padding:19px 18px;min-height:210px;display:flex;flex-direction:column}.tile-top{display:flex;justify-content:space-between;align-items:center;font-size:8px;letter-spacing:1.5px;font-weight:800;color:#9ba58e}.tile-top :global(svg){color:#d1f94d}.tile-number{font-size:48px;line-height:1;font-weight:800;letter-spacing:-3px;color:#d3fa4c;margin-top:23px}.review-tile h3{font-size:15px;margin:7px 0 5px}.review-tile p{font-size:9px;line-height:1.7;color:#aab29e;margin:0 0 16px}.review-tile button{margin-top:auto;display:flex;justify-content:space-between;align-items:center;border:0;border-top:1px solid #424a39;padding:12px 0 0;background:none;color:#d3fa4c;font-size:9px;font-weight:800}.saved-tile{border:1px solid var(--line);background:var(--tile);padding:17px 18px}.saved-tile .tile-top{color:var(--muted)}.saved-tile .tile-top :global(svg){color:#8f9d78}.saved-row{display:flex;align-items:baseline;gap:10px;margin:13px 0}.saved-row strong{font-size:30px;letter-spacing:-1px}.saved-row span{font-size:9px;color:var(--muted)}.saved-tile button{display:flex;align-items:center;justify-content:space-between;width:100%;border:0;border-top:1px solid var(--line);padding:11px 0 0;background:none;color:var(--ink);font-size:9px;font-weight:800}
  .foundation-tile{background:#20251d;color:#f1f3e9;padding:17px 18px;border:1px solid #3b4632;border-radius:4px;display:flex;flex-direction:column;gap:12px}.foundation-tile .tile-top{color:#aeb99c}.foundation-tile .tile-top :global(svg){color:#d3fa4c}.foundation-copy{display:grid;gap:5px}.foundation-copy strong{font-size:17px;color:#d3fa4c}.foundation-copy span{font-size:9px;color:#c0c9b4}.foundation-tile button{display:flex;align-items:center;justify-content:space-between;border:0;border-top:1px solid #46503b;padding:11px 0 0;background:none;color:#e4f0d1;font-size:9px;font-weight:850}
  .learning-hub{padding:35px 0 8px}.hub-heading{margin-bottom:17px}.hub-heading h2{font-size:23px;letter-spacing:-.8px;margin:7px 0 4px}.hub-heading p{font-size:10px;color:var(--muted);margin:0}.learning-feature-grid{display:grid;grid-template-columns:1fr 1fr;gap:13px}.learning-feature{min-height:205px;padding:22px 24px;position:relative;overflow:hidden;border:1px solid var(--line);border-radius:17px;display:grid;grid-template-columns:52px 1fr;grid-template-rows:auto 1fr auto;column-gap:15px;color:var(--ink);text-decoration:none;transition:transform .2s,border-color .2s}.learning-feature:hover{transform:translateY(-3px);border-color:#a9c64b}.foundation-feature{background:linear-gradient(125deg,#e9f1dd,#f8f9f3)}.entrance-feature{background:linear-gradient(125deg,#20271e,#303a2b);color:#f1f4e9;border-color:#46533b}.feature-kicker{grid-column:1/-1;font-size:8px;letter-spacing:1.5px;font-weight:900;color:#68745a}.entrance-feature .feature-kicker{color:#bdce9c}.feature-symbol{grid-column:1;grid-row:2;align-self:center;width:48px;height:48px;border-radius:14px;display:grid;place-items:center;background:#dce8cf;color:#40552c}.entrance-feature .feature-symbol{background:#3a4930;color:#d6fa55}.feature-copy{grid-column:2;grid-row:2;align-self:center;position:relative;z-index:1}.feature-copy h3{font-size:clamp(19px,2.2vw,25px);letter-spacing:-1px;margin:0 0 7px}.feature-copy p{max-width:390px;font-size:10px;line-height:1.9;color:#68715f;margin:0}.entrance-feature .feature-copy p{color:#c0c9b6}.feature-action{grid-column:1/-1;display:flex;align-items:center;justify-content:space-between;border-top:1px solid #cbd6bf;padding-top:13px;margin-top:16px;font-size:10px;font-weight:900;color:#42572e;position:relative;z-index:1}.entrance-feature .feature-action{border-color:#536046;color:#d6fa55}.feature-watermark{position:absolute;right:12px;bottom:-48px;font-size:190px;line-height:1;font-weight:950;letter-spacing:-15px;color:#526b3b;opacity:.07;pointer-events:none}.entrance-feature .feature-watermark{color:#d6fa55;opacity:.06}
  .resources-block{padding-top:57px}.compact-heading{align-items:center}.compact-heading h2{margin-bottom:0}.compact-heading>a{display:flex;align-items:center;gap:8px;font-size:9px;font-weight:800;color:var(--muted)}.resource-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:11px}.resource-workspace{background:#19251a;color:#edf2e7;border-color:#42533a}.resource-workspace .resource-icon{background:#2a3a27;color:#d4fa4c}.resource-workspace h3{color:#edf2e7}.resource-workspace p{color:#b0bca8}.resource-card{min-height:190px;padding:17px;background:var(--tile);border:1px solid var(--line);position:relative;display:flex;flex-direction:column;transition:transform .18s,border-color .18s}.resource-card:hover{transform:translateY(-4px);border-color:#a9c64b}.resource-no{font-size:8px;letter-spacing:1.4px;color:var(--muted);font-weight:800}.resource-icon{margin-top:18px;width:39px;height:39px;background:var(--soft);display:grid;place-items:center;color:var(--ink)}.resource-card h3{font-size:14px;margin:12px 0 5px}.resource-card p{font-size:9px;line-height:1.7;color:var(--muted);margin:0}.resource-link{display:flex;align-items:center;justify-content:space-between;margin-top:auto;padding-top:15px;font-size:8px;letter-spacing:1.3px;font-weight:900;color:#83935e}.resource-exam{background:#e8ece5;color:#20251d}.resource-exam .resource-icon{background:#d8e0d0}.resource-mock{background:#eff0e7;color:#20251d}.resource-mock .resource-icon{background:#e0e5d2}.resource-main{min-height:148px;display:flex;flex-direction:column;color:#20251d}.resource-main h3{color:#20251d}.resource-main p{color:#4f584b}.resource-main .resource-no{color:#586451}.resource-main .resource-link{color:#4c6329}.resource-extra{display:flex;align-items:center;gap:8px;margin-top:auto;padding:10px 10px 0;border-top:1px solid rgba(32,37,29,.18);color:#20251d;text-decoration:none}.resource-extra>span{width:24px;height:24px;border-radius:7px;background:#d3dfc8;display:grid;place-items:center;font-size:14px;font-weight:900}.resource-extra b{font-size:10px}.resource-extra small{margin-left:auto;font-size:7px;letter-spacing:.8px;color:#586451}.resource-extra :global(svg){color:#4c6329}.resource-extra:hover b{text-decoration:underline;text-underline-offset:3px}.resource-library .resource-icon{background:#f0f1e8}.site-footer{margin-top:62px;border-top:1px solid var(--line);padding:20px 0;display:flex;align-items:center;justify-content:space-between;font-size:8px;letter-spacing:1.2px;color:var(--muted)}.footer-logo{font-size:13px;font-weight:900;letter-spacing:-.4px;color:var(--ink)}.footer-logo span,.focus-brand span{color:#9fc735}.site-footer>a:last-child{display:flex;align-items:center;gap:5px;color:var(--ink);font-weight:800}
  .state-panel{min-height:170px;border:1px dashed var(--line);display:flex;align-items:center;justify-content:center;gap:12px;color:var(--muted);font-size:11px}.error-state{color:#c55}.spinner{width:22px;height:22px;border:2px solid var(--line);border-top-color:#a9d735;border-radius:50%;animation:spin .8s linear infinite}@keyframes spin{to{transform:rotate(360deg)}}@keyframes rotate{to{transform:rotate(360deg)}}
  .install-app{display:flex;align-items:center;gap:7px;height:33px;padding:0 11px;border:1px solid var(--line);border-radius:999px;background:var(--tile);color:var(--ink);font-size:9px;font-weight:800;white-space:nowrap}.install-app :global(svg){color:var(--acid)}
  .install-help{display:flex;justify-content:space-between;gap:15px;align-items:flex-start;margin-top:14px;padding:17px 19px;border:1px solid var(--line);border-radius:14px;background:var(--tile);color:var(--ink)}.install-help strong{font-size:12px}.install-help p{font-size:10px;line-height:1.8;color:var(--muted);margin:5px 0 0}.install-help button{border:0;background:transparent;color:var(--muted)}
  .resource-card{border-radius:16px;overflow:hidden}.resource-icon{border-radius:13px}.resource-summary .resource-icon,.resource-library .resource-icon{background:var(--soft);color:var(--ink)}.resource-motivation{background:#20231e;color:#f1f2e9;border-color:#34382f}.resource-motivation .resource-icon{background:#303725;color:#d4fa4c}.resource-motivation .resource-no,.resource-motivation p{color:#a2a797}.resource-motivation .resource-link{color:#d4fa4c}.resource-updates{background:var(--tile);color:var(--ink)}.resource-updates .resource-icon{background:var(--soft);color:var(--ink)}
  .mobile-nav{display:none}
  .focus-screen{--focus:#171a15;--focus-muted:#a4ac9a;min-height:100vh;background:#171a15;color:#f2f4e9;display:flex;flex-direction:column;padding:0 24px}.focus-header{height:72px;max-width:1100px;width:100%;margin:auto;display:grid;grid-template-columns:1fr 1fr 1fr;align-items:center;border-bottom:1px solid #343a2e}.exit-focus{justify-self:start;display:flex;align-items:center;gap:5px;background:none;border:0;color:#a4ac9a;font-size:10px}.focus-brand{justify-self:center;font-size:13px;font-weight:900;letter-spacing:.5px}.focus-brand small{display:block;font-size:7px;letter-spacing:2px;color:#8c9580;text-align:center;margin-top:3px}.focus-number{justify-self:end;font-size:14px;font-weight:800;color:#d4fa4c}.focus-number i{font-style:normal;color:#7d8773;font-size:10px}.focus-progress{height:3px;max-width:1100px;width:100%;margin:0 auto;background:#33392e}.focus-progress i{display:block;height:100%;background:#d4fa4c;transition:width .2s}.focus-content{width:100%;max-width:690px;margin:64px auto 40px}.focus-meta{display:flex;gap:7px}.focus-meta span{font-size:8px;letter-spacing:.6px;color:#a5ad9a;border:1px solid #41483a;padding:6px 9px}.focus-label{font-size:9px;letter-spacing:2px;color:#88927e;margin-top:38px}.focus-label b{color:#d4fa4c;margin-left:7px}.focus-content h1{font-size:clamp(21px,3vw,29px);line-height:1.8;letter-spacing:-.5px;margin:17px 0 27px;font-weight:650}.focus-answers{display:grid;gap:9px}.focus-answers button{min-height:61px;border:1px solid #3c4336;background:#20241d;color:#f0f2e9;display:flex;align-items:center;gap:17px;text-align:left;padding:12px 17px;transition:.15s}.focus-answers button:hover:not(:disabled){border-color:#d4fa4c}.focus-answers button>span{font-size:9px;color:#9ca68f;letter-spacing:1px}.focus-answers button>b{font-size:12px;font-weight:500}.focus-answers button :global(svg){margin-left:auto;color:#d4fa4c}.focus-answers button.chosen-correct{background:#27331b;border-color:#b4dc42}.focus-answers button.chosen-wrong{background:#332321;border-color:#bd7770}.focus-answers button.answer-muted{opacity:.4}.answer-explain{margin-top:18px;padding:17px 19px;border-left:3px solid #d4fa4c;background:#22271e}.answer-explain.bad{border-left-color:#cf8177}.explain-heading{font-size:12px;font-weight:800;color:#d4fa4c}.answer-explain.bad .explain-heading{color:#e99a8e}.answer-explain p{font-size:11px;line-height:1.9;color:#c4cbbb;margin:7px 0 0}.answer-explain small{display:block;color:#929d85;font-size:9px;margin-top:8px}.focus-actions{display:flex;justify-content:space-between;align-items:center;margin-top:22px}.bookmark-action{height:41px;padding:0 13px;background:transparent;border:1px solid #424a3a;color:#c0c8b5;display:flex;align-items:center;gap:8px;font-size:9px}.next-action{height:43px;padding:0 18px;background:#d4fa4c;border:0;color:#202619;display:flex;align-items:center;justify-content:center;gap:24px;font-size:10px;font-weight:900}.next-action:disabled{opacity:.35;cursor:not-allowed}.focus-footer{max-width:1100px;width:100%;margin:auto auto 0;padding:19px 0;color:#78826f;display:flex;justify-content:space-between;font-size:7px;letter-spacing:1.5px}
  .finish-screen{min-height:100vh;background:#171a15;color:#f2f4e9;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:25px;text-align:center}.finish-symbol{width:67px;height:67px;border:1px solid #53613d;color:#d4fa4c;display:grid;place-items:center;margin-bottom:23px}.finish-screen .eyebrow{color:#9aa58a}.finish-screen h1{font-size:34px;letter-spacing:-1.5px;margin:12px 0 5px}.finish-screen>p{font-size:11px;color:#a4ac9a}.finish-score{width:min(100%,390px);padding:26px 28px;margin:24px 0;background:#22271e;border:1px solid #394331;display:flex;flex-direction:column;align-items:center;gap:9px}.finish-score>strong{font-size:49px;letter-spacing:-3px;color:#d4fa4c}.finish-score>strong small{font-size:15px;color:#a4ac9a}.finish-score>span,.finish-score>b{font-size:9px;color:#a4ac9a}.finish-track{height:4px;width:100%;background:#3c4434;margin:12px 0}.finish-track i{display:block;height:100%;background:#d4fa4c}.finish-back{margin-top:15px;background:none;border:0;color:#a4ac9a;font-size:10px}
  @media(max-width:1050px){.learning-feature{padding:19px}.intro-art{right:2%;transform:translateY(-50%) scale(.82)}.stats-row{grid-template-columns:1fr repeat(3,.8fr)}.stat-progress{grid-column:1/-1;border-left:0;padding:12px 0 0}.training-layout{grid-template-columns:minmax(0,1fr) 230px}.resource-grid{grid-template-columns:repeat(2,1fr)}}
  @media(max-width:760px){.learning-hub{padding-top:30px}.hub-heading h2{font-size:20px}.learning-feature-grid{grid-template-columns:1fr;gap:9px}.learning-feature{min-height:170px;padding:17px 18px}.feature-copy h3{font-size:20px}.learning-feature{grid-template-columns:45px 1fr;column-gap:12px}.feature-symbol{width:42px;height:42px}.feature-watermark{font-size:145px;bottom:-36px}.rail{transform:translateX(-100%);transition:transform .2s;width:70px}.rail.menu-open{transform:translateX(0)}.workspace{margin-left:0;padding-bottom:75px}.topline{height:56px;padding:0 17px;justify-content:start;gap:12px}.mobile-toggle{display:grid;place-items:center;width:32px;height:32px;border:0;background:transparent;color:var(--ink)}.crumb{font-size:9px}.topline-right{margin-left:auto}.live-dot{display:none}.install-app{margin-left:auto;height:31px;padding:0 9px;font-size:8px}.page-wrap{padding:0 16px 20px}.intro{margin-top:14px;min-height:340px;padding:36px 25px;align-items:flex-start}.intro h1{font-size:48px;letter-spacing:-2.5px;margin-top:28px}.intro p{font-size:10px}.intro-art{width:190px;height:190px;right:-14px;top:auto;bottom:-29px;transform:scale(.68);transform-origin:bottom right;opacity:.8}.intro-index{right:16px;bottom:16px}.stats-row{grid-template-columns:repeat(3,1fr);gap:13px;padding:22px 0}.stats-lead{grid-column:1/-1}.stats-lead h2{font-size:15px}.stat{padding-left:10px}.stat strong{font-size:23px}.stat>span{font-size:7px}.stat>i{font-size:8px}.stat-progress{grid-column:1/-1;padding-top:3px}.section-block{padding-top:38px}.section-heading{align-items:start;gap:12px}.section-heading h2{font-size:21px}.section-heading p{font-size:9px;line-height:1.7;max-width:280px}.section-count{display:none}.training-layout{grid-template-columns:1fr}.subject-picks{gap:6px}.subject-pick{height:125px;padding:11px 9px}.pick-top{font-size:6px;letter-spacing:.8px}.pick-top :global(svg){width:14px}.pick-name{font-size:19px;margin-top:19px}.pick-foot{font-size:6px;letter-spacing:.5px}.pick-index{font-size:60px;right:5px}.filter-panel{padding:16px}.filter-top h3{font-size:13px}.filter-controls{gap:6px}.filter-controls label>span{font-size:8px}.select-shell select{font-size:9px;padding-left:7px}.filter-bottom{gap:8px}.filter-bottom strong{font-size:17px}.filter-bottom span{font-size:8px}.launch-button{font-size:9px;gap:9px;padding:0 11px}.training-side{display:grid;grid-template-columns:1fr 1fr}.foundation-tile{grid-column:1/-1}.review-tile{min-height:185px;padding:15px}.review-tile h3{font-size:13px}.review-tile p{font-size:8px}.tile-number{font-size:39px}.saved-tile{padding:15px}.saved-row strong{font-size:26px}.resources-block{padding-top:43px}.compact-heading>a{font-size:8px;white-space:nowrap}.resource-grid{grid-template-columns:repeat(2,1fr);gap:7px}.resource-card{min-height:178px;border-radius:13px}.resource-card{min-height:175px;padding:13px}.resource-card h3{font-size:12px}.resource-card p{font-size:8px}.resource-icon{width:34px;height:34px;margin-top:16px}.resource-link{font-size:7px}.site-footer{margin-top:42px;font-size:7px}.footer-logo{font-size:11px}.mobile-nav{position:fixed;z-index:20;bottom:0;left:0;right:0;height:65px;background:#191c17;display:flex;align-items:center;justify-content:space-around;padding-bottom:env(safe-area-inset-bottom)}.mobile-nav a,.mobile-nav button{width:25%;height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:5px;border:0;background:none;color:#8f9884;font-size:8px}.mobile-nav .on{color:#d4fa4c}.focus-screen{padding:0 16px}.focus-header{height:60px}.focus-content{margin:36px auto}.focus-content h1{font-size:21px}.focus-answers button{min-height:56px}.focus-footer{font-size:6px}.finish-screen h1{font-size:29px}}
  @media(max-width:390px){.intro h1{font-size:43px}.intro-art{right:-37px;opacity:.65}.subject-pick{padding:10px 7px}.pick-name{font-size:17px}.pick-foot{font-size:5.5px}.filter-controls{grid-template-columns:1fr 1fr}.filter-controls label:last-child{grid-column:1/-1}.training-side{grid-template-columns:1fr}.review-tile{min-height:170px}}
</style>

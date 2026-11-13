<script>
  import { onMount, onDestroy } from 'svelte';
  import { ArrowLeft, Check, Clock3, FileText, ListTodo, Play, Pause, RotateCcw, Plus, Sparkles, BookOpen, ChevronLeft, ChevronRight, Trash2, Target } from 'lucide-svelte';

  const today = () => new Date().toLocaleDateString('sv-SE');
  let active = $state('overview');
  let tasks = $state([]);
  let taskText = $state('');
  let taskSubject = $state('理科');
  let taskMinutes = $state(25);
  let note = $state('');
  let savedNote = $state('');
  let questions = $state([]);
  let cardIndex = $state(0);
  let flipped = $state(false);
  let remaining = $state(25 * 60);
  let running = $state(false);
  let completedFocus = $state(0);
  let timerId;

  let todayTasks = $derived(tasks.filter(t => t.date === today()));
  let doneTasks = $derived(todayTasks.filter(t => t.done).length);
  let currentCard = $derived(questions[cardIndex]);
  let timeLabel = $derived(String(Math.floor(remaining / 60)).padStart(2,'0') + ':' + String(remaining % 60).padStart(2,'0'));

  onMount(async () => {
    try {
      tasks = JSON.parse(localStorage.getItem('manabixx-planner-tasks-v1') || '[]');
      note = localStorage.getItem('manabixx-planner-note-' + today()) || '';
      savedNote = note;
      completedFocus = Number(localStorage.getItem('manabixx-focus-count-' + today()) || 0);
      const response = await fetch('/data/questions.json');
      if (response.ok) {
        const payload = await response.json();
        questions = (Array.isArray(payload) ? payload : payload.questions || []).slice(0, 100);
      }
    } catch (error) {
      console.error('MANABIXX workspace initialization failed', error);
    }
  });

  onDestroy(() => { if (timerId) clearInterval(timerId); });

  function persistTasks() {
    localStorage.setItem('manabixx-planner-tasks-v1', JSON.stringify(tasks));
  }
  function addTask() {
    const title = taskText.trim();
    if (!title) return;
    tasks = [{ id: crypto.randomUUID(), title, subject: taskSubject, minutes: Number(taskMinutes), date: today(), done: false }, ...tasks];
    taskText = '';
    persistTasks();
  }
  function toggleTask(id) {
    tasks = tasks.map(t => t.id === id ? { ...t, done: !t.done } : t);
    persistTasks();
  }
  function removeTask(id) {
    tasks = tasks.filter(t => t.id !== id);
    persistTasks();
  }
  function saveNote() {
    localStorage.setItem('manabixx-planner-note-' + today(), note);
    savedNote = note;
  }
  function startTimer() {
    if (running) return;
    running = true;
    timerId = setInterval(() => {
      if (remaining <= 1) {
        remaining = 0;
        running = false;
        clearInterval(timerId);
        timerId = null;
        completedFocus += 1;
        localStorage.setItem('manabixx-focus-count-' + today(), String(completedFocus));
        return;
      }
      remaining -= 1;
    }, 1000);
  }
  function pauseTimer() {
    running = false;
    if (timerId) clearInterval(timerId);
    timerId = null;
  }
  function resetTimer() {
    pauseTimer();
    remaining = Number(taskMinutes || 25) * 60;
  }
  function setDuration(value) {
    taskMinutes = Number(value);
    resetTimer();
  }
  function nextCard() {
    if (!questions.length) return;
    cardIndex = (cardIndex + 1) % questions.length;
    flipped = false;
  }
  function previousCard() {
    if (!questions.length) return;
    cardIndex = (cardIndex - 1 + questions.length) % questions.length;
    flipped = false;
  }
</script>

<svelte:head>
  <title>学習ワークスペース — MANABIXX</title>
  <meta name="description" content="学習計画、集中タイマー、メモ、暗記カードをまとめたMANABIXXの学習ワークスペース。"/>
  <meta name="theme-color" content="#090b0a"/>
</svelte:head>

<div class="app-shell">
  <aside class="sidebar">
    <a class="brand" href="/">M<span>.</span></a>
    <span class="side-caption">WORKSPACE</span>
    <nav>
      <button class:active={active==='overview'} onclick={() => active='overview'}><Target size={17}/>概要</button>
      <button class:active={active==='tasks'} onclick={() => active='tasks'}><ListTodo size={17}/>学習計画</button>
      <button class:active={active==='focus'} onclick={() => active='focus'}><Clock3 size={17}/>集中タイマー</button>
      <button class:active={active==='cards'} onclick={() => active='cards'}><BookOpen size={17}/>暗記カード</button>
      <button class:active={active==='notes'} onclick={() => active='notes'}><FileText size={17}/>学習メモ</button>
    </nav>
    <div class="side-bottom"><a href="/">← MANABIXX ホーム</a><small>YOUR SPACE, YOUR PACE.</small></div>
  </aside>

  <main class="main">
    <header class="topbar"><div><span>MANABIXX</span><b>/</b> WORKSPACE</div><a href="/">ホームへ戻る <ArrowLeft size={14}/></a></header>
    <div class="content">
      <section class="welcome">
        <div><div class="eyebrow"><Sparkles size={14}/> PERSONAL STUDY SYSTEM</div><h1>自分だけの、<em>学習拠点。</em></h1><p>計画する。集中する。記録する。学習に必要な道具をひとつに。</p></div>
        <div class="date-chip"><small>TODAY</small><strong>{new Date().toLocaleDateString('ja-JP',{month:'long',day:'numeric',weekday:'short'})}</strong></div>
      </section>

      <div class="tabs">
        <button class:chosen={active==='overview'} onclick={() => active='overview'}>ダッシュボード</button>
        <button class:chosen={active==='tasks'} onclick={() => active='tasks'}>学習計画</button>
        <button class:chosen={active==='focus'} onclick={() => active='focus'}>集中タイマー</button>
        <button class:chosen={active==='cards'} onclick={() => active='cards'}>暗記カード</button>
        <button class:chosen={active==='notes'} onclick={() => active='notes'}>学習メモ</button>
      </div>

      {#if active==='overview'}
        <section class="section-head"><div><span class="eyebrow">YOUR DAY</span><h2>今日の進捗</h2></div><span class="live">LOCAL DATA · DEVICE ONLY</span></section>
        <div class="metrics">
          <article><small>TODAY'S TASKS</small><strong>{doneTasks}<i> / {todayTasks.length}</i></strong><span>完了したタスク</span><div class="bar"><i style="width:{todayTasks.length ? doneTasks/todayTasks.length*100 : 0}%"></i></div></article>
          <article><small>FOCUS SESSIONS</small><strong>{completedFocus}<i> 回</i></strong><span>今日完了した集中時間</span><div class="bar"><i style="width:{Math.min(completedFocus/4*100,100)}%"></i></div></article>
          <article><small>FLASHCARDS</small><strong>{questions.length}<i> 枚</i></strong><span>問題データから作成</span><div class="bar"><i style="width:{Math.min(questions.length,100)}%"></i></div></article>
        </div>
        <div class="dashboard-grid">
          <article class="panel"><div class="panel-title"><div><span class="eyebrow">PLAN</span><h3>今日やること</h3></div><button class="text-button" onclick={() => active='tasks'}>計画を編集 <ChevronRight size={15}/></button></div>
            {#if todayTasks.length}<div class="task-list">{#each todayTasks.slice(0,5) as task}<div class="task-row"><button class:checked={task.done} class="check" onclick={() => toggleTask(task.id)} aria-label="完了切り替え">{#if task.done}<Check size={14}/>{/if}</button><span class:finished={task.done}>{task.title}</span><small>{task.subject}</small></div>{/each}</div>{:else}<p class="empty">今日の計画はまだ空。小さなタスクをひとつ追加しよう。</p>{/if}
          </article>
          <article class="panel focus-panel"><span class="eyebrow">FOCUS</span><h3>まずは25分、集中。</h3><div class="mini-time">{timeLabel}</div><p>スマホを置いて、目の前の一つに取り組もう。</p><button class="primary" onclick={() => active='focus'}>タイマーを開く <ArrowRightIcon/></button></article>
        </div>
        <div class="quick-grid">
          <button onclick={() => active='tasks'}><ListTodo size={19}/><b>学習計画を作る</b><span>今日やることを整理</span></button>
          <button onclick={() => active='cards'}><BookOpen size={19}/><b>暗記カードを開く</b><span>問題データで復習</span></button>
          <button onclick={() => active='notes'}><FileText size={19}/><b>学習メモを書く</b><span>気づきを記録</span></button>
        </div>
      {:else if active==='tasks'}
        <section class="section-head"><div><span class="eyebrow">DAILY PLANNER</span><h2>今日の学習計画</h2><p>やることを小さく分けて、終わったらチェック。</p></div><span class="count">{doneTasks}/{todayTasks.length} 完了</span></section>
        <section class="panel">
          <form class="add-task" onsubmit={(e)=>{e.preventDefault();addTask();}}>
            <input bind:value={taskText} placeholder="例：理科の電流を20問解く" aria-label="タスク名"/>
            <select bind:value={taskSubject} aria-label="教科"><option>理科</option><option>社会</option><option>数学</option><option>英語</option><option>国語</option><option>その他</option></select>
            <select bind:value={taskMinutes} aria-label="予定時間"><option value={15}>15分</option><option value={25}>25分</option><option value={45}>45分</option><option value={60}>60分</option></select>
            <button class="primary" type="submit"><Plus size={16}/>追加</button>
          </form>
          <div class="task-list large">{#each todayTasks as task}<div class="task-row"><button class:checked={task.done} class="check" onclick={() => toggleTask(task.id)} aria-label="完了切り替え">{#if task.done}<Check size={14}/>{/if}</button><span class:finished={task.done}>{task.title}</span><small>{task.subject} · {task.minutes}分</small><button class="delete" onclick={() => removeTask(task.id)} aria-label="削除"><Trash2 size={15}/></button></div>{:else}<p class="empty">タスクはまだありません。最初の一つを追加しよう。</p>{/each}</div>
        </section>
      {:else if active==='focus'}
        <section class="section-head"><div><span class="eyebrow">DEEP WORK</span><h2>集中タイマー</h2><p>時間を決めて、一つの課題に集中しよう。</p></div><span class="count">{completedFocus} セッション完了</span></section>
        <section class="timer-card"><div class="timer-ring"><div><strong>{timeLabel}</strong><small>{running?'FOCUSING':'READY TO FOCUS'}</small></div></div><div class="duration"><button class:chosen={taskMinutes===15} onclick={() => setDuration(15)}>15分</button><button class:chosen={taskMinutes===25} onclick={() => setDuration(25)}>25分</button><button class:chosen={taskMinutes===45} onclick={() => setDuration(45)}>45分</button><button class:chosen={taskMinutes===60} onclick={() => setDuration(60)}>60分</button></div><div class="timer-actions">{#if running}<button class="primary" onclick={pauseTimer}><Pause size={17}/>一時停止</button>{:else}<button class="primary" onclick={startTimer} disabled={remaining===0}><Play size={17}/>スタート</button>{/if}<button class="secondary" onclick={resetTimer}><RotateCcw size={16}/>リセット</button></div><p>通知音は鳴らさず、画面上で残り時間を表示します。別のページに移動するとタイマーは停止します。</p></section>
      {:else if active==='cards'}
        <section class="section-head"><div><span class="eyebrow">ACTIVE RECALL</span><h2>暗記カード</h2><p>問題を見て答えを考えてから、カードを裏返そう。</p></div><span class="count">{questions.length ? cardIndex+1 : 0} / {questions.length}</span></section>
        {#if currentCard}<button class="flashcard" onclick={() => flipped=!flipped}><small>{flipped?'ANSWER / 解説':'QUESTION / 問題'} · {currentCard.subject==='science'?'理科':'社会'}</small>{#if flipped}<strong>{currentCard.options?.[currentCard.correct] || '解答なし'}</strong><p>{currentCard.explanation || '解説は問題ページで確認できます。'}</p>{:else}<strong>{currentCard.prompt}</strong><p>タップして答えを確認</p>{/if}<span>{flipped?'タップで問題に戻る':'TAP TO FLIP'}</span></button><div class="card-controls"><button class="secondary" onclick={previousCard}><ChevronLeft size={17}/>前へ</button><button class="primary" onclick={nextCard}>次のカード <ChevronRight size={17}/></button></div>{:else}<p class="empty">問題データを読み込んでいます。</p>{/if}
      {:else if active==='notes'}
        <section class="section-head"><div><span class="eyebrow">QUICK NOTES</span><h2>今日の学習メモ</h2><p>覚えたいこと、間違えた理由、次にやることを書き残そう。</p></div><span class="count">{note.length.toLocaleString('ja-JP')} 文字</span></section>
        <section class="panel notes-panel"><div class="note-date">NOTE · {today()}</div><textarea bind:value={note} placeholder="今日わかったこと、まだ曖昧なところ、次に復習すること…"></textarea><div class="note-footer"><span>{savedNote===note?'保存済み':'未保存の変更があります'}</span><button class="primary" onclick={saveNote}><Check size={16}/>この日のメモを保存</button></div></section>
      {/if}
      <footer>MANABIXX WORKSPACE <span>データはこの端末のブラウザー内に保存されます。</span></footer>
    </div>
  </main>
</div>

<script context="module">
  function ArrowRightIcon() { return null; }
</script>

<style>
  :global(body){margin:0;background:#090b0a;color:#edf1e9;font-family:'DM Sans','Noto Sans JP',sans-serif}
  .app-shell{min-height:100vh;background:#090b0a;color:#edf1e9;--line:#29332b;--muted:#929d90;--panel:#121713;--accent:#d4fa4c}
  .sidebar{position:fixed;inset:0 auto 0 0;width:220px;background:#101510;border-right:1px solid #263027;padding:25px 17px;display:flex;flex-direction:column;z-index:5}
  .brand{font-size:28px;font-weight:900;letter-spacing:-2px;color:#edf1e9;margin:0 0 44px 8px}.brand span{color:#d4fa4c}
  .side-caption{font-size:9px;letter-spacing:2px;color:#667363;font-weight:800;padding:0 10px 13px}
  nav{display:grid;gap:6px}nav button{border:0;background:transparent;color:#9aa596;text-align:left;padding:13px 12px;border-radius:10px;display:flex;align-items:center;gap:12px;font-size:12px}nav button.active,nav button:hover{background:#263020;color:#d4fa4c}
  .side-bottom{margin-top:auto;display:grid;gap:12px;padding:12px 8px}.side-bottom a{font-size:11px;color:#c4cfbd}.side-bottom small{font-size:8px;letter-spacing:1.5px;color:#65705f}
  .main{margin-left:220px;min-height:100vh}.topbar{height:62px;border-bottom:1px solid var(--line);display:flex;align-items:center;justify-content:space-between;padding:0 5vw;color:#9ba695;font-size:9px;letter-spacing:1.5px}.topbar b{margin:0 12px;color:#596451}.topbar a{display:flex;align-items:center;gap:7px;color:#d5dfd0;font-size:10px;letter-spacing:0}
  .content{max-width:1250px;margin:auto;padding:34px 5vw 30px}.welcome{display:flex;align-items:center;justify-content:space-between;padding:25px 0 35px}.eyebrow{display:flex;align-items:center;gap:7px;color:#b8d95a;font-size:9px;letter-spacing:1.8px;font-weight:800}.welcome h1{font-size:clamp(30px,4vw,47px);letter-spacing:-2px;margin:16px 0 8px}.welcome h1 em{font-style:normal;color:#d4fa4c}.welcome p,.section-head p{color:var(--muted);font-size:11px;line-height:1.8;margin:0}.date-chip{border:1px solid var(--line);background:var(--panel);padding:13px 18px;display:grid;gap:5px}.date-chip small{font-size:8px;letter-spacing:1.5px;color:var(--muted)}.date-chip strong{font-size:16px}
  .tabs{display:flex;gap:4px;overflow:auto;border-bottom:1px solid var(--line);margin-bottom:32px}.tabs button{flex:none;border:0;border-bottom:2px solid transparent;background:transparent;color:#879184;padding:13px 15px;font-size:10px}.tabs button.chosen{color:#d4fa4c;border-color:#d4fa4c}
  .section-head{display:flex;align-items:end;justify-content:space-between;margin:28px 0 18px}.section-head h2{font-size:22px;margin:7px 0 5px}.live,.count{font-size:9px;color:#9eac93;letter-spacing:1px}
  .metrics{display:grid;grid-template-columns:repeat(3,1fr);gap:12px}.metrics article,.panel{background:var(--panel);border:1px solid var(--line);padding:20px}.metrics small{display:block;font-size:8px;letter-spacing:1.4px;color:var(--muted);font-weight:800}.metrics strong{display:block;font-size:30px;margin:10px 0 2px}.metrics strong i{font-size:12px;color:var(--muted);font-style:normal}.metrics span{font-size:9px;color:var(--muted)}.bar{height:3px;background:#2a3329;margin-top:15px}.bar i{display:block;height:100%;background:#d4fa4c}
  .dashboard-grid{display:grid;grid-template-columns:1.4fr 1fr;gap:12px;margin-top:13px}.panel{min-width:0}.panel-title{display:flex;align-items:center;justify-content:space-between}.panel h3{font-size:16px;margin:7px 0 12px}.text-button{display:flex;align-items:center;gap:4px;border:0;background:transparent;color:#c7d2bf;font-size:10px}.task-list{display:grid}.task-row{display:flex;align-items:center;gap:11px;min-height:46px;border-top:1px solid #283128;font-size:11px}.task-row>span{flex:1}.task-row small{font-size:9px;color:var(--muted)}.finished{text-decoration:line-through;color:#778274}.check{width:19px;height:19px;flex:none;border:1px solid #59654f;border-radius:6px;background:transparent;color:#192019;display:grid;place-items:center;padding:0}.check.checked{background:#d4fa4c;border-color:#d4fa4c}.empty{color:var(--muted);font-size:11px;line-height:1.8}.focus-panel{background:linear-gradient(145deg,#1c2719,#121713)}.mini-time{font-size:42px;font-weight:800;letter-spacing:-2px;margin:14px 0 5px}.focus-panel p{font-size:10px;color:var(--muted)}.primary,.secondary{display:inline-flex;align-items:center;justify-content:center;gap:8px;border:0;padding:12px 16px;font-size:10px;font-weight:800}.primary{background:#d4fa4c;color:#172014}.primary:disabled{opacity:.4}.secondary{background:#252e25;color:#e0e8dc;border:1px solid #394438}.quick-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-top:13px}.quick-grid button{background:#111712;border:1px solid var(--line);color:#d4fa4c;text-align:left;padding:18px;display:grid;gap:9px}.quick-grid b{font-size:11px;color:#e7eee2}.quick-grid span{font-size:9px;color:var(--muted)}
  .add-task{display:grid;grid-template-columns:1fr 120px 100px auto;gap:8px}.add-task input,.add-task select{min-width:0;background:#0b100c;border:1px solid #344032;color:#eaf0e5;padding:12px;font-size:10px}.large{margin-top:18px}.delete{border:0;background:transparent;color:#788575;padding:8px}.timer-card{border:1px solid var(--line);background:radial-gradient(circle at 50% 35%,#202d1c,#101510 65%);padding:45px 20px;text-align:center}.timer-ring{width:245px;height:245px;border:7px solid #33412b;border-top-color:#d4fa4c;border-right-color:#9dbd3c;border-radius:50%;margin:0 auto 25px;display:grid;place-items:center}.timer-ring div{display:grid;gap:6px}.timer-ring strong{font-size:49px;letter-spacing:-2px}.timer-ring small{font-size:8px;letter-spacing:2px;color:#a7b49c}.duration{display:flex;justify-content:center;gap:7px}.duration button{border:1px solid #3a4635;background:#171f16;color:#aebba4;padding:8px 15px;font-size:10px}.duration button.chosen{border-color:#d4fa4c;color:#d4fa4c}.timer-actions{display:flex;justify-content:center;gap:8px;margin-top:20px}.timer-card>p{font-size:9px;color:var(--muted);margin-top:24px}
  .flashcard{width:100%;min-height:310px;background:linear-gradient(145deg,#1b2618,#111712);border:1px solid #42513a;color:#eef4e8;padding:35px;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;gap:22px}.flashcard small,.flashcard>span{font-size:9px;letter-spacing:1.5px;color:#b8d95a}.flashcard strong{font-size:clamp(19px,3vw,27px);line-height:1.8;max-width:780px}.flashcard p{font-size:11px;line-height:1.8;color:#aab6a2;max-width:720px}.card-controls{display:flex;justify-content:center;gap:10px;margin-top:15px}
  .notes-panel textarea{width:100%;min-height:300px;resize:vertical;background:#0b100c;border:1px solid #344032;color:#edf1e9;padding:18px;font:12px/2 'Noto Sans JP',sans-serif;outline:none}.note-date{font-size:9px;color:#b8d95a;letter-spacing:1.5px;margin-bottom:12px}.note-footer{display:flex;align-items:center;justify-content:space-between;margin-top:14px}.note-footer span{font-size:9px;color:var(--muted)}
  footer{border-top:1px solid var(--line);margin-top:55px;padding:18px 0;display:flex;justify-content:space-between;font-size:8px;letter-spacing:1.3px;color:#84917e}footer span{letter-spacing:0}
  @media(max-width:850px){.sidebar{width:68px;padding:20px 8px}.brand{margin:0 auto 38px}.side-caption,.side-bottom small,.side-bottom a{display:none}nav button{justify-content:center;font-size:0;padding:13px 8px}nav button :global(svg){flex:none}.main{margin-left:68px}.content{padding:26px 22px}.dashboard-grid{grid-template-columns:1fr}}
  @media(max-width:600px){.sidebar{position:fixed;inset:auto 0 0;width:100%;height:61px;padding:5px 8px;border-top:1px solid var(--line);border-right:0;background:#101510}.brand,.side-bottom{display:none}nav{display:flex;justify-content:space-around;gap:0}nav button{padding:8px 7px;gap:4px;display:flex;flex-direction:column;font-size:8px}nav button :global(svg){width:16px}.main{margin:0;padding-bottom:72px}.topbar{height:50px;padding:0 15px}.content{padding:18px 14px}.welcome{align-items:flex-start;gap:10px}.welcome h1{font-size:29px}.welcome p{font-size:9px}.date-chip{padding:9px;font-size:12px}.date-chip strong{font-size:12px}.tabs{margin-bottom:23px}.tabs button{padding:12px 10px;font-size:9px}.metrics{grid-template-columns:1fr;gap:8px}.metrics article{padding:15px}.metrics strong{font-size:25px}.quick-grid{grid-template-columns:1fr}.add-task{grid-template-columns:1fr 1fr}.add-task input{grid-column:1/-1}.add-task .primary{grid-column:1/-1}.timer-ring{width:210px;height:210px}.timer-ring strong{font-size:42px}.duration{flex-wrap:wrap}.section-head{align-items:start}.live{display:none}footer{gap:10px;line-height:1.6}footer span{text-align:right}}
</style>

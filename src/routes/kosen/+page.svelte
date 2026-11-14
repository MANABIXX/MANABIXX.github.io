<script>
  import { onMount } from 'svelte';
  import { ArrowLeft, ArrowRight, CheckCircle2, GraduationCap, RotateCcw, Sun, Moon } from 'lucide-svelte';
  let questions = $state([]);
  let subject = $state('all');
  let pool = $state([]);
  let index = $state(0);
  let selected = $state(null);
  let score = $state(0);
  let screen = $state('home');
  let theme = $state('dark');
  let loadError = $state('');
  let q = $derived(pool[index]);
  let count = $derived(questions.length);
  let available = $derived(questions.filter(item => subject === 'all' || item.subject === subject));
  const labels = { math: '数学', science: '理科', english: '英語' };
  onMount(async () => {
    theme = localStorage.getItem('manabixx-theme') || 'dark';
    document.documentElement.dataset.theme = theme;
    try {
      const response = await fetch('/data/kosen-questions.json');
      if (!response.ok) throw new Error('問題データを読み込めませんでした');
      const data = await response.json();
      questions = Array.isArray(data.questions) ? data.questions : [];
    } catch (error) { loadError = error.message || '読み込みに失敗しました'; }
  });
  function start() {
    const list = [...available];
    for (let i = list.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [list[i], list[j]] = [list[j], list[i]];
    }
    if (!list.length) return;
    pool = list; index = 0; selected = null; score = 0; screen = 'quiz';
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
  function answer(i) {
    if (selected !== null) return;
    selected = i;
    if (i === q.correct) score += 1;
  }
  function next() {
    if (index + 1 >= pool.length) screen = 'result';
    else { index += 1; selected = null; }
  }
  function toggleTheme() {
    theme = theme === 'dark' ? 'light' : 'dark';
    document.documentElement.dataset.theme = theme;
    localStorage.setItem('manabixx-theme', theme);
  }
  function home() { screen = 'home'; selected = null; }
</script>
<svelte:head>
  <title>高専専用モード — MANABIXX</title>
  <meta name="description" content="数学・理科・英語を分野別に演習できる学習モード。"/>
  <meta name="theme-color" content="#090b0a"/>
</svelte:head>
<div class="kosen-shell">
  <header class="top"><a href="/" class="brand"><span>M</span> MANABIXX</a><div><span class="mode-label">SPECIAL STUDY MODE</span><button class="theme" onclick={toggleTheme} aria-label="テーマ切替">{#if theme==='dark'}<Sun size={17}/>{:else}<Moon size={17}/>{/if}</button></div></header>
  {#if screen === 'home'}
    <main class="home">
      <a href="/" class="back"><ArrowLeft size={16}/> Studyホームへ戻る</a>
      <section class="hero"><div class="eyebrow">EXAM TRACK / INDEPENDENT PRACTICE</div><div class="symbol"><GraduationCap size={30}/></div><h1>高専専用モード</h1><p>数学・理科・英語を、分野ごとに一問ずつ。<br/>基礎から標準レベルまで、着実に力を積み上げよう。</p><div class="stats"><div><b>{count}</b><span>オリジナル問題</span></div><div><b>3</b><span>教科</span></div><div><b>4択</b><span>出題形式</span></div></div></section>
      <section class="select"><div class="section-head"><div><span>01 / SELECT SUBJECT</span><h2>教科を選ぶ</h2></div><small>{available.length} QUESTIONS</small></div><div class="subjects"><button class:active={subject==='all'} onclick={()=>subject='all'}><b>ALL</b><span>全教科</span><small>{questions.length}問</small></button>{#each ['math','science','english'] as key}<button class:active={subject===key} onclick={()=>subject=key}><b>{key.toUpperCase()}</b><span>{labels[key]}</span><small>{questions.filter(x=>x.subject===key).length}問</small></button>{/each}</div><button class="start" disabled={!available.length} onclick={start}>演習を始める <ArrowRight size={17}/></button>{#if loadError}<p class="error">{loadError}</p>{/if}</section>
      <section class="topics"><span>02 / TOPICS</span><h2>収録分野</h2><div>{#each [...new Set(available.map(x=>x.topic))] as topic}<span>{topic}</span>{/each}</div><p>収録問題は学習用に作成したオリジナル問題です。実際の過去問ではありません。</p></section>
    </main>
  {:else if screen === 'quiz' && q}
    <main class="quiz"><div class="quiz-head"><button onclick={home}><ArrowLeft size={16}/> 終了</button><span>{labels[q.subject]} / {q.topic}</span><b>{index+1} / {pool.length}</b></div><div class="progress"><i style="width:{(index+1)/pool.length*100}%"></i></div><div class="question"><span>QUESTION {String(index+1).padStart(2,'0')} · {q.level}</span><h1>{q.prompt}</h1><div class="answers">{#each q.options as option,i}<button class:correct={selected!==null && i===q.correct} class:wrong={selected===i && selected!==q.correct} disabled={selected!==null} onclick={()=>answer(i)}><b>{String.fromCharCode(65+i)}</b>{option}</button>{/each}</div>{#if selected!==null}<div class="explanation"><strong>{selected===q.correct?'正解！':'正解は '+String.fromCharCode(65+q.correct)+' です'}</strong><p>{q.explanation}</p><button onclick={next}>{index+1===pool.length?'結果を見る':'次の問題へ'} <ArrowRight size={16}/></button></div>{/if}</div></main>
  {:else}
    <main class="result"><div class="result-icon"><CheckCircle2 size={34}/></div><span>YOUR RESULT</span><h1>{score} <small>/ {pool.length}</small></h1><p>{Math.round(score/pool.length*100)}% 正解</p><div class="result-actions"><button class="start" onclick={start}><RotateCcw size={16}/> もう一度解く</button><button class="back-button" onclick={home}>教科選択へ戻る</button></div></main>
  {/if}
  <footer>MANABIXX <span>·</span> LEARN AT YOUR OWN PACE</footer>
</div>
<style>
:global(body){margin:0;background:#090b0a;color:#eef2ee;font-family:Inter,"Noto Sans JP",system-ui,sans-serif}
:global(html[data-theme="light"] body){background:#f4f6f4;color:#18201b}
.kosen-shell{min-height:100vh;background:radial-gradient(ellipse at 50% 0%,#173326 0,transparent 48%),#090b0a;color:#eef2ee}
:global(html[data-theme="light"] .kosen-shell){background:radial-gradient(ellipse at 50% 0%,#d8e9dc 0,transparent 48%),#f4f6f4;color:#18201b}
.top{height:70px;max-width:1080px;margin:auto;padding:0 24px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #ffffff16}
.brand{display:flex;gap:10px;align-items:center;color:inherit;text-decoration:none;font-size:13px;font-weight:800;letter-spacing:.12em}.brand span{display:grid;place-items:center;width:29px;height:29px;border:1px solid #65d59a;border-radius:9px;color:#65d59a}
.top>div{display:flex;align-items:center;gap:18px}.mode-label,.eyebrow,.section-head>div>span,.topics>span,.question>span,.result>span{font-size:10px;letter-spacing:.16em;color:#75dba3;font-weight:800}
.theme{width:36px;height:36px;border:1px solid #ffffff24;background:transparent;color:inherit;border-radius:50%;display:grid;place-items:center}
.home{max-width:860px;margin:auto;padding:34px 22px 80px}.back,.quiz-head button{display:inline-flex;align-items:center;gap:7px;color:inherit;text-decoration:none;opacity:.72;font-size:13px}
.hero{text-align:center;padding:65px 15px 48px}.symbol{margin:24px auto 16px;width:64px;height:64px;border-radius:20px;display:grid;place-items:center;background:#65d59a18;color:#75dba3;border:1px solid #65d59a45}
.hero h1{font-size:clamp(34px,7vw,56px);letter-spacing:-.05em;margin:12px 0}.hero p{line-height:1.9;color:#aab8ae;font-size:14px}.stats{display:flex;justify-content:center;gap:50px;margin-top:30px}.stats div{display:grid;gap:5px}.stats b{font-size:22px}.stats span,.stats small{font-size:11px;color:#94a399}
.select,.topics{border:1px solid #ffffff20;border-radius:22px;background:#111815;padding:26px;margin-top:22px}
:global(html[data-theme="light"] .select),:global(html[data-theme="light"] .topics){background:#fff;border-color:#d9e2da}
.section-head{display:flex;align-items:center;justify-content:space-between}.section-head h2,.topics h2{font-size:22px;margin:7px 0 18px}.section-head small{font-size:10px;color:#9ba99f}
.subjects{display:grid;grid-template-columns:repeat(4,1fr);gap:10px}.subjects button{min-height:112px;text-align:left;border:1px solid #ffffff20;background:#0c110e;color:inherit;border-radius:15px;padding:15px;display:flex;flex-direction:column;gap:7px}.subjects button.active{border-color:#65d59a;background:#65d59a14}.subjects b{font-size:11px;color:#75dba3;letter-spacing:.08em}.subjects span{font-size:14px;font-weight:700}.subjects small{font-size:11px;color:#9ba99f}
.start{margin-top:20px;width:100%;height:52px;border:0;border-radius:13px;background:#65d59a;color:#092014;font-size:14px;font-weight:800;display:flex;align-items:center;justify-content:center;gap:9px}.start:disabled{opacity:.4}
.topics>div{display:flex;flex-wrap:wrap;gap:8px}.topics>div span{padding:8px 12px;border:1px solid #ffffff20;border-radius:999px;font-size:12px}.topics p,.error{font-size:11px;color:#9ba99f;line-height:1.8;margin-top:17px}
.quiz{max-width:760px;margin:0 auto;padding:30px 22px 80px}.quiz-head{display:flex;align-items:center;justify-content:space-between;font-size:12px}.quiz-head button{border:0;background:none;color:inherit}.quiz-head b{font-variant-numeric:tabular-nums}.progress{height:3px;background:#ffffff20;margin-top:20px}.progress i{display:block;height:100%;background:#65d59a}
.question{padding:70px 0}.question h1{font-size:clamp(23px,5vw,34px);line-height:1.7;margin:18px 0 32px}.answers{display:grid;gap:11px}.answers button{display:flex;align-items:center;gap:15px;min-height:62px;text-align:left;padding:13px 17px;border:1px solid #ffffff24;background:#111815;color:inherit;border-radius:14px;font-size:15px}.answers button b{display:grid;place-items:center;width:30px;height:30px;border-radius:9px;background:#ffffff12;color:#75dba3}.answers button.correct{border-color:#65d59a;background:#65d59a18}.answers button.wrong{border-color:#e17b7b;background:#e17b7b18}.answers button:disabled{opacity:1}
.explanation{margin-top:20px;padding:20px;border:1px solid #65d59a55;background:#65d59a10;border-radius:15px}.explanation strong{color:#75dba3}.explanation p{font-size:14px;line-height:1.9}.explanation button{border:0;background:#65d59a;color:#092014;border-radius:10px;padding:12px 17px;font-weight:800}
.result{max-width:560px;margin:100px auto;text-align:center;padding:20px}.result-icon{color:#75dba3}.result h1{font-size:70px;margin:14px 0}.result h1 small{font-size:23px;color:#9ba99f}.result p{color:#9ba99f}.result-actions{display:grid;gap:10px}.back-button{height:48px;border:1px solid #ffffff25;border-radius:12px;background:transparent;color:inherit}
footer{text-align:center;padding:28px;font-size:10px;letter-spacing:.16em;color:#8a988e}footer span{color:#65d59a}
@media(max-width:640px){.top{padding:0 16px}.mode-label{font-size:8px}.home{padding:24px 16px 70px}.hero{padding:48px 8px 35px}.stats{gap:24px}.select,.topics{padding:19px}.subjects{grid-template-columns:repeat(2,1fr)}.subjects button{min-height:90px}.quiz{padding:22px 16px}.question{padding:48px 0}.question h1{line-height:1.65}}
</style>
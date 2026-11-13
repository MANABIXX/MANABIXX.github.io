<script>
  import { onMount } from 'svelte';
  import { ArrowLeft, ArrowRight, Check, CircleHelp, RotateCcw, Bookmark, BookOpen, Filter } from 'lucide-svelte';
  import { toast } from 'svelte-sonner';
  let { title, subtitle, endpoint, kind = 'practice' } = $props();
  let items = $state([]), loading = $state(true), error = $state('');
  let subject = $state('all'), amount = $state('10'), index = $state(0), selected = $state(null), pool = $state([]);
  let finished = $state(false), score = $state(0);
  let topics = $derived([...new Set(items.filter(x => subject === 'all' || x.subject === subject).map(x => x.topic).filter(Boolean))].sort((a,b)=>a.localeCompare(b,'ja')));
  let q = $derived(pool[index]);
  let filtered = $derived(items.filter(x => subject === 'all' || x.subject === subject));
  onMount(async()=>{try{const r=await fetch(endpoint);if(!r.ok)throw new Error('教材データを読み込めませんでした');const d=await r.json();items=Array.isArray(d)?d:(d.questions||[]);}catch(e){error=e.message;}finally{loading=false;}});
  function start(){let a=[...filtered];for(let i=a.length-1;i>0;i--){let j=Math.floor(Math.random()*(i+1));[a[i],a[j]]=[a[j],a[i]];}pool=a.slice(0,amount==='all'?a.length:Number(amount));if(!pool.length){toast.error('問題がありません');return;}index=0;selected=null;score=0;finished=false;}
  function answer(i){if(selected!==null)return;selected=i;if(i===q.correct)score++;}
  function next(){if(index===pool.length-1)finished=true;else{index++;selected=null;}}
  function back(){finished=false;pool=[];selected=null;}
</script>
<svelte:head><title>{title} — MANABIXX Study</title><meta name="description" content={subtitle}/></svelte:head>
<div class="page">
  <header><a href="/" class="back"><ArrowLeft size={17}/> Studyホーム</a><span class="brand">MANABIXX <b>STUDY</b></span></header>
  <main>
    {#if !pool.length && !finished}
      <div class="eyebrow">LEARNING LIBRARY</div><h1>{title}</h1><p class="lead">{subtitle}</p>
      {#if loading}<div class="panel">教材データを読み込んでいます…</div>
      {:else if error}<div class="panel error"><CircleHelp/> {error}</div>
      {:else}
        <section class="stats"><div><strong>{items.length.toLocaleString('ja-JP')}</strong><span>収録問題</span></div><div><strong>{items.filter(x=>x.subject==='science').length}</strong><span>理科</span></div><div><strong>{items.filter(x=>x.subject==='social').length}</strong><span>社会</span></div></section>
        <section class="panel"><h2><Filter size={18}/> 出題設定</h2><label>教科<select bind:value={subject}><option value="all">すべて</option><option value="science">理科</option><option value="social">社会</option></select></label>
        <label>問題数<select bind:value={amount}><option value="10">10問</option><option value="20">20問</option><option value="30">30問</option><option value="50">50問</option><option value="all">全問</option></select></label>
        <p class="available">{filtered.length}問から出題</p><button class="primary" onclick={start}>演習を始める <ArrowRight size={17}/></button></section>
        <div class="topic-list"><h2>収録分野</h2>{#each topics as t}<span>{t}</span>{/each}</div>
      {/if}
    {:else if finished}
      <div class="result"><div class="eyebrow">SESSION COMPLETE</div><h1>おつかれさま！</h1><strong>{score} <small>/ {pool.length}</small></strong><p>正答率 {Math.round(score/pool.length*100)}%</p><button class="primary" onclick={start}>もう一度解く <RotateCcw size={17}/></button><button class="secondary" onclick={back}>一覧に戻る</button></div>
    {:else if q}
      <div class="quiz-head"><button class="back" onclick={back}><ArrowLeft size={17}/> 中断する</button><span>{index+1} / {pool.length}</span></div><div class="progress"><i style="width:{(index+1)/pool.length*100}%"></i></div>
      <div class="eyebrow">{q.subject==='science'?'理科':q.subject==='social'?'社会':q.subject||'演習'} · {q.topic||q.term||''}</div>
      <h1 class="question">{q.prompt}</h1><div class="answers">{#each q.options as option,i}<button class:correct={selected!==null&&i===q.correct} class:wrong={selected===i&&selected!==q.correct} disabled={selected!==null} onclick={()=>answer(i)}><span>{['A','B','C','D'][i]||i+1}</span>{option}{#if selected!==null&&i===q.correct}<Check size={18}/>{/if}</button>{/each}</div>
      {#if selected!==null}<div class="explanation"><b>{selected===q.correct?'正解！':'解説を確認しよう'}</b><p>{q.explanation}</p>{#if q.takeaway}<small>{q.takeaway}</small>{/if}{#if q.sourceNote}<small>{q.sourceNote}</small>{/if}</div><button class="primary next" onclick={next}>{index===pool.length-1?'結果を見る':'次の問題へ'} <ArrowRight size={17}/></button>{/if}
    {/if}
  </main>
</div>
<style>
.page{min-height:100vh;background:var(--canvas);color:var(--ink)}header{height:68px;border-bottom:1px solid var(--line);display:flex;align-items:center;justify-content:space-between;padding:0 max(22px,calc((100vw - 1040px)/2));background:var(--surface)}.back{display:inline-flex;align-items:center;gap:8px;color:var(--muted);font-weight:650;font-size:14px}.brand{font-size:12px;letter-spacing:.12em;font-weight:800}.brand b{color:var(--brand)}main{max-width:850px;margin:0 auto;padding:58px 22px 100px}.eyebrow{font-size:11px;letter-spacing:.16em;color:var(--brand);font-weight:800;margin-bottom:12px}h1{font-size:clamp(30px,5vw,44px);letter-spacing:-.04em;margin:0 0 12px}h2{font-size:18px;display:flex;align-items:center;gap:9px}.lead{color:var(--muted);line-height:1.8;margin-bottom:30px}.stats{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin:24px 0}.stats div,.panel{background:var(--surface);border:1px solid var(--line);border-radius:18px;padding:22px;box-shadow:var(--shadow)}.stats strong{display:block;font-size:30px}.stats span{font-size:12px;color:var(--muted)}label{display:inline-grid;gap:8px;margin:12px 16px 10px 0;font-size:13px;color:var(--muted)}select{background:var(--surface-2);color:var(--ink);border:1px solid var(--line);border-radius:10px;padding:12px 18px;min-width:150px}.available{color:var(--muted);font-size:13px}.primary,.secondary{border:0;border-radius:12px;padding:14px 20px;font-weight:750;display:inline-flex;align-items:center;gap:10px}.primary{background:var(--brand);color:white}.secondary{background:var(--surface-2);color:var(--ink);margin-left:8px}.topic-list{margin-top:32px;display:flex;gap:8px;flex-wrap:wrap}.topic-list h2{width:100%}.topic-list span{padding:8px 12px;background:var(--surface);border:1px solid var(--line);border-radius:99px;font-size:12px}.quiz-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:18px}.progress{height:6px;background:var(--surface-2);border-radius:99px;margin-bottom:44px;overflow:hidden}.progress i{display:block;height:100%;background:var(--brand);transition:width .2s}.question{font-size:clamp(23px,4vw,34px);line-height:1.65;margin:16px 0 30px}.answers{display:grid;gap:12px}.answers button{display:flex;align-items:center;gap:15px;text-align:left;padding:18px;background:var(--surface);border:1px solid var(--line);border-radius:14px;color:var(--ink);font-weight:650}.answers button span{width:30px;height:30px;border-radius:9px;background:var(--surface-2);display:grid;place-items:center;font-size:12px}.answers button.correct{border-color:#269b77;background:#eaf8f2;color:#176b51}.answers button.wrong{border-color:#e26b75;background:#fff0f1;color:#a6323d}.explanation{margin-top:22px;padding:20px;border-radius:15px;background:var(--brand-soft);line-height:1.8}.explanation p{margin:8px 0}.explanation small{display:block;color:var(--muted);margin-top:8px}.next{margin-top:20px;width:100%;justify-content:center}.result{text-align:center;padding:55px 15px}.result strong{display:block;font-size:66px;color:var(--brand);margin:20px}.result small{font-size:22px;color:var(--muted)}.error{color:#bd4450}@media(max-width:600px){main{padding:38px 16px 80px}.stats div{padding:15px}.stats strong{font-size:24px}.panel{padding:18px}.stats{gap:7px}}
</style>
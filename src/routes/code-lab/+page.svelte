<script lang="ts">
  import { codeExamples, normalizeCodeLanguage, type CodeLanguage } from '$lib/code-lab';
  import { onDestroy } from 'svelte';

  let language = $state<CodeLanguage>('typescript');
  let source = $state(codeExamples.typescript.source);
  let output = $state('ここに実行結果が表示されます。');
  let running = $state(false);
  let runtimeReady = $state(false);
  let runtimeMessage = $state('実行時に必要な環境を読み込みます。');
  let pyodide: any = null;
  let disposed = false;

  onDestroy(() => { disposed = true; });

  function switchLanguage(next: string) {
    language = normalizeCodeLanguage(next);
    source = codeExamples[language].source;
    output = 'ここに実行結果が表示されます。';
    runtimeReady = false;
    runtimeMessage = '実行時に必要な環境を読み込みます。';
  }

  async function runTypeScript() {
    const ts = await import(/* @vite-ignore */ 'https://esm.sh/typescript@5.7.3');
    const result = ts.transpileModule(source, {
      compilerOptions: {
        target: ts.ScriptTarget.ES2022,
        module: ts.ModuleKind.None,
        strict: true,
      },
      reportDiagnostics: true,
    });
    const errors = (result.diagnostics || []).filter((item: any) => item.category === ts.DiagnosticCategory.Error);
    if (errors.length) {
      output = errors.map((item: any) => ts.flattenDiagnosticMessageText(item.messageText, '\\n')).join('\\n');
      return;
    }
    const logs: string[] = [];
    const safeConsole = { log: (...args: unknown[]) => logs.push(args.map(String).join(' ')), warn: (...args: unknown[]) => logs.push(args.map(String).join(' ')), error: (...args: unknown[]) => logs.push(args.map(String).join(' ')) };
    const execute = new Function('console', '"use strict";\\n' + result.outputText);
    execute(safeConsole);
    output = logs.join('\\n') || '実行完了（出力はありません）。';
    runtimeReady = true;
    runtimeMessage = 'TypeScriptをブラウザ内でコンパイルして実行しました。';
  }

  async function runPython() {
    if (!pyodide) {
      runtimeMessage = 'Python実行環境を読み込み中…（初回は少し時間がかかります）';
      const module = await import(/* @vite-ignore */ 'https://cdn.jsdelivr.net/pyodide/v0.27.2/full/pyodide.mjs');
      pyodide = await module.loadPyodide();
    }
    const logs: string[] = [];
    pyodide.setStdout({ batched: (text: string) => logs.push(text) });
    pyodide.setStderr({ batched: (text: string) => logs.push(text) });
    await pyodide.runPythonAsync(source);
    output = logs.join('\\n') || '実行完了（出力はありません）。';
    runtimeReady = true;
    runtimeMessage = 'PythonをPyodideでブラウザ内実行しました。';
  }

  async function runCode() {
    if (running) return;
    running = true;
    output = '実行中…';
    try {
      if (language === 'typescript') await runTypeScript();
      else await runPython();
    } catch (error) {
      output = error instanceof Error ? error.message : String(error);
      runtimeMessage = '実行時にエラーが発生しました。コードを確認してください。';
    } finally {
      running = false;
    }
  }

  function resetCode() {
    source = codeExamples[language].source;
    output = 'サンプルコードに戻しました。';
  }
</script>

<svelte:head>
  <title>コードラボ — MANABIXX</title>
  <meta name="description" content="TypeScriptとPythonをブラウザで試せる、MANABIXXのプログラミング学習ラボ。"/>
  <link rel="icon" href="/favicon.svg" type="image/svg+xml"/>
</svelte:head>

<div class="lab-shell">
  <header class="lab-top">
    <a class="brand" href="/"><span class="brand-mark">M</span><span>MANABIXX <small>CODE LAB</small></span></a>
    <a class="back-link" href="/">← 学習ホームへ戻る</a>
  </header>

  <main class="lab-main">
    <div class="eyebrow">03 / PROGRAMMING STUDIO</div>
    <h1>コードを書いて、<em>動かしてみる。</em></h1>
    <p class="lead">TypeScriptもPythonも、ブラウザだけで実行。環境構築なしで、すぐに試せる。</p>

    <section class="language-grid" aria-label="言語を選択">
      <button class:active={language === 'typescript'} class="language-card" onclick={() => switchLanguage('typescript')}>
        <span class="language-icon ts">TS</span><span><b>TypeScript</b><small>型安全なJavaScript</small></span><span class="arrow">↗</span>
      </button>
      <button class:active={language === 'python'} class="language-card" onclick={() => switchLanguage('python')}>
        <span class="language-icon py">Py</span><span><b>Python</b><small>データ・自動化・AI</small></span><span class="arrow">↗</span>
      </button>
    </section>

    <section class="editor-panel">
      <div class="editor-head">
        <div><span class="editor-dot"></span><b>{language === 'typescript' ? 'main.ts' : 'main.py'}</b><small> / EDITOR</small></div>
        <button class="reset" onclick={resetCode}>サンプルに戻す ↺</button>
      </div>
      <label class="sr-only" for="code-editor">コードエディター</label>
      <textarea id="code-editor" bind:value={source} spellcheck="false" autocapitalize="off" autocomplete="off" autocorrect="off" aria-label="コードエディター"></textarea>
      <div class="editor-actions">
        <span class="runtime-note">{runtimeMessage}</span>
        <button class="run-button" onclick={runCode} disabled={running}>{running ? '実行中…' : '▶　コードを実行'}</button>
      </div>
    </section>

    <section class="output-panel">
      <div class="output-head"><b>OUTPUT</b><span>{runtimeReady ? '● READY' : '○ WAITING'}</span></div>
      <pre>{output}</pre>
    </section>

    <div class="privacy-note">実行処理はあなたのブラウザ内で行われます。入力したコードをMANABIXXのサーバーへ送信しません。Pythonは初回実行時にPyodide本体をCDNから読み込みます。</div>
  </main>
</div>

<style>
  :global(body){background:#090b0a;color:#eef2e9}
  .lab-shell{min-height:100vh;background:radial-gradient(ellipse at 80% 0%,rgba(111,151,51,.13),transparent 38%),#090b0a;padding:0 24px 72px}
  .lab-top{max-width:1080px;margin:auto;height:76px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #273027}
  .brand{display:flex;align-items:center;gap:12px;font-weight:800;letter-spacing:.04em}.brand small{display:block;font-size:9px;letter-spacing:.2em;color:#a5b49a;margin-top:3px}
  .brand-mark{display:grid;place-items:center;width:36px;height:36px;border-radius:11px;background:#d4fa4c;color:#17200f;font-size:19px}
  .back-link{font-size:12px;color:#aab4a4}
  .lab-main{max-width:900px;margin:70px auto 0}.eyebrow{font-size:10px;letter-spacing:.22em;color:#d4fa4c;font-weight:800}
  h1{font-size:clamp(32px,6vw,58px);line-height:1.2;letter-spacing:-.055em;margin:18px 0 14px}h1 em{font-style:normal;color:#d4fa4c}
  .lead{color:#a8b1a3;font-size:14px;line-height:1.8;margin-bottom:34px}
  .language-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:18px}
  .language-card{display:flex;align-items:center;gap:14px;text-align:left;padding:18px;border:1px solid #303a30;border-radius:15px;background:#121713;color:#eef2e9;cursor:pointer}
  .language-card.active{border-color:#d4fa4c;background:#1b2418;box-shadow:inset 0 0 0 1px #d4fa4c33}
  .language-icon{width:42px;height:42px;border-radius:12px;display:grid;place-items:center;font-weight:900;font-size:14px}.ts{background:#203b59;color:#7fc5ff}.py{background:#3a3420;color:#ffe078}
  .language-card b,.language-card small{display:block}.language-card small{font-size:11px;color:#9ba696;margin-top:4px}.arrow{margin-left:auto;color:#d4fa4c}
  .editor-panel,.output-panel{border:1px solid #303a30;border-radius:16px;overflow:hidden;background:#101511}
  .editor-head,.output-head{height:48px;padding:0 16px;display:flex;align-items:center;justify-content:space-between;background:#171e18;border-bottom:1px solid #303a30;font-size:12px}
  .editor-head small{color:#8c9887;font-size:10px}.editor-dot{display:inline-block;width:8px;height:8px;border-radius:50%;background:#d4fa4c;margin-right:9px}
  .reset{background:transparent;border:0;color:#a9b59f;font-size:11px;cursor:pointer}
  textarea{display:block;width:100%;min-height:300px;resize:vertical;border:0;outline:0;padding:22px;background:#0d110e;color:#d8e8d0;font:13px/1.8 ui-monospace,SFMono-Regular,Consolas,monospace;tab-size:4;white-space:pre}
  .editor-actions{padding:14px 16px;display:flex;align-items:center;justify-content:space-between;gap:12px;border-top:1px solid #283128}.runtime-note{font-size:10px;color:#96a18f;line-height:1.6}
  .run-button{border:0;border-radius:10px;padding:12px 18px;background:#d4fa4c;color:#19200f;font-weight:800;font-size:12px;cursor:pointer;white-space:nowrap}.run-button:disabled{opacity:.55;cursor:wait}
  .output-panel{margin-top:14px}.output-head{height:40px;font-size:10px;letter-spacing:.15em}.output-head span{color:#b9d66b}
  pre{margin:0;padding:18px;min-height:90px;white-space:pre-wrap;overflow-wrap:anywhere;color:#d4e5ca;font:12px/1.7 ui-monospace,SFMono-Regular,Consolas,monospace}
  .privacy-note{font-size:10px;line-height:1.8;color:#788575;margin-top:16px}
  .sr-only{position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0}
  @media(max-width:600px){.lab-shell{padding:0 15px 50px}.lab-main{margin-top:46px}.language-grid{grid-template-columns:1fr}.language-card{padding:14px}.editor-actions{align-items:flex-start;flex-direction:column}.run-button{width:100%}.back-link{font-size:10px}}
</style>

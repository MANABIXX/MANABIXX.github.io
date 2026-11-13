(()=>{"use strict";
const CONFIG=[
 {id:"seiran",name:"青藍泰斗高校",kind:"私立入試",date:"2027-01-06",start:"2026-11-13",goal:30},
 {id:"tochigi",name:"栃木県立高校入試",kind:"一般選抜",date:"2027-03-04",start:"2026-11-13",goal:30}
];
const messages={
 foundation:["今は基礎を固める時期。今日覚えた1つが、本番の1点になる。","焦って難問に飛びつかなくていい。取れる問題を確実に取ろう。","昨日できなかった問題を今日できるようにする。それが実力。"],
 practice:["知識を得点に変える時期。解いた後の解き直しまでが演習。","正解した数より、間違いから何を回収したか。","本番と同じつもりで1問に向き合おう。"],
 sprint:["新しいことを増やしすぎず、取れる問題を落とさない。","ここまで積み上げた自分を信じて、いつも通り解こう。","最後の1日まで伸びる。睡眠も実力のうち。"],
 streak:["続けた日数は、簡単には裏切らない。","今日も机に向かった。それだけで昨日より前進している。","小さくても継続。積み重ねは本番で力になる。"]
};
const $=id=>document.getElementById(id);
const dayKey=d=>[d.getFullYear(),String(d.getMonth()+1).padStart(2,"0"),String(d.getDate()).padStart(2,"0")].join("-");
const localDate=s=>{const [y,m,d]=s.split("-").map(Number);return new Date(y,m-1,d)};
function render(){
 const root=$("examCountdown");if(!root)return;
 const now=new Date(),today=dayKey(now);
 let p={history:[],streak:0};try{p=Object.assign(p,JSON.parse(localStorage.getItem("shitadumi-progress-v2")||"{}"))}catch{}
 const done=(p.history||[]).filter(x=>x.date===today).length;
 const days=new Set((p.history||[]).map(x=>x.date));let streak=0,cursor=new Date(now.getFullYear(),now.getMonth(),now.getDate());
 if(!days.has(today))cursor.setDate(cursor.getDate()-1);
 while(days.has(dayKey(cursor))){streak++;cursor.setDate(cursor.getDate()-1)}
 const cards=CONFIG.map(x=>{
  const target=localDate(x.date),diff=target-now,passed=diff<=0,remaining=Math.max(0,diff),daysLeft=Math.ceil(remaining/86400000);
  const mins=Math.floor(remaining/60000),hours=Math.floor(mins/60)%24,minutes=mins%60;
  const start=localDate(x.start),progress=Math.min(100,Math.max(0,Math.round((now-start)/(target-start)*100)));
  const tone=passed?"passed":daysLeft<=7?"sprint":daysLeft<=30?"warning":"normal";
  const total=Math.max(0,daysLeft*x.goal);
  return `<article class="exam-card ${tone}"><div class="exam-card-head"><div><small>${x.kind}</small><h3>${x.name}</h3></div><span class="exam-status">${passed?"NEXT STAGE":daysLeft<=7?"LAST SPURT":daysLeft<=30?"あと少し":"COUNTDOWN"}</span></div>${passed?'<strong class="exam-passed">お疲れ様でした！</strong><p>次の目標へ、一歩ずつ。</p>':`<div class="exam-days"><b>${daysLeft}</b><span>日</span></div><p class="exam-time">あと ${hours}時間 ${minutes}分</p><div class="exam-progress-label"><span>入試までの準備期間</span><b>${progress}%</b></div><div class="exam-track"><i style="width:${progress}%"></i></div><p class="exam-total">今日 ${x.goal}問ペースで、入試までに約 ${total.toLocaleString("ja-JP")}問。</p><small class="exam-provisional">※日程は仮設定。募集要項公表後に更新してください。</small>`}</article>`;
 }).join("");
 const nearest=CONFIG.map(x=>({x,days:Math.ceil((localDate(x.date)-now)/86400000)})).filter(x=>x.days>0).sort((a,b)=>a.days-b.days)[0];
 const phase=!nearest?"passed":nearest.days<=14?"sprint":nearest.days<=60?"practice":"foundation";
 const list=phase==="passed"?["試験を終えた自分に、お疲れ様。次の目標へ進もう。"]:messages[phase];
 const msg=streak>=3?messages.streak[(streak+now.getDate())%3]:list[(now.getDate()+now.getMonth())%list.length];
 const pct=Math.min(100,Math.round(done/30*100));
 root.innerHTML=`<div class="exam-grid">${cards}</div><div class="exam-mission"><div class="exam-mission-top"><div><small>TODAY'S MISSION</small><h3>今日の目標は 30問</h3></div><div class="exam-done"><b>${done}<small> / 30問</small></b><span>${pct}% 達成</span></div></div><div class="exam-track mission-track"><i style="width:${pct}%"></i></div><div class="exam-message"><p>「${msg}」</p><span>🔥 ${streak}日連続</span></div></div>`;
}
render();setInterval(render,30000);window.addEventListener("storage",render);
})();
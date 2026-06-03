// screens_analysis.jsx — Analysis result + Error details
const { useState: useStateA } = React;

// ── sub-screen header ─────────────────────────────────────────
function SubHeader({ title, onBack, trailing, subtitle }) {
  return (
    <>
      <div className="safe-top" />
      <div className="appbar" style={{ paddingTop: 6, paddingBottom: 6 }}>
        <button onClick={onBack} style={{ appearance: 'none', border: 'none', background: 'var(--card)', boxShadow: 'var(--shadow-sm)', width: 38, height: 38, borderRadius: 999, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', color: 'var(--ink)' }}>
          <Icon name="chevL" size={20} sw={2.3} />
        </button>
        <div style={{ textAlign: 'center', flex: 1 }}>
          <div className="h-sec">{title}</div>
          {subtitle && <div className="t-sm">{subtitle}</div>}
        </div>
        <div style={{ width: 38, height: 38, display: 'flex', alignItems: 'center', justifyContent: 'flex-end' }}>{trailing}</div>
      </div>
    </>
  );
}

// ── word-level diff (LCS) ─────────────────────────────────────
function diffWords(a, b) {
  const A = a.split(/(\s+)/), B = b.split(/(\s+)/);
  const m = A.length, n = B.length;
  const dp = Array.from({ length: m + 1 }, () => new Array(n + 1).fill(0));
  for (let i = m - 1; i >= 0; i--)
    for (let j = n - 1; j >= 0; j--)
      dp[i][j] = A[i] === B[j] ? dp[i + 1][j + 1] + 1 : Math.max(dp[i + 1][j], dp[i][j + 1]);
  const ops = []; let i = 0, j = 0;
  while (i < m && j < n) {
    if (A[i] === B[j]) { ops.push({ w: A[i], k: 'eq' }); i++; j++; }
    else if (dp[i + 1][j] >= dp[i][j + 1]) { ops.push({ w: A[i], k: 'del' }); i++; }
    else { ops.push({ w: B[j], k: 'add' }); j++; }
  }
  while (i < m) ops.push({ w: A[i++], k: 'del' });
  while (j < n) ops.push({ w: B[j++], k: 'add' });
  return ops;
}
function DiffText({ ops, mode }) {
  return (
    <span>
      {ops.filter(o => o.k === 'eq' || o.k === mode).map((o, i) => {
        if (o.k === 'eq') return <span key={i}>{o.w}</span>;
        if (mode === 'del') return <span key={i} style={{ background: 'color-mix(in oklab, var(--bad) 16%, #fff)', color: 'color-mix(in oklab, var(--bad) 75%, #000)', textDecoration: 'line-through', borderRadius: 4, padding: '0 1px' }}>{o.w}</span>;
        return <span key={i} style={{ background: 'color-mix(in oklab, var(--good) 18%, #fff)', color: 'color-mix(in oklab, var(--good) 70%, #000)', fontWeight: 700, borderRadius: 4, padding: '0 1px' }}>{o.w}</span>;
      })}
    </span>
  );
}

// ── ANALYSIS RESULT ───────────────────────────────────────────
const SEV = { high: 'bad', mid: 'warn', low: 'good' };
const SEV_LABEL = { high: 'Frequent', mid: 'Occasional', low: 'Rare' };

function AnalysisScreen({ exam, examKey, setExam, go }) {
  const score = exam.key === 'ielts' ? exam.fmt(LAST_ESSAY.band) : exam.fmt(LAST_ESSAY.toefl);
  const skills = SKILLS.map((s, i) => ({ ...s, name: exam.skills[i] }));
  const examOpts = [{ value: 'ielts', label: 'IELTS' }, { value: 'toefl', label: 'TOEFL' }];

  return (
    <div className="screen">
      <SubHeader title="Analysis" subtitle={LAST_ESSAY.title} onBack={() => go('home')}
        trailing={<button style={{ appearance: 'none', border: 'none', background: 'none', cursor: 'pointer', color: 'var(--primary)' }}><Icon name="refresh" size={20} sw={2} /></button>} />

      <div className="screen-pad rise" style={{ paddingTop: 4 }}>
        {/* score card */}
        <div className="card card-pad" style={{ overflow: 'hidden' }}>
          <div className="between" style={{ marginBottom: 16 }}>
            <Chip tone="primary">{exam.label} Task 2 · {LAST_ESSAY.words} words</Chip>
            <Segmented options={examOpts} value={examKey} onChange={setExam} />
          </div>
          <div className="row" style={{ gap: 20 }}>
            <Ring value={LAST_ESSAY.normalized} size={128} sw={12}>
              <span className="t-num" style={{ fontSize: 40, fontWeight: 700, color: 'var(--primary)', lineHeight: 1 }}><CountUp value={LAST_ESSAY.normalized} /></span>
              <span className="t-sm" style={{ marginTop: 1 }}>/ 100 health</span>
            </Ring>
            <div style={{ flex: 1 }}>
              <div className="t-sm">Estimated {exam.label} {exam.scoreLabel.toLowerCase()}</div>
              <div className="t-num" style={{ fontSize: 46, fontWeight: 700, lineHeight: 1, margin: '2px 0 8px' }}>{score}</div>
              <Chip tone="good" icon={<Icon name="arrowUp" size={13} sw={2.6} />}>+0.5 from last</Chip>
            </div>
          </div>
          <p className="t-body" style={{ marginTop: 16, paddingTop: 14, borderTop: '1px solid var(--line-2)', fontSize: 14 }}>
            A well-structured response with a clear position. Push your <b style={{ color: 'var(--ink)' }}>lexical range</b> and tidy up article usage to reach Band {exam.fmt(exam.goal)}.
          </p>
        </div>

        {/* skill breakdown */}
        <SecHead title="Skill breakdown" />
        <div className="card card-pad stack">
          {skills.map((s, i) => (
            <div key={i}>
              <div className="between" style={{ marginBottom: 7 }}>
                <div className="row-gap" style={{ gap: 8 }}>
                  <span style={{ fontSize: 14.5, fontWeight: 600 }}>{s.name}</span>
                  {s.focus && <Chip tone="primary" style={{ padding: '2px 8px', fontSize: 11 }}>Focus</Chip>}
                </div>
                <div className="row-gap" style={{ gap: 8 }}>
                  <Delta value={s.delta} />
                  <span className="t-num" style={{ fontWeight: 700, fontSize: 15, width: 24, textAlign: 'right' }}>{s.score}</span>
                </div>
              </div>
              <Bar pct={s.score} height={8} delay={120 + i * 90}
                color={s.score >= 80 ? 'var(--good)' : s.score >= 70 ? 'var(--primary)' : 'var(--warn)'} />
            </div>
          ))}
        </div>

        {/* recurring mistakes */}
        <SecHead title="Top recurring mistakes" action="All corrections" onAction={() => go('error')} />
        <div className="card" style={{ overflow: 'hidden' }}>
          {MISTAKES.slice(0, 4).map((m, i) => (
            <button key={m.id} onClick={() => go('error')} style={{
              display: 'flex', alignItems: 'center', gap: 12, width: '100%', textAlign: 'left',
              appearance: 'none', border: 'none', background: 'none', cursor: 'pointer',
              padding: '14px 16px', borderTop: i ? '1px solid var(--line-2)' : 'none',
            }}>
              <span style={{ width: 9, height: 9, borderRadius: 999, flex: 'none', background: `var(--${SEV[m.level] === 'bad' ? 'bad' : SEV[m.level] === 'warn' ? 'warn' : 'good'})` }} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14.5, fontWeight: 600 }}>{m.label}</div>
                <div className="t-sm" style={{ marginTop: 1 }}>{m.count} occurrences · {SEV_LABEL[m.level]}</div>
              </div>
              <Delta value={m.trend} invertGood />
              <Icon name="chevR" size={16} sw={2.2} style={{ color: 'var(--ink-4)' }} />
            </button>
          ))}
        </div>

        <button className="btn btn-primary btn-block" style={{ marginTop: 18 }} onClick={() => go('error')}>
          <Icon name="edit" size={18} sw={2.1} /> Review corrections
        </button>
      </div>
      <div className="tab-safe" style={{ height: 24 }} />
    </div>
  );
}

// ── ERROR DETAILS (pager) ─────────────────────────────────────
function ErrorScreen({ go }) {
  const [idx, setIdx] = useStateA(0);
  const total = CORRECTIONS.length;
  const c = CORRECTIONS[idx];
  const ops = diffWords(c.original, c.corrected);
  const next = () => setIdx(i => Math.min(total - 1, i + 1));
  const prev = () => setIdx(i => Math.max(0, i - 1));

  return (
    <div className="screen">
      <SubHeader title="Corrections" subtitle={`${idx + 1} of ${total}`} onBack={() => go('analysis')} />

      {/* progress dots */}
      <div className="row" style={{ gap: 6, justifyContent: 'center', padding: '0 0 14px' }}>
        {CORRECTIONS.map((_, i) => (
          <span key={i} onClick={() => setIdx(i)} style={{ cursor: 'pointer', height: 5, borderRadius: 999, width: i === idx ? 26 : 18, background: i === idx ? 'var(--primary)' : i < idx ? 'var(--good)' : 'var(--line)', transition: 'all 200ms' }} />
        ))}
      </div>

      <div className="screen-pad" style={{ paddingTop: 0 }}>
        <div key={idx} className="anim-push stack">
          <div className="between">
            <Chip tone={SEV[c.severity]} icon={<Icon name="info" size={13} sw={2.2} />}>{SEV_LABEL[c.severity]} · {c.type}</Chip>
          </div>

          {/* original */}
          <div className="card card-pad" style={{ borderColor: 'color-mix(in oklab, var(--bad) 22%, var(--line))', background: 'var(--bad-tint)' }}>
            <div className="row-gap" style={{ marginBottom: 8, color: 'color-mix(in oklab, var(--bad) 70%, #000)' }}>
              <Icon name="x" size={15} sw={2.6} /><span className="h-eyebrow" style={{ color: 'inherit' }}>Your sentence</span>
            </div>
            <p style={{ margin: 0, fontSize: 15.5, lineHeight: 1.55, color: 'var(--ink)' }}><DiffText ops={ops} mode="del" /></p>
          </div>

          {/* corrected */}
          <div className="card card-pad" style={{ borderColor: 'color-mix(in oklab, var(--good) 30%, var(--line))', background: 'var(--good-tint)' }}>
            <div className="row-gap" style={{ marginBottom: 8, color: 'color-mix(in oklab, var(--good) 65%, #000)' }}>
              <Icon name="check" size={15} sw={2.8} /><span className="h-eyebrow" style={{ color: 'inherit' }}>Suggested</span>
            </div>
            <p style={{ margin: 0, fontSize: 15.5, lineHeight: 1.55, color: 'var(--ink)' }}><DiffText ops={ops} mode="add" /></p>
          </div>

          {/* explanation */}
          <div className="card card-pad">
            <div className="row-gap" style={{ marginBottom: 9 }}>
              <div style={{ width: 30, height: 30, borderRadius: 9, background: 'var(--primary-tint)', color: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="bulb" size={17} sw={2} /></div>
              <div><div style={{ fontSize: 14.5, fontWeight: 700 }}>Why this matters</div><div className="t-sm">{c.rule}</div></div>
            </div>
            <p className="t-body">{c.why}</p>
          </div>

          {/* vocab upgrades */}
          <div>
            <div className="row-gap" style={{ margin: '4px 2px 10px', gap: 8 }}>
              <Icon name="arrowUp" size={17} sw={2.4} style={{ color: 'var(--violet)' }} />
              <span className="h-sec">Vocabulary upgrades</span>
            </div>
            <div className="card" style={{ overflow: 'hidden' }}>
              {c.upgrades.map((u, i) => (
                <div key={i} style={{ padding: '13px 16px', borderTop: i ? '1px solid var(--line-2)' : 'none' }}>
                  <div className="row-gap" style={{ flexWrap: 'wrap', gap: 8 }}>
                    <span style={{ fontSize: 14, color: 'var(--ink-3)', textDecoration: 'line-through' }}>{u.from}</span>
                    <Icon name="arrowRight" size={15} sw={2.2} style={{ color: 'var(--violet)' }} />
                    <span style={{ fontSize: 14.5, fontWeight: 700, color: 'var(--violet)' }}>{u.to}</span>
                  </div>
                  <div className="t-sm" style={{ marginTop: 4 }}>{u.note}</div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* pager controls */}
        <div className="row-gap" style={{ gap: 10, marginTop: 20 }}>
          <button className="btn btn-soft" style={{ flex: 'none', width: 54, padding: 14, opacity: idx === 0 ? 0.4 : 1 }} onClick={prev} disabled={idx === 0}><Icon name="chevL" size={20} sw={2.3} /></button>
          {idx < total - 1
            ? <button className="btn btn-primary" style={{ flex: 1 }} onClick={next}>Next correction <Icon name="chevR" size={18} sw={2.3} /></button>
            : <button className="btn btn-primary" style={{ flex: 1 }} onClick={() => go('progress')}><Icon name="check" size={18} sw={2.6} /> Done · view progress</button>}
        </div>
      </div>
      <div className="tab-safe" style={{ height: 24 }} />
    </div>
  );
}

Object.assign(window, { SubHeader, AnalysisScreen, ErrorScreen, diffWords, DiffText });

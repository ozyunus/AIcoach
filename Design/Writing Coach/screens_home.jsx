// screens_home.jsx — Home dashboard + Write essay
const { useState: useStateH, useEffect: useEffectH, useRef: useRefH } = React;

// ── greeting helper ───────────────────────────────────────────
function greeting() {
  const h = 9; // demo morning
  return h < 12 ? 'Good morning' : h < 18 ? 'Good afternoon' : 'Good evening';
}

// ── hero: Writing Health Score (3 viz variants) ───────────────
function HeroScore({ exam, examKey, setExam, viz, go }) {
  const band = exam.toBand(HEALTH.score);
  const goalPct = Math.round(((exam.current) / exam.goal) * 100);
  const examOpts = [{ value: 'ielts', label: 'IELTS' }, { value: 'toefl', label: 'TOEFL' }];

  const numberViz = (
    <div className="between" style={{ alignItems: 'flex-end', gap: 14 }}>
      <div>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 6 }}>
          <span className="t-num" style={{ fontSize: 62, fontWeight: 700, lineHeight: 0.95, color: 'var(--primary)' }}>
            <CountUp value={HEALTH.score} />
          </span>
          <span className="t-num" style={{ fontSize: 19, fontWeight: 600, color: 'var(--ink-4)' }}>/100</span>
        </div>
        <div className="row-gap" style={{ marginTop: 8 }}>
          <Chip tone="good" icon={<Icon name="arrowUp" size={13} sw={2.6} />}>{HEALTH.delta} this week</Chip>
        </div>
      </div>
      <div style={{ flex: 1, maxWidth: 150 }}>
        <TrendChart data={HEALTH.history} w={150} h={66} dots={false} />
      </div>
    </div>
  );

  const ringViz = (
    <div className="row" style={{ gap: 18 }}>
      <Ring value={HEALTH.score} size={120} sw={11}>
        <span className="t-num" style={{ fontSize: 38, fontWeight: 700, color: 'var(--primary)', lineHeight: 1 }}><CountUp value={HEALTH.score} /></span>
        <span className="t-sm" style={{ marginTop: 2 }}>of 100</span>
      </Ring>
      <div style={{ flex: 1 }}>
        <Chip tone="good" icon={<Icon name="arrowUp" size={13} sw={2.6} />}>{HEALTH.delta} pts this week</Chip>
        <p className="t-sm" style={{ marginTop: 10 }}>Up from {HEALTH.prev} last week. Your strongest run yet.</p>
      </div>
    </div>
  );

  const barViz = (
    <div>
      <div className="between" style={{ alignItems: 'flex-end' }}>
        <span className="t-num" style={{ fontSize: 54, fontWeight: 700, color: 'var(--primary)', lineHeight: 0.95 }}><CountUp value={HEALTH.score} /><span style={{ fontSize: 18, color: 'var(--ink-4)' }}>/100</span></span>
        <Chip tone="good" icon={<Icon name="arrowUp" size={13} sw={2.6} />}>{HEALTH.delta} this week</Chip>
      </div>
      <div style={{ marginTop: 14 }}><Bar pct={HEALTH.score} height={12} /></div>
    </div>
  );

  return (
    <div className="card card-pad" style={{ overflow: 'hidden' }}>
      <div className="between" style={{ marginBottom: 14 }}>
        <div className="row-gap">
          <div style={{ width: 30, height: 30, borderRadius: 9, background: 'var(--primary-tint)', color: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="shield" size={17} sw={2} />
          </div>
          <span className="h-eyebrow" style={{ color: 'var(--ink-2)' }}>Writing Health</span>
        </div>
        <Segmented options={examOpts} value={examKey} onChange={setExam} />
      </div>

      {viz === 'ring' ? ringViz : viz === 'bar' ? barViz : numberViz}

      <div style={{ height: 1, background: 'var(--line-2)', margin: '16px 0 14px' }} />
      <div className="between">
        <div>
          <div className="t-sm">Current {exam.label} {exam.scoreLabel.toLowerCase()}</div>
          <div className="row-gap" style={{ marginTop: 3 }}>
            <span className="t-num" style={{ fontSize: 21, fontWeight: 700 }}>{exam.fmt(exam.current)}</span>
            <Icon name="arrowRight" size={15} sw={2.4} style={{ color: 'var(--ink-4)' }} />
            <span className="t-num" style={{ fontSize: 21, fontWeight: 700, color: 'var(--primary)' }}>{exam.fmt(exam.goal)}</span>
            <span className="t-sm">goal</span>
          </div>
        </div>
        <div style={{ width: 90 }}>
          <div className="t-sm" style={{ textAlign: 'right', marginBottom: 5 }}>{goalPct}% there</div>
          <Bar pct={goalPct} height={7} />
        </div>
      </div>
    </div>
  );
}

// ── today's goal ──────────────────────────────────────────────
function TodayGoal({ go }) {
  return (
    <div className="card card-pad" style={{ background: 'var(--primary)', color: '#fff', border: 'none', boxShadow: 'var(--shadow-cta)' }}>
      <div className="between">
        <span className="h-eyebrow" style={{ color: 'rgba(255,255,255,0.8)' }}>Today’s goal</span>
        <Chip style={{ background: 'rgba(255,255,255,0.18)', color: '#fff' }} icon={<Icon name="clock" size={13} sw={2.2} />}>{TODAY_GOAL.minutes} min</Chip>
      </div>
      <h3 style={{ margin: '10px 0 6px', fontSize: 19, fontWeight: 800, letterSpacing: '-0.01em' }}>{TODAY_GOAL.task}</h3>
      <p style={{ margin: 0, fontSize: 13.5, lineHeight: 1.45, color: 'rgba(255,255,255,0.85)' }}>“{TODAY_GOAL.prompt}”</p>
      <button className="btn btn-block" style={{ marginTop: 16, background: '#fff', color: 'var(--primary)' }} onClick={() => go('write')}>
        <Icon name="pen" size={18} sw={2.2} /> Start writing
      </button>
    </div>
  );
}

// ── active challenges (horizontal) ────────────────────────────
const ACC = { warn: 'var(--warn)', good: 'var(--good)', violet: 'var(--violet)', primary: 'var(--primary)' };
const ACC_TINT = { warn: 'var(--warn-tint)', good: 'var(--good-tint)', violet: 'var(--violet-tint)', primary: 'var(--primary-tint)' };
const ACC_ICON = { streak: 'flame', errors: 'target', vocab: 'book', coherence: 'check' };

function ChallengeMini({ c, go }) {
  const pct = Math.round((c.progress / c.total) * 100);
  return (
    <button onClick={() => go('challenges')} style={{
      textAlign: 'left', appearance: 'none', cursor: 'pointer',
      minWidth: 184, width: 184, flex: 'none', border: '1px solid var(--line-2)',
      background: 'var(--card)', borderRadius: 'var(--r-md)', padding: 15, boxShadow: 'var(--shadow-sm)',
    }}>
      <div className="between" style={{ marginBottom: 12 }}>
        <div style={{ width: 34, height: 34, borderRadius: 10, background: ACC_TINT[c.accent], color: ACC[c.accent], display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name={ACC_ICON[c.kind]} size={18} sw={2.1} fill={c.kind === 'streak' ? 'currentColor' : 'none'} />
        </div>
        <span className="t-num" style={{ fontSize: 13, fontWeight: 700, color: ACC[c.accent] }}>{c.progress}/{c.total}</span>
      </div>
      <div style={{ fontSize: 14, fontWeight: 700, lineHeight: 1.25, marginBottom: 10 }}>{c.title}</div>
      <Bar pct={pct} height={6} color={ACC[c.accent]} />
      <div className="t-sm" style={{ marginTop: 9, display: 'flex', alignItems: 'center', gap: 5 }}>
        <Icon name="bolt" size={12} sw={2} fill="currentColor" style={{ color: ACC[c.accent] }} />+{c.reward} credits
      </div>
    </button>
  );
}

// ── last essay ────────────────────────────────────────────────
function LastEssay({ exam, go }) {
  const score = exam.key === 'ielts' ? exam.fmt(LAST_ESSAY.band) : exam.fmt(LAST_ESSAY.toefl);
  return (
    <button className="card card-pad" onClick={() => go('analysis')} style={{ display: 'block', width: '100%', textAlign: 'left', cursor: 'pointer', appearance: 'none' }}>
      <div className="between">
        <div style={{ flex: 1, minWidth: 0 }}>
          <div className="row-gap" style={{ marginBottom: 7 }}>
            <Chip tone="primary">{exam.label} Task 2</Chip>
            <span className="t-sm">{LAST_ESSAY.date}</span>
          </div>
          <div style={{ fontSize: 15.5, fontWeight: 700, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{LAST_ESSAY.title}</div>
          <div className="t-sm" style={{ marginTop: 3 }}>{LAST_ESSAY.words} words · {LAST_ESSAY.normalized}/100 health</div>
        </div>
        <div style={{ textAlign: 'center', marginLeft: 12 }}>
          <div className="t-num" style={{ fontSize: 30, fontWeight: 700, color: 'var(--primary)', lineHeight: 1 }}>{score}</div>
          <div className="t-sm">{exam.scoreLabel.toLowerCase()}</div>
        </div>
        <Icon name="chevR" size={18} sw={2.2} style={{ color: 'var(--ink-4)', marginLeft: 6 }} />
      </div>
    </button>
  );
}

// ── HOME ──────────────────────────────────────────────────────
function HomeScreen({ exam, examKey, setExam, healthViz, go }) {
  return (
    <div className="screen">
      <div className="safe-top" />
      <div className="appbar">
        <div>
          <div className="t-sm" style={{ fontWeight: 600 }}>{greeting()},</div>
          <div className="h-screen">{USER.name}</div>
        </div>
        <div className="row-gap">
          <button className="chip chip-primary" style={{ cursor: 'pointer', border: 'none', padding: '8px 12px' }} onClick={() => go('paywall')}>
            <Icon name="bolt" size={14} sw={2} fill="currentColor" /> {USER.credits}
          </button>
          <button style={{ appearance: 'none', border: 'none', background: 'none', cursor: 'pointer', padding: 0 }} onClick={() => go('profile')}>
            <Avatar initials={USER.initials} size={42} />
          </button>
        </div>
      </div>

      <div className="screen-pad rise">
        <HeroScore exam={exam} examKey={examKey} setExam={setExam} viz={healthViz} go={go} />
        <div style={{ marginTop: 14 }}><TodayGoal go={go} /></div>

        <div>
          <SecHead title="Active challenges" action="See all" onAction={() => go('challenges')} />
          <div style={{ display: 'flex', gap: 12, overflowX: 'auto', margin: '0 -18px', padding: '2px 18px 6px', scrollbarWidth: 'none' }}>
            {CHALLENGES.filter(c => c.state === 'active').map(c => <ChallengeMini key={c.id} c={c} go={go} />)}
          </div>
        </div>

        <div>
          <SecHead title="Last essay" action="History" onAction={() => go('progress')} />
          <LastEssay exam={exam} go={go} />
        </div>

        <div>
          <SecHead title="This month" action="Details" onAction={() => go('progress')} />
          <div className="card card-pad">
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
              {[
                { n: MONTHLY.essays, l: 'Essays' },
                { n: '+' + MONTHLY.scoreChange, l: 'Health pts', accent: true },
                { n: USER.streak, l: 'Day streak' },
              ].map((s, i) => (
                <div key={i} style={{ textAlign: 'center' }}>
                  <div className="t-num" style={{ fontSize: 26, fontWeight: 700, color: s.accent ? 'var(--good)' : 'var(--ink)' }}>{s.n}</div>
                  <div className="t-sm" style={{ marginTop: 2 }}>{s.l}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
      <div className="tab-safe" />
    </div>
  );
}

// ── WRITE ─────────────────────────────────────────────────────
function WriteScreen({ exam, essay, setEssay, credits, go, onAnalyze }) {
  const words = (essay.trim().match(/\S+/g) || []).length;
  const target = 250;
  const pct = Math.min(100, Math.round((words / target) * 100));
  const taRef = useRefH();
  const canAnalyze = words >= 20 && credits > 0;

  return (
    <div className="screen">
      <div className="safe-top" />
      <div className="appbar">
        <h1 className="h-screen">Write</h1>
        <button className="chip chip-primary" style={{ cursor: 'pointer', border: 'none', padding: '8px 12px', gap: 7 }} onClick={() => go('paywall')}>
          <Icon name="bolt" size={15} sw={2} fill="currentColor" />
          <span><b className="t-num">{credits}</b> credits</span>
        </button>
      </div>

      <div className="screen-pad rise">
        {/* prompt */}
        <div className="card card-pad" style={{ background: 'var(--bg-sunken)', boxShadow: 'none' }}>
          <div className="between" style={{ marginBottom: 8 }}>
            <Chip tone="primary">{exam.label} Task 2</Chip>
            <span className="t-sm row-gap" style={{ gap: 5 }}><Icon name="clock" size={14} sw={2.1} />40 min</span>
          </div>
          <p style={{ margin: 0, fontSize: 15, lineHeight: 1.5, fontWeight: 600, color: 'var(--ink)' }}>{TODAY_GOAL.prompt}</p>
        </div>

        {/* editor */}
        <div className="card" style={{ marginTop: 14, overflow: 'hidden' }}>
          <textarea
            ref={taRef}
            value={essay}
            onChange={(e) => setEssay(e.target.value)}
            placeholder="Start writing your response here…"
            spellCheck={false}
            style={{
              width: '100%', minHeight: 230, border: 'none', outline: 'none', resize: 'none',
              padding: 18, fontFamily: 'var(--ff)', fontSize: 15.5, lineHeight: 1.6, color: 'var(--ink)',
              background: 'transparent', display: 'block',
            }}
          />
          <div className="between" style={{ padding: '12px 16px', borderTop: '1px solid var(--line-2)', background: 'var(--bg)' }}>
            <div className="row-gap" style={{ gap: 10 }}>
              <span className="t-num" style={{ fontWeight: 700, fontSize: 15 }}>{words}</span>
              <span className="t-sm">/ {target} words</span>
            </div>
            <div style={{ width: 110 }}><Bar pct={pct} height={6} delay={0} color={words >= target ? 'var(--good)' : 'var(--primary)'} /></div>
          </div>
        </div>

        {!essay && (
          <button className="btn btn-soft btn-block" style={{ marginTop: 12, fontSize: 14 }} onClick={() => setEssay(SAMPLE_ESSAY)}>
            <Icon name="edit" size={16} sw={2} /> Load a sample essay
          </button>
        )}

        {/* writing tips */}
        <SecHead title="Writing tips" />
        <div className="card card-pad stack">
          {WRITING_TIPS.map((tip, i) => (
            <div key={i} className="row-gap" style={{ alignItems: 'flex-start', gap: 11 }}>
              <div style={{ width: 22, height: 22, borderRadius: 7, background: 'var(--primary-tint)', color: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', flex: 'none', marginTop: 1 }}>
                <Icon name="check" size={13} sw={2.6} />
              </div>
              <p className="t-body" style={{ fontSize: 14 }}>{tip}</p>
            </div>
          ))}
        </div>
        <div style={{ height: 150 }} />
      </div>

      {/* sticky CTA */}
      <div style={{ position: 'absolute', left: 0, right: 0, bottom: 'var(--tab-h)', padding: '20px 18px 14px', background: 'linear-gradient(transparent, var(--bg) 38%)', zIndex: 35 }}>
        <button className="btn btn-primary btn-block" disabled={!canAnalyze}
          style={{ opacity: canAnalyze ? 1 : 0.45 }} onClick={() => canAnalyze && onAnalyze()}>
          <Icon name="spark" size={19} sw={0} fill="currentColor" /> Analyze essay
          <span style={{ background: 'rgba(255,255,255,0.22)', borderRadius: 999, padding: '3px 9px', fontSize: 13 }} className="t-num">1 credit</span>
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { HomeScreen, WriteScreen, ACC, ACC_TINT, ACC_ICON, ChallengeMini });

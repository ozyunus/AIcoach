// screens_progress.jsx — Progress, AI Coach, Challenges
const { useState: useStateP } = React;

const ERR_PER_ESSAY = [4.4, 3.9, 3.6, 3.0, 2.7, 2.2, 1.9, 1.5];

// ── PROGRESS ──────────────────────────────────────────────────
function ProgressScreen({ exam, examKey, setExam, go }) {
  const [range, setRange] = useStateP('8w');
  const skills = SKILLS.map((s, i) => ({ ...s, name: exam.skills[i] }));
  const data = range === '4w' ? HEALTH.history.slice(4) : HEALTH.history;
  const labels = range === '4w' ? HEALTH.weeks.slice(4) : HEALTH.weeks;
  const examOpts = [{ value: 'ielts', label: 'IELTS' }, { value: 'toefl', label: 'TOEFL' }];

  return (
    <div className="screen">
      <div className="safe-top" />
      <div className="appbar">
        <h1 className="h-screen">Progress</h1>
        <Segmented options={examOpts} value={examKey} onChange={setExam} />
      </div>

      <div className="screen-pad rise">
        {/* score history */}
        <div className="card card-pad">
          <div className="between" style={{ marginBottom: 6 }}>
            <div>
              <div className="t-sm">Writing Health Score</div>
              <div className="row-gap" style={{ gap: 8, marginTop: 2 }}>
                <span className="t-num" style={{ fontSize: 34, fontWeight: 700, color: 'var(--primary)', lineHeight: 1 }}><CountUp value={HEALTH.score} /></span>
                <Delta value={HEALTH.delta} />
              </div>
            </div>
            <Segmented options={[{ value: '4w', label: '4 wks' }, { value: '8w', label: '8 wks' }]} value={range} onChange={setRange} />
          </div>
          <div style={{ marginTop: 8 }}>
            <TrendChart key={range} data={data} w={330} h={140} labels={labels} dots />
          </div>
        </div>

        {/* error trend */}
        <SecHead title="Error trend" />
        <div className="card card-pad">
          <div className="between">
            <div>
              <div className="t-sm">Mistakes per essay</div>
              <div className="row-gap" style={{ gap: 8, marginTop: 2 }}>
                <span className="t-num" style={{ fontSize: 28, fontWeight: 700, lineHeight: 1 }}>{ERR_PER_ESSAY[ERR_PER_ESSAY.length - 1]}</span>
                <Chip tone="good" icon={<Icon name="arrowDown" size={13} sw={2.6} />}>66% lower</Chip>
              </div>
            </div>
          </div>
          <div style={{ marginTop: 10 }}>
            <TrendChart data={ERR_PER_ESSAY} w={330} h={96} color="var(--good)" dots min={0} />
          </div>
          <div style={{ marginTop: 14, paddingTop: 14, borderTop: '1px solid var(--line-2)' }}>
            {MISTAKES.slice(0, 3).map((m, i) => (
              <div key={m.id} className="between" style={{ marginTop: i ? 12 : 0 }}>
                <span style={{ fontSize: 14, fontWeight: 500 }}>{m.label}</span>
                <div className="row-gap" style={{ gap: 10 }}>
                  <span className="t-sm t-num">{m.count}×</span>
                  <Delta value={m.trend} invertGood />
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* skill breakdown */}
        <SecHead title="Skill breakdown" />
        <div className="card card-pad stack">
          {skills.map((s, i) => (
            <div key={i}>
              <div className="between" style={{ marginBottom: 7 }}>
                <span style={{ fontSize: 14.5, fontWeight: 600 }}>{s.name}</span>
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

        {/* monthly overview */}
        <SecHead title={`${MONTHLY.month} overview`} />
        <div className="card card-pad">
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
            {[
              { n: MONTHLY.essays, l: 'Essays analyzed', icon: 'edit' },
              { n: '+' + MONTHLY.scoreChange, l: 'Health points', icon: 'trend', accent: 'good' },
              { n: Math.round(MONTHLY.minutes / 60) + 'h', l: 'Time writing', icon: 'clock' },
              { n: MONTHLY.bestSkill, l: 'Best skill', icon: 'star', small: true, accent: 'primary' },
            ].map((s, i) => (
              <div key={i} className="row-gap" style={{ gap: 11, alignItems: 'flex-start' }}>
                <div style={{ width: 36, height: 36, borderRadius: 10, flex: 'none', background: s.accent === 'good' ? 'var(--good-tint)' : 'var(--primary-tint)', color: s.accent === 'good' ? 'var(--good)' : 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <Icon name={s.icon} size={18} sw={2} fill={s.icon === 'star' ? 'currentColor' : 'none'} />
                </div>
                <div>
                  <div className="t-num" style={{ fontSize: s.small ? 14 : 22, fontWeight: 700, lineHeight: 1.1, color: s.accent === 'good' ? 'var(--good)' : 'var(--ink)', fontFamily: s.small ? 'var(--ff)' : 'var(--ff-num)' }}>{s.n}</div>
                  <div className="t-sm" style={{ marginTop: 2 }}>{s.l}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
      <div className="tab-safe" />
    </div>
  );
}

// ── AI COACH ──────────────────────────────────────────────────
const REC_TINT = { Vocabulary: 'var(--violet)', Task: 'var(--primary)' };
function CoachScreen({ go }) {
  return (
    <div className="screen">
      <div className="safe-top" />
      <div className="appbar">
        <div>
          <div className="t-sm" style={{ fontWeight: 600 }}>{COACH.week}</div>
          <h1 className="h-screen">AI Coach</h1>
        </div>
        <div style={{ width: 44, height: 44, borderRadius: 999, background: 'var(--primary)', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: 'var(--shadow-cta)' }}>
          <Icon name="spark" size={24} sw={0} fill="currentColor" />
        </div>
      </div>

      <div className="screen-pad rise">
        {/* weekly report */}
        <div className="card card-pad">
          <div className="row-gap" style={{ marginBottom: 12 }}>
            <Chip tone="primary" icon={<Icon name="spark" size={13} sw={0} fill="currentColor" />}>Weekly report</Chip>
          </div>
          <h2 style={{ margin: '0 0 10px', fontSize: 21, fontWeight: 800, letterSpacing: '-0.015em', lineHeight: 1.2 }}>{COACH.headline}</h2>
          <p className="t-body" style={{ fontSize: 14.5 }}>{COACH.summary}</p>
        </div>

        {/* focus area */}
        <div className="card card-pad" style={{ marginTop: 14, background: 'var(--violet)', color: '#fff', border: 'none' }}>
          <div className="between">
            <span className="h-eyebrow" style={{ color: 'rgba(255,255,255,0.82)' }}>Recommended focus</span>
            <Icon name="target" size={20} sw={2} style={{ opacity: 0.85 }} />
          </div>
          <div className="between" style={{ alignItems: 'flex-end', marginTop: 8 }}>
            <h3 style={{ margin: 0, fontSize: 22, fontWeight: 800 }}>{COACH.focus.skill}</h3>
            <span className="t-num" style={{ fontSize: 30, fontWeight: 700 }}>{COACH.focus.score}<span style={{ fontSize: 15, opacity: 0.7 }}>/100</span></span>
          </div>
          <p style={{ margin: '10px 0 0', fontSize: 13.5, lineHeight: 1.5, color: 'rgba(255,255,255,0.88)' }}>{COACH.focus.why}</p>
        </div>

        {/* key insights */}
        <SecHead title="Key insights" />
        <div className="card" style={{ overflow: 'hidden' }}>
          {COACH.insights.map((ins, i) => (
            <div key={i} className="row-gap" style={{ alignItems: 'flex-start', gap: 13, padding: '15px 16px', borderTop: i ? '1px solid var(--line-2)' : 'none' }}>
              <div style={{ width: 38, height: 38, borderRadius: 11, flex: 'none', background: 'var(--good-tint)', color: 'var(--good)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name={ins.icon} size={19} sw={2.1} />
              </div>
              <div>
                <div style={{ fontSize: 14.5, fontWeight: 700 }}>{ins.title}</div>
                <div className="t-sm" style={{ marginTop: 2 }}>{ins.body}</div>
              </div>
            </div>
          ))}
        </div>

        {/* recommendations */}
        <SecHead title="Recommended for you" />
        <div className="stack">
          {COACH.recommendations.map((r, i) => (
            <button key={i} className="card card-pad" onClick={() => go('write')} style={{ display: 'flex', alignItems: 'center', gap: 13, width: '100%', textAlign: 'left', appearance: 'none', cursor: 'pointer' }}>
              <div style={{ width: 42, height: 42, borderRadius: 12, flex: 'none', background: 'color-mix(in oklab, ' + (REC_TINT[r.tag] || 'var(--primary)') + ' 12%, #fff)', color: REC_TINT[r.tag] || 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name={r.tag === 'Vocabulary' ? 'book' : 'edit'} size={20} sw={2} />
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, fontWeight: 700 }}>{r.title}</div>
                <div className="t-sm" style={{ marginTop: 2 }}>{r.meta}</div>
              </div>
              <Icon name="chevR" size={18} sw={2.2} style={{ color: 'var(--ink-4)' }} />
            </button>
          ))}
        </div>

        {/* suggested topics */}
        <SecHead title="Suggested study topics" />
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 9 }}>
          {COACH.topics.map(t => (
            <button key={t} className="chip" style={{ cursor: 'pointer', border: '1px solid var(--line)', background: 'var(--card)', padding: '10px 14px', fontSize: 13.5 }} onClick={() => go('write')}>
              <Icon name="plus" size={13} sw={2.4} style={{ color: 'var(--primary)' }} />{t}
            </button>
          ))}
        </div>
      </div>
      <div className="tab-safe" />
    </div>
  );
}

// ── CHALLENGES ────────────────────────────────────────────────
function ChallengeCard({ c, frozen, onFreeze }) {
  const pct = Math.round((c.progress / c.total) * 100);
  const done = c.state === 'done';
  return (
    <div className="card card-pad">
      <div className="row-gap" style={{ alignItems: 'flex-start', gap: 13 }}>
        <div style={{ width: 46, height: 46, borderRadius: 13, flex: 'none', background: done ? 'var(--good-tint)' : ACC_TINT[c.accent], color: done ? 'var(--good)' : ACC[c.accent], display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name={done ? 'trophy' : ACC_ICON[c.kind]} size={23} sw={2} fill={c.kind === 'streak' && !done ? 'currentColor' : 'none'} />
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div className="between">
            <span style={{ fontSize: 15.5, fontWeight: 700 }}>{c.title}</span>
            {done
              ? <Chip tone="good" icon={<Icon name="check" size={12} sw={3} />}>Done</Chip>
              : <span className="chip" style={{ background: ACC_TINT[c.accent], color: ACC[c.accent], gap: 4 }}><Icon name="bolt" size={12} sw={2} fill="currentColor" />+{c.reward}</span>}
          </div>
          <p className="t-sm" style={{ marginTop: 4 }}>{c.desc}</p>
        </div>
      </div>

      <div style={{ marginTop: 14 }}>
        <div className="between" style={{ marginBottom: 7 }}>
          <span className="t-sm t-num" style={{ fontWeight: 600 }}>{c.progress} / {c.total} {c.unit}</span>
          <span className="t-num t-sm" style={{ fontWeight: 700, color: done ? 'var(--good)' : ACC[c.accent] }}>{pct}%</span>
        </div>
        <Bar pct={pct} height={9} color={done ? 'var(--good)' : ACC[c.accent]} />
      </div>

      {c.kind === 'streak' && !done && (
        <button onClick={onFreeze} className="btn btn-soft btn-block" style={{ marginTop: 14, fontSize: 14, gap: 8, color: frozen ? 'var(--primary)' : 'var(--ink-2)', background: frozen ? 'var(--primary-tint)' : 'var(--bg-sunken)' }}>
          <Icon name="snow" size={17} sw={2} />{frozen ? 'Streak frozen — safe for today' : 'Freeze challenge (1 left)'}
        </button>
      )}
    </div>
  );
}

function ChallengesScreen({ go }) {
  const [frozen, setFrozen] = useStateP(false);
  const active = CHALLENGES.filter(c => c.state === 'active');
  const done = CHALLENGES.filter(c => c.state === 'done');
  return (
    <div className="screen">
      <SubHeader title="Challenges" onBack={() => go('home')} />
      <div className="screen-pad rise" style={{ paddingTop: 2 }}>
        {/* streak banner */}
        <div className="card card-pad" style={{ background: 'var(--warn)', border: 'none', color: 'color-mix(in oklab, var(--warn) 32%, #000)' }}>
          <div className="between">
            <div>
              <div className="h-eyebrow" style={{ color: 'inherit', opacity: 0.8 }}>Current streak</div>
              <div className="row-gap" style={{ gap: 8, marginTop: 4 }}>
                <Icon name="flame" size={30} sw={1.6} fill="currentColor" />
                <span className="t-num" style={{ fontSize: 40, fontWeight: 700, lineHeight: 1 }}>{USER.streak}</span>
                <span style={{ fontSize: 15, fontWeight: 700, alignSelf: 'flex-end', marginBottom: 4 }}>days</span>
              </div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div className="t-num" style={{ fontSize: 13, fontWeight: 700 }}>Best: 9 days</div>
              <div style={{ fontSize: 12.5, opacity: 0.85, marginTop: 2 }}>Keep it alive!</div>
            </div>
          </div>
        </div>

        <SecHead title="Active challenges" />
        <div className="stack">
          {active.map(c => <ChallengeCard key={c.id} c={c} frozen={frozen} onFreeze={() => setFrozen(f => !f)} />)}
        </div>

        <SecHead title="Completed" />
        <div className="stack">
          {done.map(c => <ChallengeCard key={c.id} c={c} />)}
        </div>
      </div>
      <div className="tab-safe" style={{ height: 24 }} />
    </div>
  );
}

Object.assign(window, { ProgressScreen, CoachScreen, ChallengesScreen });

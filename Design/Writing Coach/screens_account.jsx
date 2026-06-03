// screens_account.jsx — Profile, Paywall, Analyzing transition
const { useState: useStateAc, useEffect: useEffectAc } = React;

// ── ANALYZING (transition) ────────────────────────────────────
const STEPS = ['Reading your essay', 'Checking grammar & syntax', 'Scoring lexical range', 'Estimating exam band'];
function AnalyzingScreen({ onDone }) {
  const [step, setStep] = useStateAc(0);
  useEffectAc(() => {
    const total = window.__noMotion ? 200 : 2600;
    const per = total / STEPS.length;
    const timers = STEPS.map((_, i) => setTimeout(() => setStep(i + 1), per * (i + 1)));
    const done = setTimeout(onDone, total + 250);
    return () => { timers.forEach(clearTimeout); clearTimeout(done); };
  }, []);
  return (
    <div className="screen" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 30 }}>
      <div style={{ position: 'relative', width: 96, height: 96, marginBottom: 30 }}>
        <div style={{ position: 'absolute', inset: 0, borderRadius: 999, border: '4px solid var(--primary-tint-2)', borderTopColor: 'var(--primary)', animation: 'spin 900ms linear infinite' }} />
        <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--primary)' }}>
          <Icon name="spark" size={36} sw={0} fill="currentColor" />
        </div>
      </div>
      <h2 style={{ margin: '0 0 6px', fontSize: 21, fontWeight: 800 }}>Analyzing your essay</h2>
      <p className="t-sm" style={{ marginBottom: 28 }}>Your coach is reading carefully…</p>
      <div style={{ width: '100%', maxWidth: 280 }}>
        {STEPS.map((s, i) => {
          const state = i < step ? 'done' : i === step ? 'active' : 'todo';
          return (
            <div key={i} className="row-gap" style={{ gap: 11, padding: '9px 0', opacity: state === 'todo' ? 0.4 : 1, transition: 'opacity 300ms' }}>
              <div style={{ width: 24, height: 24, borderRadius: 999, flex: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', background: state === 'done' ? 'var(--good)' : state === 'active' ? 'var(--primary-tint)' : 'var(--bg-sunken)', color: state === 'done' ? '#fff' : 'var(--primary)' }}>
                {state === 'done' ? <Icon name="check" size={14} sw={3} />
                  : state === 'active' ? <div style={{ width: 9, height: 9, borderRadius: 999, background: 'var(--primary)', animation: 'pulse 900ms ease-in-out infinite' }} />
                  : <div style={{ width: 7, height: 7, borderRadius: 999, background: 'var(--ink-4)' }} />}
              </div>
              <span style={{ fontSize: 14.5, fontWeight: state === 'active' ? 700 : 500, color: state === 'todo' ? 'var(--ink-3)' : 'var(--ink)' }}>{s}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ── PROFILE ───────────────────────────────────────────────────
function StatBox({ n, label, icon, fill }) {
  return (
    <div className="card card-pad" style={{ textAlign: 'center', padding: '16px 8px' }}>
      <div style={{ color: 'var(--primary)', display: 'flex', justifyContent: 'center', marginBottom: 6 }}>
        <Icon name={icon} size={20} sw={2} fill={fill ? 'currentColor' : 'none'} />
      </div>
      <div className="t-num" style={{ fontSize: 24, fontWeight: 700, lineHeight: 1 }}>{n}</div>
      <div className="t-sm" style={{ marginTop: 3 }}>{label}</div>
    </div>
  );
}

function Row({ icon, label, detail, onClick, danger, last }) {
  return (
    <button onClick={onClick} style={{ display: 'flex', alignItems: 'center', gap: 13, width: '100%', textAlign: 'left', appearance: 'none', border: 'none', background: 'none', cursor: 'pointer', padding: '14px 16px', borderTop: last ? 'none' : undefined }}>
      <div style={{ width: 32, height: 32, borderRadius: 9, flex: 'none', background: danger ? 'var(--bad-tint)' : 'var(--bg-sunken)', color: danger ? 'var(--bad)' : 'var(--ink-2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Icon name={icon} size={17} sw={2} />
      </div>
      <span style={{ flex: 1, fontSize: 15, fontWeight: 600, color: danger ? 'var(--bad)' : 'var(--ink)' }}>{label}</span>
      {detail && <span className="t-sm">{detail}</span>}
      {!danger && <Icon name="chevR" size={16} sw={2.2} style={{ color: 'var(--ink-4)' }} />}
    </button>
  );
}

function ProfileScreen({ exam, credits, go }) {
  return (
    <div className="screen">
      <div className="safe-top" />
      <div className="appbar"><h1 className="h-screen">Profile</h1></div>

      <div className="screen-pad rise">
        {/* identity */}
        <div className="card card-pad row-gap" style={{ gap: 15 }}>
          <Avatar initials={USER.initials} size={62} />
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 19, fontWeight: 800 }}>{USER.fullName}</div>
            <div className="t-sm" style={{ marginTop: 1 }}>@{USER.name.toLowerCase()} · joined {USER.joined}</div>
            <div className="row-gap" style={{ gap: 7, marginTop: 8 }}>
              <Chip tone="primary">{exam.label} · {exam.scoreLabel} {exam.fmt(exam.current)}</Chip>
              <Chip>{USER.plan}</Chip>
            </div>
          </div>
        </div>

        {/* credits */}
        <div className="card card-pad between" style={{ marginTop: 14, background: 'var(--primary)', color: '#fff', border: 'none' }}>
          <div>
            <div className="h-eyebrow" style={{ color: 'rgba(255,255,255,0.82)' }}>Credit balance</div>
            <div className="row-gap" style={{ gap: 8, marginTop: 4 }}>
              <Icon name="bolt" size={26} sw={0} fill="currentColor" />
              <span className="t-num" style={{ fontSize: 36, fontWeight: 700, lineHeight: 1 }}>{credits}</span>
              <span style={{ alignSelf: 'flex-end', marginBottom: 4, fontWeight: 600, opacity: 0.85 }}>credits</span>
            </div>
          </div>
          <button className="btn" style={{ background: '#fff', color: 'var(--primary)', padding: '12px 18px', fontSize: 14.5 }} onClick={() => go('paywall')}>Get more</button>
        </div>

        {/* stats */}
        <SecHead title="Your stats" />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12 }}>
          <StatBox n={USER.essaysAnalyzed} label="Essays" icon="edit" />
          <StatBox n={USER.streak} label="Streak" icon="flame" fill />
          <StatBox n={USER.avgScore} label="Avg score" icon="star" fill />
        </div>

        {/* settings */}
        <SecHead title="Account" />
        <div className="card" style={{ overflow: 'hidden' }}>
          <Row icon="bolt" label="Purchase history" detail="3 orders" onClick={() => go('paywall')} last />
          <div style={{ height: 1, background: 'var(--line-2)', marginLeft: 61 }} />
          <Row icon="target" label="Exam & goal" detail={`${exam.label} ${exam.fmt(exam.goal)}`} onClick={() => go('home')} />
          <div style={{ height: 1, background: 'var(--line-2)', marginLeft: 61 }} />
          <Row icon="clock" label="Reminders" detail="Daily 9:00" onClick={() => {}} />
        </div>

        <div className="card" style={{ overflow: 'hidden', marginTop: 14 }}>
          <Row icon="shield" label="Privacy & data" onClick={() => {}} last />
          <div style={{ height: 1, background: 'var(--line-2)', marginLeft: 61 }} />
          <Row icon="info" label="Help & support" onClick={() => {}} />
          <div style={{ height: 1, background: 'var(--line-2)', marginLeft: 61 }} />
          <Row icon="x" label="Sign out" danger onClick={() => {}} />
        </div>

        <p className="t-sm" style={{ textAlign: 'center', marginTop: 18 }}>Writing Coach · v1.0.0</p>
      </div>
      <div className="tab-safe" />
    </div>
  );
}

// ── PAYWALL ───────────────────────────────────────────────────
function Pack({ p, selected, onSelect }) {
  return (
    <button onClick={onSelect} style={{
      position: 'relative', display: 'block', width: '100%', textAlign: 'left', cursor: 'pointer', appearance: 'none',
      borderRadius: 'var(--r-card)', padding: '16px 18px',
      border: selected ? '2px solid var(--primary)' : '2px solid var(--line)',
      background: selected ? 'var(--primary-soft)' : 'var(--card)',
      boxShadow: selected ? 'var(--shadow-card)' : 'none', transition: 'all 160ms var(--ease)',
    }}>
      {p.tag && <span style={{ position: 'absolute', top: -10, right: 16, background: p.accent ? 'var(--primary)' : 'var(--violet)', color: '#fff', fontSize: 11, fontWeight: 700, padding: '3px 10px', borderRadius: 999 }}>{p.tag}</span>}
      <div className="between">
        <div className="row-gap" style={{ gap: 13 }}>
          <div style={{ width: 22, height: 22, borderRadius: 999, flex: 'none', border: selected ? 'none' : '2px solid var(--line)', background: selected ? 'var(--primary)' : 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff' }}>
            {selected && <Icon name="check" size={13} sw={3} />}
          </div>
          <div>
            <div className="row-gap" style={{ gap: 7 }}>
              <span className="t-num" style={{ fontSize: 20, fontWeight: 700 }}>{p.credits}</span>
              <span style={{ fontSize: 15, fontWeight: 700 }}>essays</span>
              {p.save && <Chip tone="good" style={{ padding: '2px 8px', fontSize: 11 }}>{p.save}</Chip>}
            </div>
            <div className="t-sm" style={{ marginTop: 2 }}>{p.per}</div>
          </div>
        </div>
        <div className="t-num" style={{ fontSize: 19, fontWeight: 700 }}>{p.price}</div>
      </div>
    </button>
  );
}

function PaywallScreen({ go, onPurchase }) {
  const [sel, setSel] = useStateAc('p10');
  const [phase, setPhase] = useStateAc('idle'); // idle | sheet | processing | success
  const pack = PACKS.find(p => p.id === sel);

  const confirm = () => {
    setPhase('processing');
    setTimeout(() => { setPhase('success'); onPurchase(pack.credits); }, window.__noMotion ? 200 : 1600);
  };

  return (
    <div className="screen" style={{ background: 'var(--bg)' }}>
      <SubHeader title="Get credits" onBack={() => go('home')}
        trailing={<button onClick={() => go('home')} style={{ appearance: 'none', border: 'none', background: 'none', cursor: 'pointer', color: 'var(--ink-3)', fontSize: 13.5, fontWeight: 600 }}>Restore</button>} />

      <div className="screen-pad rise" style={{ paddingTop: 2 }}>
        <div style={{ textAlign: 'center', padding: '4px 6px 8px' }}>
          <div style={{ width: 64, height: 64, margin: '0 auto 14px', borderRadius: 20, background: 'var(--primary)', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: 'var(--shadow-cta)' }}>
            <Icon name="bolt" size={32} sw={0} fill="currentColor" />
          </div>
          <h2 style={{ margin: '0 0 6px', fontSize: 23, fontWeight: 800, letterSpacing: '-0.02em' }}>Keep improving</h2>
          <p className="t-body" style={{ fontSize: 14.5 }}>1 credit = 1 full essay analysis. No subscription — buy what you need.</p>
        </div>

        <div className="stack" style={{ marginTop: 18 }}>
          {PACKS.map(p => <Pack key={p.id} p={p} selected={sel === p.id} onSelect={() => setSel(p.id)} />)}
        </div>

        <div className="card card-pad" style={{ marginTop: 16, background: 'var(--bg-sunken)', boxShadow: 'none' }}>
          {PERKS.map((perk, i) => (
            <div key={i} className="row-gap" style={{ gap: 10, marginTop: i ? 11 : 0 }}>
              <Icon name="checkCircle" size={19} sw={2} style={{ color: 'var(--good)', flex: 'none' }} />
              <span style={{ fontSize: 14, fontWeight: 500 }}>{perk}</span>
            </div>
          ))}
        </div>
        <p className="t-sm" style={{ textAlign: 'center', marginTop: 14 }}>Secured by RevenueCat · Restore anytime</p>
      </div>

      {/* sticky buy */}
      <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, padding: '14px 18px 22px', background: 'linear-gradient(transparent, var(--bg) 28%)', zIndex: 35 }}>
        <button className="btn btn-primary btn-block" onClick={() => setPhase('sheet')}>
          Continue · {pack.price}
        </button>
      </div>

      {/* RevenueCat-style purchase sheet */}
      {phase !== 'idle' && (
        <div style={{ position: 'absolute', inset: 0, zIndex: 60, display: 'flex', alignItems: 'flex-end' }}>
          <div onClick={() => phase === 'sheet' && setPhase('idle')} style={{ position: 'absolute', inset: 0, background: 'rgba(15,18,30,0.42)', animation: 'scrim 240ms ease both' }} />
          <div style={{ position: 'relative', width: '100%', background: 'var(--card)', borderRadius: '26px 26px 0 0', padding: '10px 22px calc(env(safe-area-inset-bottom) + 26px)', animation: 'sheetUp 320ms var(--ease) both' }}>
            <div style={{ width: 40, height: 5, borderRadius: 999, background: 'var(--line)', margin: '0 auto 18px' }} />
            {phase === 'success' ? (
              <div style={{ textAlign: 'center', padding: '8px 0 4px' }}>
                <div style={{ width: 62, height: 62, margin: '0 auto 14px', borderRadius: 999, background: 'var(--good-tint)', color: 'var(--good)', display: 'flex', alignItems: 'center', justifyContent: 'center', animation: 'popIn 320ms var(--ease) both' }}>
                  <Icon name="check" size={32} sw={3} />
                </div>
                <h3 style={{ margin: '0 0 6px', fontSize: 20, fontWeight: 800 }}>Purchase complete</h3>
                <p className="t-body" style={{ fontSize: 14 }}>{pack.credits} credits added to your account.</p>
                <button className="btn btn-primary btn-block" style={{ marginTop: 20 }} onClick={() => { setPhase('idle'); go('write'); }}>Start writing</button>
              </div>
            ) : (
              <>
                <div className="between" style={{ paddingBottom: 14, borderBottom: '1px solid var(--line-2)' }}>
                  <div className="row-gap" style={{ gap: 12 }}>
                    <div style={{ width: 44, height: 44, borderRadius: 12, background: 'var(--primary-tint)', color: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="bolt" size={22} sw={0} fill="currentColor" /></div>
                    <div>
                      <div style={{ fontSize: 15, fontWeight: 700 }}>{pack.credits} Essay Pack</div>
                      <div className="t-sm">Writing Coach</div>
                    </div>
                  </div>
                  <div className="t-num" style={{ fontSize: 18, fontWeight: 700 }}>{pack.price}</div>
                </div>
                <div className="between" style={{ padding: '14px 0' }}>
                  <span className="t-sm">Account</span>
                  <span style={{ fontSize: 13.5, fontWeight: 600 }}>amara@icloud.com</span>
                </div>
                <button className="btn btn-primary btn-block" disabled={phase === 'processing'} onClick={confirm} style={{ opacity: phase === 'processing' ? 0.7 : 1 }}>
                  {phase === 'processing'
                    ? <><div style={{ width: 18, height: 18, borderRadius: 999, border: '2.5px solid rgba(255,255,255,0.4)', borderTopColor: '#fff', animation: 'spin 800ms linear infinite' }} /> Processing…</>
                    : <><Icon name="lock" size={16} sw={2.2} /> Confirm with Face ID</>}
                </button>
                <p className="t-sm" style={{ textAlign: 'center', marginTop: 12 }}>Double-click the side button to pay</p>
              </>
            )}
          </div>
        </div>
      )}
      <div className="tab-safe" style={{ height: 90 }} />
    </div>
  );
}

Object.assign(window, { AnalyzingScreen, ProfileScreen, PaywallScreen });

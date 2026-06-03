// app.jsx — root: routing, transitions, exam state, tweaks, mount
const { useState: useStateApp, useEffect: useEffectApp } = React;

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "primary": "#2f5fe0",
  "exam": "ielts",
  "healthViz": "number",
  "motion": true
}/*EDITMODE-END*/;

const PRIMARY_OPTS = ['#2f5fe0', '#4f46e5', '#0d9488', '#7c3aed'];
const TABS_SET = ['home', 'progress', 'coach', 'profile', 'write'];
const PUSH_SET = ['analysis', 'error', 'challenges', 'paywall', 'analyzing'];

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
  const [screen, setScreen] = useStateApp('home');
  const [essay, setEssay] = useStateApp('');
  const [credits, setCredits] = useStateApp(USER.credits);

  const exam = EXAMS[t.exam] || EXAMS.ielts;

  // apply theme + motion globally
  useEffectApp(() => {
    document.documentElement.style.setProperty('--primary', t.primary);
    window.__noMotion = !t.motion;
  }, [t.primary, t.motion]);

  const go = (s) => {
    if (s === screen) { document.querySelector('.screen')?.scrollTo({ top: 0 }); return; }
    setScreen(s);
  };

  const onAnalyze = () => {
    setCredits(c => Math.max(0, c - 1));
    setScreen('analyzing');
  };
  const onPurchase = (n) => setCredits(c => c + n);

  const showTab = TABS_SET.includes(screen);
  const examProps = { exam, examKey: t.exam, setExam: (v) => setTweak('exam', v) };

  let view;
  switch (screen) {
    case 'home': view = <HomeScreen {...examProps} healthViz={t.healthViz} go={go} />; break;
    case 'write': view = <WriteScreen exam={exam} essay={essay} setEssay={setEssay} credits={credits} go={go} onAnalyze={onAnalyze} />; break;
    case 'analyzing': view = <AnalyzingScreen onDone={() => setScreen('analysis')} />; break;
    case 'analysis': view = <AnalysisScreen {...examProps} go={go} />; break;
    case 'error': view = <ErrorScreen go={go} />; break;
    case 'progress': view = <ProgressScreen {...examProps} go={go} />; break;
    case 'coach': view = <CoachScreen go={go} />; break;
    case 'challenges': view = <ChallengesScreen go={go} />; break;
    case 'profile': view = <ProfileScreen exam={exam} credits={credits} go={go} />; break;
    case 'paywall': view = <PaywallScreen go={go} onPurchase={onPurchase} />; break;
    default: view = <HomeScreen {...examProps} healthViz={t.healthViz} go={go} />;
  }

  const animClass = PUSH_SET.includes(screen) && screen !== 'analyzing' ? 'anim-push' : 'anim-fade';

  return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 22 }}>
      <IOSDevice>
        <div className={`app ${t.motion ? '' : 'no-motion'}`}>
          <div key={screen} className={animClass} style={{ position: 'absolute', inset: 0 }}>
            {view}
          </div>
          {showTab && <TabBar active={screen} onNav={go} />}
        </div>
      </IOSDevice>

      <TweaksPanel>
        <TweakSection label="Brand" />
        <TweakColor label="Accent" value={t.primary} options={PRIMARY_OPTS} onChange={(v) => setTweak('primary', v)} />
        <TweakSection label="Content" />
        <TweakRadio label="Exam" value={t.exam} options={[{ value: 'ielts', label: 'IELTS' }, { value: 'toefl', label: 'TOEFL' }]} onChange={(v) => setTweak('exam', v)} />
        <TweakRadio label="Health score" value={t.healthViz} options={[{ value: 'number', label: 'Number' }, { value: 'ring', label: 'Ring' }, { value: 'bar', label: 'Bar' }]} onChange={(v) => setTweak('healthViz', v)} />
        <TweakSection label="Motion" />
        <TweakToggle label="Animations" value={t.motion} onChange={(v) => setTweak('motion', v)} />
      </TweaksPanel>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);

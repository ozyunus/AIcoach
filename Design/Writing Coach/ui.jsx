// ui.jsx — shared primitives (exported to window)
const { useState, useEffect, useRef, useMemo } = React;

// ── icon set (clean line icons, currentColor) ─────────────────
const PATHS = {
  home: <path d="M3 10.5 12 3l9 7.5M5.5 9V20h13V9" />,
  pen: <g><path d="M14.5 5.5l4 4M4 20l1-4L16 5a2.1 2.1 0 0 1 3 3L8 19l-4 1Z" /></g>,
  chart: <g><path d="M4 20h16" /><path d="M7 20v-6M12 20V8M17 20v-9" /></g>,
  coach: <g><circle cx="12" cy="12" r="8.5" /><path d="M12 7v5l3 2" /></g>,
  user: <g><circle cx="12" cy="8.5" r="3.7" /><path d="M5 20a7 7 0 0 1 14 0" /></g>,
  spark: <path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8L12 3Z" />,
  flame: <path d="M12 3s5 4 5 9a5 5 0 0 1-10 0c0-1.6.8-2.8 1.6-3.6C9 10 9 12 11 12c0-3 1-5 1-9Z" />,
  bolt: <path d="M13 2 4 14h6l-1 8 9-12h-6l1-8Z" />,
  target: <g><circle cx="12" cy="12" r="8.5" /><circle cx="12" cy="12" r="4.4" /><circle cx="12" cy="12" r="0.6" fill="currentColor" /></g>,
  clock: <g><circle cx="12" cy="12" r="8.5" /><path d="M12 7v5l3.5 2" /></g>,
  trend: <g><path d="M3 17l5-5 4 3 8-8" /><path d="M16 7h5v5" /></g>,
  book: <path d="M4 5.5A2 2 0 0 1 6 4h6v15H6a2 2 0 0 0-2 1.5ZM12 4h6a2 2 0 0 1 2 2v12.5a2 2 0 0 0-2-1.5h-6" />,
  check: <path d="M5 12.5l4.5 4.5L19 6.5" />,
  checkCircle: <g><circle cx="12" cy="12" r="8.5" /><path d="M8.5 12.2l2.4 2.4L16 9.5" /></g>,
  plus: <path d="M12 5v14M5 12h14" />,
  lock: <g><rect x="5" y="10.5" width="14" height="9.5" rx="2.4" /><path d="M8 10.5V8a4 4 0 0 1 8 0v2.5" /></g>,
  chevR: <path d="M9 5l7 7-7 7" />,
  chevL: <path d="M15 5l-7 7 7 7" />,
  arrowUp: <path d="M12 19V5M6 11l6-6 6 6" />,
  arrowDown: <path d="M12 5v14M6 13l6 6 6-6" />,
  x: <path d="M6 6l12 12M18 6 6 18" />,
  info: <g><circle cx="12" cy="12" r="8.5" /><path d="M12 11v5M12 8h.01" /></g>,
  snow: <g><path d="M12 2v20M4 7l16 10M20 7 4 17" /><path d="M12 5l-2.2-2M12 5l2.2-2M12 19l-2.2 2M12 19l2.2 2" /></g>,
  trophy: <g><path d="M7 4h10v3a5 5 0 0 1-10 0Z" /><path d="M7 5H4v1a3 3 0 0 0 3 3M17 5h3v1a3 3 0 0 1-3 3M10 13h4M9 20h6M12 13v4" /></g>,
  bulb: <g><path d="M9 17h6M10 20h4" /><path d="M12 3a6 6 0 0 1 4 10.5c-.7.7-1 1.2-1 2.5H9c0-1.3-.3-1.8-1-2.5A6 6 0 0 1 12 3Z" /></g>,
  edit: <path d="M4 20l1-4L16 5l3 3L8 19l-4 1ZM14 7l3 3" />,
  arrowRight: <path d="M5 12h14M13 6l6 6-6 6" />,
  star: <path d="M12 3.5l2.6 5.3 5.9.9-4.3 4.1 1 5.8-5.2-2.7-5.2 2.7 1-5.8L3.5 9.7l5.9-.9Z" />,
  shield: <path d="M12 3l7 2.5v5.5c0 5-3.4 8-7 9.5-3.6-1.5-7-4.5-7-9.5V5.5Z" />,
  refresh: <g><path d="M20 11a8 8 0 0 0-14-4.5L4 8" /><path d="M4 4v4h4" /><path d="M4 13a8 8 0 0 0 14 4.5L20 16" /><path d="M20 20v-4h-4" /></g>,
};
function Icon({ name, size = 22, sw = 2, fill = 'none', style, ...rest }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill={fill}
      stroke="currentColor" strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round"
      style={{ flex: 'none', ...style }} {...rest}>
      {PATHS[name]}
    </svg>
  );
}

// ── animated count-up ─────────────────────────────────────────
function useCountUp(target, { dur = 1000, decimals = 0 } = {}) {
  const [v, setV] = useState(window.__noMotion ? target : 0);
  const ref = useRef();
  useEffect(() => {
    if (window.__noMotion) { setV(target); return; }
    const start = performance.now();
    cancelAnimationFrame(ref.current);
    const tick = (now) => {
      const p = Math.min(1, (now - start) / dur);
      const e = 1 - Math.pow(1 - p, 3);
      setV(target * e);
      if (p < 1) ref.current = requestAnimationFrame(tick);
      else setV(target);
    };
    ref.current = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(ref.current);
  }, [target]);
  return decimals ? v.toFixed(decimals) : Math.round(v);
}
function CountUp({ value, decimals = 0, dur = 1000, suffix = '' }) {
  const v = useCountUp(value, { dur, decimals });
  return <span className="t-num">{v}{suffix}</span>;
}

// ── delayed mount flag (for triggering CSS fills) ─────────────
function useReveal(delay = 60) {
  const [on, setOn] = useState(false);
  useEffect(() => { const t = setTimeout(() => setOn(true), window.__noMotion ? 0 : delay); return () => clearTimeout(t); }, []);
  return on;
}

// ── progress bar ──────────────────────────────────────────────
function Bar({ pct, color = 'var(--primary)', track, height = 9, delay = 120 }) {
  const on = useReveal(delay);
  return (
    <div className="bar-track" style={{ height, background: track }}>
      <div className="bar-fill" style={{ width: on ? `${Math.max(0, Math.min(100, pct))}%` : 0, background: color }} />
    </div>
  );
}

// ── score ring ────────────────────────────────────────────────
function Ring({ value, max = 100, size = 132, sw = 12, color = 'var(--primary)', track = 'var(--bg-sunken)', children }) {
  const r = (size - sw) / 2;
  const c = 2 * Math.PI * r;
  const on = useReveal(80);
  const pct = Math.max(0, Math.min(1, value / max));
  return (
    <div style={{ position: 'relative', width: size, height: size }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={track} strokeWidth={sw} />
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={color} strokeWidth={sw}
          strokeLinecap="round" strokeDasharray={c}
          strokeDashoffset={on ? c * (1 - pct) : c}
          style={{ transition: 'stroke-dashoffset 1100ms var(--ease)' }} />
      </svg>
      <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
        {children}
      </div>
    </div>
  );
}

// ── trend / spark chart ───────────────────────────────────────
function TrendChart({ data, w = 320, h = 120, color = 'var(--primary)', pad = 10, dots = false, area = true, labels = null, highlightLast = true, min, max }) {
  const id = useMemo(() => 'g' + Math.random().toString(36).slice(2, 7), []);
  const on = useReveal(120);
  const lo = min != null ? min : Math.min(...data) - 4;
  const hi = max != null ? max : Math.max(...data) + 4;
  const innerW = w - pad * 2, innerH = h - pad * 2 - (labels ? 16 : 0);
  const pts = data.map((d, i) => {
    const x = pad + (i / (data.length - 1)) * innerW;
    const y = pad + innerH - ((d - lo) / (hi - lo)) * innerH;
    return [x, y];
  });
  const line = pts.map((p, i) => `${i ? 'L' : 'M'}${p[0].toFixed(1)} ${p[1].toFixed(1)}`).join(' ');
  const areaPath = `${line} L${pts[pts.length - 1][0].toFixed(1)} ${pad + innerH} L${pad} ${pad + innerH} Z`;
  const last = pts[pts.length - 1];
  const len = 700;
  return (
    <svg width="100%" viewBox={`0 0 ${w} ${h}`} style={{ display: 'block', overflow: 'visible' }}>
      <defs>
        <linearGradient id={id} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={color} stopOpacity="0.22" />
          <stop offset="100%" stopColor={color} stopOpacity="0" />
        </linearGradient>
      </defs>
      {area && <path d={areaPath} fill={`url(#${id})`} style={{ opacity: on ? 1 : 0, transition: 'opacity 700ms 400ms' }} />}
      <path d={line} fill="none" stroke={color} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round"
        className="spark-path" strokeDasharray={len} strokeDashoffset={on ? 0 : len} />
      {dots && pts.map((p, i) => (
        <circle key={i} cx={p[0]} cy={p[1]} r={i === pts.length - 1 && highlightLast ? 4.5 : 2.6}
          fill={i === pts.length - 1 && highlightLast ? color : '#fff'} stroke={color} strokeWidth="2"
          style={{ opacity: on ? 1 : 0, transition: `opacity 300ms ${300 + i * 60}ms` }} />
      ))}
      {highlightLast && !dots && (
        <circle cx={last[0]} cy={last[1]} r="4.5" fill={color} stroke="#fff" strokeWidth="2.5"
          style={{ opacity: on ? 1 : 0, transition: 'opacity 400ms 900ms' }} />
      )}
      {labels && labels.map((l, i) => (
        <text key={i} x={pad + (i / (labels.length - 1)) * innerW} y={h - 2}
          textAnchor="middle" fontSize="9.5" fontFamily="var(--ff-num)"
          fill="var(--ink-4)" fontWeight="600">{l}</text>
      ))}
    </svg>
  );
}

// ── segmented control ─────────────────────────────────────────
function Segmented({ options, value, onChange, full }) {
  const ref = useRef();
  const idx = options.findIndex(o => (o.value ?? o) === value);
  const [thumb, setThumb] = useState({ left: 3, width: 0 });
  useEffect(() => {
    const el = ref.current; if (!el) return;
    const btns = el.querySelectorAll('button');
    const b = btns[idx]; if (!b) return;
    setThumb({ left: b.offsetLeft, width: b.offsetWidth });
  }, [idx, options.length]);
  return (
    <div className="seg" ref={ref} style={full ? { display: 'flex', width: '100%' } : {}}>
      <div className="seg-thumb" style={{ left: thumb.left, width: thumb.width }} />
      {options.map((o) => {
        const v = o.value ?? o, label = o.label ?? o;
        return (
          <button key={v} className={v === value ? 'on' : ''} style={full ? { flex: 1 } : {}}
            onClick={() => onChange(v)}>{label}</button>
        );
      })}
    </div>
  );
}

// ── chip / delta ──────────────────────────────────────────────
function Chip({ tone = '', icon, children, style }) {
  return <span className={`chip ${tone ? 'chip-' + tone : ''}`} style={style}>{icon}{children}</span>;
}
function Delta({ value, suffix = '', invertGood = false }) {
  const up = value >= 0;
  const good = invertGood ? !up : up;
  return (
    <span className="t-num" style={{
      display: 'inline-flex', alignItems: 'center', gap: 2, fontSize: 12.5, fontWeight: 700,
      color: good ? 'color-mix(in oklab, var(--good) 78%, #000)' : 'color-mix(in oklab, var(--bad) 78%, #000)',
    }}>
      <Icon name={up ? 'arrowUp' : 'arrowDown'} size={13} sw={2.6} />
      {Math.abs(value)}{suffix}
    </span>
  );
}

// ── avatar ────────────────────────────────────────────────────
function Avatar({ initials = 'AO', size = 40 }) {
  return <div className="avatar" style={{ width: size, height: size, fontSize: size * 0.38 }}>{initials}</div>;
}

// ── reusable section header ───────────────────────────────────
function SecHead({ title, action, onAction }) {
  return (
    <div className="sec-head">
      <h3 className="h-sec">{title}</h3>
      {action && <span className="link" onClick={onAction} style={{ cursor: 'pointer' }}>{action}</span>}
    </div>
  );
}

// ── tab bar ───────────────────────────────────────────────────
const TABS = [
  { id: 'home', icon: 'home', label: 'Home' },
  { id: 'progress', icon: 'chart', label: 'Progress' },
  { id: 'write', icon: 'pen', label: 'Write', center: true },
  { id: 'coach', icon: 'coach', label: 'Coach' },
  { id: 'profile', icon: 'user', label: 'Profile' },
];
function TabBar({ active, onNav }) {
  return (
    <div className="tabbar">
      {TABS.map(t => {
        const on = active === t.id;
        if (t.center) {
          return (
            <button key={t.id} className="tab" onClick={() => onNav('write')}>
              <div className="tab-write"><Icon name="pen" size={22} sw={2.2} /></div>
              <span className="tlabel" style={{ color: 'var(--ink-4)' }}>{t.label}</span>
            </button>
          );
        }
        return (
          <button key={t.id} className={`tab ${on ? 'on' : ''}`} onClick={() => onNav(t.id)}>
            <Icon name={t.icon} size={23} sw={on ? 2.3 : 2} />
            <span className="tlabel">{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

Object.assign(window, {
  Icon, useCountUp, CountUp, useReveal, Bar, Ring, TrendChart,
  Segmented, Chip, Delta, Avatar, SecHead, TabBar,
});

// data.jsx — mock content, exam config, helpers (exported to window)

// ── exam configuration ───────────────────────────────────────
const EXAMS = {
  ielts: {
    key: 'ielts',
    label: 'IELTS',
    scoreLabel: 'Band',
    current: 6.5,
    goal: 7.5,
    max: 9,
    fmt: (b) => b.toFixed(1),
    // map normalized 0-100 health score → band
    toBand: (n) => Math.round((4 + (n / 100) * 5) * 2) / 2,
    skills: ['Task Achievement', 'Coherence & Cohesion', 'Lexical Resource', 'Grammar Range'],
  },
  toefl: {
    key: 'toefl',
    label: 'TOEFL',
    scoreLabel: 'Score',
    current: 24,
    goal: 28,
    max: 30,
    fmt: (s) => String(Math.round(s)),
    toBand: (n) => Math.round(18 + (n / 100) * 12),
    skills: ['Task Response', 'Coherence & Cohesion', 'Lexical Resource', 'Grammar Range'],
  },
};

// ── the writer ────────────────────────────────────────────────
const USER = {
  name: 'Amara',
  fullName: 'Amara Okafor',
  initials: 'AO',
  credits: 12,
  streak: 5,
  essaysAnalyzed: 47,
  avgScore: 74,
  joined: 'Mar 2026',
  plan: 'Free',
};

// Writing Health Score (normalized 0-100)
const HEALTH = {
  score: 78,
  prev: 71,
  delta: +7,
  // 8-week history of the normalized score
  history: [58, 61, 60, 66, 64, 71, 74, 78],
  weeks: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'Now'],
};

// per-skill normalized scores (0-100)
const SKILLS = [
  { name: 'Task Achievement', short: 'Task', score: 81, delta: +5 },
  { name: 'Coherence & Cohesion', short: 'Coherence', score: 79, delta: +3 },
  { name: 'Lexical Resource', short: 'Vocabulary', score: 68, delta: +9, focus: true },
  { name: 'Grammar Range', short: 'Grammar', score: 84, delta: +2 },
];

const TODAY_GOAL = {
  task: 'Write 1 Task 2 essay',
  prompt: 'Some people believe technology has made our lives too complex. To what extent do you agree?',
  minutes: 40,
  done: false,
};

const LAST_ESSAY = {
  title: 'Public transport & city design',
  type: 'IELTS Task 2',
  normalized: 76,
  band: 6.5,
  toefl: 24,
  date: '2 days ago',
  words: 284,
};

// recurring mistakes (frequency-ranked)
const MISTAKES = [
  { id: 'art', label: 'Article usage (a / an / the)', count: 14, trend: -3, level: 'high' },
  { id: 'coll', label: 'Word choice & collocation', count: 11, trend: -1, level: 'high' },
  { id: 'sva', label: 'Subject–verb agreement', count: 8, trend: -4, level: 'mid' },
  { id: 'comma', label: 'Comma splices', count: 6, trend: +1, level: 'mid' },
  { id: 'prep', label: 'Prepositions', count: 5, trend: -2, level: 'low' },
];

// detailed corrections for the Error Details screen
const CORRECTIONS = [
  {
    id: 'c1',
    type: 'Article usage',
    severity: 'high',
    original: 'Government should invest in public transport to reduce the traffic.',
    corrected: 'The government should invest in public transport to reduce traffic.',
    diff: [
      { t: 'Add ', k: 'n' }, { t: 'The ', k: 'add' }, { t: 'government should invest in public transport to reduce ', k: 'n' }, { t: 'the ', k: 'del' }, { t: 'traffic.', k: 'n' },
    ],
    why: 'Use “the” before a specific, named institution (“the government”). “Traffic” here is an uncountable noun used in a general sense, so it takes no article.',
    rule: 'Definite article + uncountable nouns',
    upgrades: [
      { from: 'reduce traffic', to: 'ease congestion', note: 'more precise, exam-level collocation' },
      { from: 'invest in', to: 'allocate funding to', note: 'higher register for formal writing' },
    ],
  },
  {
    id: 'c2',
    type: 'Word choice & collocation',
    severity: 'high',
    original: 'This will make a big advantage for people who travel every day.',
    corrected: 'This would offer a significant advantage to daily commuters.',
    diff: [],
    why: '“Make an advantage” is not a natural collocation. Pair “advantage” with “offer/provide/bring”, and prefer the hypothetical “would” when discussing outcomes.',
    rule: 'Verb–noun collocation',
    upgrades: [
      { from: 'people who travel every day', to: 'daily commuters', note: 'concise noun phrase' },
      { from: 'big', to: 'significant / substantial', note: 'avoid informal intensifiers' },
    ],
  },
  {
    id: 'c3',
    type: 'Comma splice',
    severity: 'mid',
    original: 'Cars cause pollution, they should be limited in city centres.',
    corrected: 'Cars cause pollution; therefore, they should be limited in city centres.',
    diff: [],
    why: 'Two independent clauses cannot be joined by a comma alone. Use a semicolon, a full stop, or a coordinating conjunction with a linking adverb.',
    rule: 'Joining independent clauses',
    upgrades: [
      { from: 'they should be limited', to: 'they ought to be restricted', note: 'stronger modal + formal verb' },
    ],
  },
];

// AI coach weekly report
const COACH = {
  week: 'Week of May 25',
  headline: 'Your vocabulary is climbing — let’s lock it in.',
  summary: 'You wrote 4 essays this week and your health score rose 7 points. Grammar is now a clear strength. The biggest lever for your next half-band is lexical range — you’re repeating common words where examiners reward precise, less frequent vocabulary.',
  focus: { skill: 'Lexical Resource', score: 68, why: 'Lowest band-equivalent of your four skills, and the fastest to move with targeted practice.' },
  insights: [
    { icon: 'trend', title: 'Article errors down 40%', body: 'Your most common mistake last month is now your 3rd. Keep going.' },
    { icon: 'clock', title: 'You write best in the morning', body: 'Essays before noon score 6 points higher on average.' },
    { icon: 'target', title: 'Conclusions are rushed', body: 'Your last sentence is often under 8 words. Examiners want a restated position.' },
  ],
  recommendations: [
    { title: 'Learn 10 academic collocations', meta: '15 min · Vocabulary', tag: 'Vocabulary' },
    { title: 'Rewrite your last conclusion', meta: '10 min · Task Achievement', tag: 'Task' },
    { title: 'Paraphrase practice: technology', meta: '12 min · Vocabulary', tag: 'Vocabulary' },
  ],
  topics: ['Environment', 'Technology', 'Education', 'Urban planning', 'Health'],
};

// challenges
const CHALLENGES = [
  {
    id: 'streak', title: '5-Day Writing Streak', kind: 'streak',
    desc: 'Write at least one essay a day for 5 days.',
    progress: 3, total: 5, reward: 3, unit: 'days',
    state: 'active', accent: 'warn', frozen: false,
  },
  {
    id: 'errors', title: 'Error Reduction', kind: 'errors',
    desc: 'Cut your article-usage mistakes by half.',
    progress: 8, total: 14, reward: 5, unit: 'errors fixed', inverse: true,
    state: 'active', accent: 'good',
  },
  {
    id: 'vocab', title: 'Vocabulary Upgrade', kind: 'vocab',
    desc: 'Use 20 new academic words across your essays.',
    progress: 11, total: 20, reward: 5, unit: 'words',
    state: 'active', accent: 'violet',
  },
  {
    id: 'coherence', title: 'Flawless Flow', kind: 'coherence',
    desc: 'Score 85+ on Coherence in 3 essays.',
    progress: 3, total: 3, reward: 4, unit: 'essays',
    state: 'done', accent: 'primary',
  },
];

// monthly overview
const MONTHLY = {
  month: 'May 2026',
  essays: 12,
  scoreChange: +7,
  bestSkill: 'Grammar Range',
  focusSkill: 'Lexical Resource',
  minutes: 312,
};

// credit packs (paywall)
const PACKS = [
  { id: 'p5', credits: 5, price: '$4.99', per: '$1.00 / essay', tag: null, accent: false },
  { id: 'p10', credits: 10, price: '$8.99', per: '$0.90 / essay', tag: 'Most popular', accent: true, save: 'Save 10%' },
  { id: 'p25', credits: 25, price: '$18.99', per: '$0.76 / essay', tag: 'Best value', accent: false, save: 'Save 24%' },
];

const PERKS = [
  'Detailed sentence-level corrections',
  'IELTS & TOEFL band estimates',
  'Vocabulary upgrade suggestions',
  'Weekly AI coach reports',
];

// sample essay seed for the Write screen
const SAMPLE_ESSAY = `In recent years, public transport has become a central topic in city planning. Government should invest in public transport to reduce the traffic. This will make a big advantage for people who travel every day.

Cars cause pollution, they should be limited in city centres. If cities build better trains and buses, more people will choose them over private vehicles.`;

const WRITING_TIPS = [
  'State your position clearly in the introduction.',
  'Use one main idea per body paragraph.',
  'Support claims with specific examples.',
  'Vary sentence length for better flow.',
];

Object.assign(window, {
  EXAMS, USER, HEALTH, SKILLS, TODAY_GOAL, LAST_ESSAY, MISTAKES,
  CORRECTIONS, COACH, CHALLENGES, MONTHLY, PACKS, PERKS, SAMPLE_ESSAY, WRITING_TIPS,
});

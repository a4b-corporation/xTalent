const pptxgen = require('pptxgenjs');
const html2pptx = require('/Users/nguyenhuyvu/.gemini/antigravity/skills/pptx/scripts/html2pptx');
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const WORKSPACE = __dirname;
const SLIDES_DIR = path.join(WORKSPACE, 'slides');
const ASSETS = path.resolve(WORKSPACE, '..', 'assets');

// --- STEP 1: Create rasterized assets (gradients, backgrounds) ---
async function createAssets() {
  // Dark background
  const darkBg = `<svg xmlns="http://www.w3.org/2000/svg" width="960" height="540"><rect width="100%" height="100%" fill="#0a0e1a"/></svg>`;
  await sharp(Buffer.from(darkBg)).png().toFile(path.join(SLIDES_DIR, 'dark-bg.png'));

  // Gradient divider line
  const gradDivider = `<svg xmlns="http://www.w3.org/2000/svg" width="80" height="4"><defs><linearGradient id="g" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" style="stop-color:#6366f1"/><stop offset="100%" style="stop-color:#06b6d4"/></linearGradient></defs><rect width="100%" height="100%" fill="url(#g)" rx="2"/></svg>`;
  await sharp(Buffer.from(gradDivider)).png().toFile(path.join(SLIDES_DIR, 'divider.png'));

  // CTA gradient box
  const ctaBg = `<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="500"><defs><linearGradient id="g" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" style="stop-color:#6366f1"/><stop offset="100%" style="stop-color:#06b6d4"/></linearGradient></defs><rect width="100%" height="100%" fill="url(#g)" rx="20"/></svg>`;
  await sharp(Buffer.from(ctaBg)).png().toFile(path.join(SLIDES_DIR, 'cta-bg.png'));

  console.log('Assets created.');
}

// Common HTML wrapper: 720pt x 405pt, dark bg, Arial
function slideHTML(css, body) {
  return `<!DOCTYPE html><html><head><style>
html { background: transparent; }
body {
  width: 720pt; height: 405pt; margin: 0; padding: 0;
  font-family: Arial, sans-serif;
  display: flex; flex-direction: column;
  background-image: url('dark-bg.png'); background-size: cover;
  color: #e2e8f0;
}
${css}
</style></head><body>${body}</body></html>`;
}

// Tag helper
const tag = (text) => `<div style="display:inline-block;padding:4pt 10pt;border-radius:14pt;font-size:7pt;font-weight:700;text-transform:uppercase;letter-spacing:0.8pt;background:rgba(99,102,241,0.15);color:#818cf8;border:1px solid rgba(99,102,241,0.3);margin-bottom:8pt;"><p>${text}</p></div>`;

// ==================== SLIDES ====================

function slide00() {
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;align-items:center;justify-content:center;width:720pt;height:405pt;">
      ${tag('Strategic Vision 2026')}
      <h1 style="font-size:36pt;font-weight:800;color:#818cf8;margin-bottom:2pt;">xTalent</h1>
      <h2 style="font-size:14pt;font-weight:400;color:#94a3b8;margin-bottom:10pt;">The Self-Evolving HCM Platform</h2>
      <div style="margin:6pt 0;"><img src="divider.png" style="width:50pt;height:3pt;"></div>
      <p style="font-size:10pt;color:#94a3b8;text-align:center;max-width:480pt;line-height:1.5;margin-top:8pt;">A next-generation Human Capital Management solution built on the Self-Evolving Platform (SEP) — designed to continuously learn, adapt, and evolve alongside your organization in the age of AI Agents.</p>
    </div>
  `);
}

function slide01() {
  const items = [
    { n: '1', c: '#818cf8', bg: 'rgba(99,102,241,0.2)', t: 'Market Context', d: 'The Era of Cognitive Autonomy' },
    { n: '2', c: '#f472b6', bg: 'rgba(236,72,153,0.2)', t: 'The Problem', d: 'Why Traditional HCM Falls Short' },
    { n: '3', c: '#22d3ee', bg: 'rgba(6,182,212,0.2)', t: 'Our Vision', d: 'xTalent on the Self-Evolving Platform' },
    { n: '4', c: '#fbbf24', bg: 'rgba(245,158,11,0.2)', t: 'Architecture', d: 'The Four-Layer Model' },
    { n: '5', c: '#34d399', bg: 'rgba(16,185,129,0.2)', t: 'Capabilities', d: 'Use Cases on SEP' },
    { n: '6', c: '#a78bfa', bg: 'rgba(139,92,246,0.2)', t: 'Roadmap', d: 'Three Phases to Evolution' },
    { n: '7', c: '#fb7185', bg: 'rgba(244,63,94,0.2)', t: 'ROI & Governance', d: 'Value & Trust' },
  ];
  const rows = items.map(i => `
    <div style="display:flex;align-items:center;gap:8pt;margin:4pt 0;">
      <div style="width:26pt;height:26pt;border-radius:7pt;background:${i.bg};display:flex;align-items:center;justify-content:center;"><p style="color:${i.c};font-weight:700;font-size:11pt;">${i.n}</p></div>
      <p style="font-size:9pt;color:#94a3b8;"><b style="color:#e2e8f0;">${i.t}</b> — ${i.d}</p>
    </div>
  `).join('');
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;align-items:center;justify-content:center;width:720pt;height:405pt;">
      <h2 style="font-size:20pt;font-weight:700;color:#e2e8f0;margin-bottom:4pt;">Agenda</h2>
      <div style="margin:6pt 0;"><img src="divider.png" style="width:50pt;height:3pt;"></div>
      <div style="margin-top:8pt;max-width:400pt;">${rows}</div>
    </div>
  `);
}

function slide02() {
  const stats = [
    { num: '40%', label: 'Enterprise apps with agentic capabilities' },
    { num: '$3-5T', label: 'Global Agentic Commerce revenue' },
    { num: '3.5x', label: 'ROI per $1 invested in Agentic AI' },
    { num: '15%', label: 'Daily decisions made autonomously by AI' },
  ];
  const boxes = stats.map(s => `
    <div style="text-align:center;flex:1;">
      <p style="font-size:22pt;font-weight:800;color:#818cf8;">${s.num}</p>
      <p style="font-size:7pt;color:#94a3b8;margin-top:3pt;">${s.label}</p>
    </div>
  `).join('');
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;align-items:center;justify-content:center;width:720pt;height:405pt;">
      ${tag('Market Context')}
      <h2 style="font-size:20pt;font-weight:700;color:#e2e8f0;">The Era of Cognitive Autonomy</h2>
      <p style="font-size:9pt;color:#94a3b8;text-align:center;max-width:460pt;margin:6pt 0 16pt;">AI has shifted from experimental pilots to production-grade autonomous systems delivering measurable P&L impact.</p>
      <div style="display:flex;gap:16pt;max-width:600pt;width:100%;">${boxes}</div>
      <p style="font-size:6pt;color:#94a3b8;margin-top:14pt;">Sources: Gartner, McKinsey, Deloitte, Neurons Lab — 2026</p>
    </div>
  `);
}

function slide03() {
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;align-items:center;margin:24pt 40pt;">
      ${tag('Market Context')}
      <h2 style="font-size:18pt;font-weight:700;color:#e2e8f0;">The Agentic Divide</h2>
      <p style="font-size:7.5pt;color:#94a3b8;text-align:center;max-width:440pt;margin:3pt 0 4pt;">A stark gap is emerging between organizations that rewire around AI vs. those treating it as an add-on.</p>
      <img src="${path.join(ASSETS, 'agentic_divide.png')}" style="width:240pt;border-radius:8pt;">
    </div>
  `);
}

function slide04() {
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;align-items:center;margin:24pt 40pt;">
      ${tag('The Problem')}
      <h2 style="font-size:18pt;font-weight:700;color:#e2e8f0;">Traditional HCM is Fundamentally Broken</h2>
      <div style="margin:3pt 0;"><img src="divider.png" style="width:50pt;height:3pt;"></div>
      <img src="${path.join(ASSETS, 'comparison.png')}" style="width:240pt;margin-top:3pt;border-radius:8pt;">
    </div>
  `);
}

function slide05() {
  const cards = [
    { t: 'Self-Understanding', d: 'AI Agents comprehend HR processes like a domain expert through Ontology-Driven Knowledge', c: '#6366f1' },
    { t: 'Self-Adapting', d: 'Interfaces generate in real-time based on user intent — from fixed screens to AI-created views', c: '#06b6d4' },
    { t: 'Self-Orchestrating', d: 'Multi-agent workflows coordinate across HR functions — onboarding, payroll, compliance', c: '#f59e0b' },
  ];
  const cardHTML = cards.map(ca => `
    <div style="background:#1a2235;border-radius:10pt;padding:12pt;border:1px solid rgba(255,255,255,0.06);border-left:3pt solid ${ca.c};flex:1;">
      <h3 style="font-size:9pt;font-weight:600;color:#06b6d4;margin-bottom:4pt;">${ca.t}</h3>
      <p style="font-size:7pt;color:#94a3b8;line-height:1.4;">${ca.d}</p>
    </div>
  `).join('');
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;align-items:center;margin:28pt 40pt;">
      ${tag('Our Vision')}
      <h2 style="font-size:18pt;font-weight:700;color:#e2e8f0;text-align:center;">xTalent on the Self-Evolving Platform</h2>
      <p style="font-size:8pt;color:#94a3b8;text-align:center;max-width:460pt;margin:4pt 0 10pt;">Software that understands, learns, and evolves — transforming HCM from a static tool to a living system.</p>
      <div style="display:flex;gap:10pt;width:100%;">${cardHTML}</div>
      <div style="margin-top:10pt;width:200pt;">
        <div style="background:#1a2235;border-radius:10pt;padding:12pt;border:1px solid rgba(255,255,255,0.06);border-left:3pt solid #10b981;">
          <h3 style="font-size:9pt;font-weight:600;color:#06b6d4;margin-bottom:4pt;">Self-Managing Data</h3>
          <p style="font-size:7pt;color:#94a3b8;line-height:1.4;">Multi-modal data architecture grows organically — from ACID databases to AI-native vector stores</p>
        </div>
      </div>
    </div>
  `);
}

function slide06() {
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;align-items:center;margin:24pt 40pt;">
      ${tag('Architecture')}
      <h2 style="font-size:18pt;font-weight:700;color:#e2e8f0;">The Four-Layer Model</h2>
      <img src="${path.join(ASSETS, 'architecture_overview.png')}" style="width:250pt;margin-top:4pt;border-radius:8pt;">
    </div>
  `);
}

function slide07() {
  const items = [
    { t: 'Domain Ontology', d: 'Formal HR entity models in LinkML/OWL' },
    { t: 'Semantic Layer', d: 'Business terms to technical data mapping' },
    { t: 'Knowledge Graph', d: 'Employee, Position, Dept relationships' },
    { t: 'Rules Engine', d: 'Encoded labor law and policy guardrails' },
    { t: 'Cognitive API', d: 'SME-as-a-Service for any Agent' },
  ];
  const cards = items.map(i => `
    <div style="background:#1a2235;border-radius:8pt;padding:10pt;border:1px solid rgba(255,255,255,0.06);border-left:3pt solid #6366f1;flex:1;">
      <h3 style="font-size:8pt;font-weight:600;color:#06b6d4;margin-bottom:3pt;">${i.t}</h3>
      <p style="font-size:6.5pt;color:#94a3b8;line-height:1.3;">${i.d}</p>
    </div>
  `).join('');
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;margin:24pt 34pt;">
      ${tag('Layer 1')}
      <h2 style="font-size:18pt;font-weight:700;color:#e2e8f0;">Ontology-Driven Knowledge Layer</h2>
      <p style="font-size:8pt;color:#94a3b8;margin:4pt 0 10pt;">The "semantic brain" — enabling AI Agents to understand HR domain as deeply as a subject matter expert.</p>
      <div style="display:flex;gap:8pt;">${cards}</div>
      <p style="font-size:7pt;color:#818cf8;margin-top:10pt;font-weight:600;">Without this layer, AI is surface-level automation. With it, AI becomes a domain-aware decision partner.</p>
    </div>
  `);
}

function slide08() {
  const panels = [
    { t: 'Core UI (Fixed) — 30%', d: 'Navigation, design system, brand identity. Built by developers.' },
    { t: 'Configurable UI — 60%', d: 'JSON/Template-driven views. Admins customize without code.' },
    { t: 'Generative UI (A2UI) — 10%', d: 'AI Agents create interfaces on-demand for long-tail needs.' },
  ];
  const panelHTML = panels.map(p => `
    <div style="background:#1a2235;border-radius:8pt;padding:8pt;border:1px solid rgba(255,255,255,0.06);border-left:3pt solid #06b6d4;margin-bottom:5pt;">
      <h3 style="font-size:7.5pt;font-weight:600;color:#06b6d4;margin-bottom:2pt;">${p.t}</h3>
      <p style="font-size:6.5pt;color:#94a3b8;line-height:1.3;">${p.d}</p>
    </div>
  `).join('');
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;align-items:center;margin:22pt 34pt;">
      ${tag('Layer 2')}
      <h2 style="font-size:17pt;font-weight:700;color:#e2e8f0;text-align:center;">Adaptive UI Layer — The 30-60-10 Model</h2>
      <p style="font-size:7.5pt;color:#94a3b8;text-align:center;max-width:480pt;margin:3pt 0 6pt;">The right interface, to the right user, at the right time — balancing consistency with flexibility.</p>
      <div style="display:flex;gap:10pt;width:100%;align-items:flex-start;">
        <img src="${path.join(ASSETS, 'ui_distribution.png')}" style="width:240pt;border-radius:10pt;">
        <div style="flex:1;">${panelHTML}</div>
      </div>
      <p style="font-size:6pt;color:#94a3b8;margin-top:4pt;">Powered by: <b style="color:#e2e8f0;">A2UI</b> (Google) + <b style="color:#e2e8f0;">AG-UI</b> (Event Protocol) + <b style="color:#e2e8f0;">MCP</b> (Data Access)</p>
    </div>
  `);
}

function slide09() {
  const items = [
    { t: 'Headless API', d: 'REST/GraphQL stateless CRUD' },
    { t: 'Workflow Engine', d: 'Visual workflow designer, zero-code' },
    { t: 'Agent Orchestration', d: 'Multi-agent teams: Recruit, Comply, Payroll' },
    { t: 'Policy & Governance', d: 'Agent RBAC, audit, kill switches, HITL' },
  ];
  const cards = items.map(i => `
    <div style="background:#1a2235;border-radius:8pt;padding:10pt;border:1px solid rgba(255,255,255,0.06);border-left:3pt solid #f59e0b;flex:1;">
      <h3 style="font-size:8pt;font-weight:600;color:#06b6d4;margin-bottom:3pt;">${i.t}</h3>
      <p style="font-size:6.5pt;color:#94a3b8;line-height:1.3;">${i.d}</p>
    </div>
  `).join('');
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;margin:24pt 34pt;">
      ${tag('Layer 3')}
      <h2 style="font-size:18pt;font-weight:700;color:#e2e8f0;">Intelligent Backend Layer</h2>
      <p style="font-size:8pt;color:#94a3b8;margin:4pt 0 10pt;">From APIs to agent teams — processing business logic through traditional and AI-powered orchestration.</p>
      <div style="display:flex;gap:8pt;">${cards}</div>
      <div style="background:rgba(245,158,11,0.06);border:1px solid rgba(245,158,11,0.15);border-radius:8pt;padding:10pt;margin-top:10pt;text-align:center;">
        <p style="font-size:7pt;color:#94a3b8;"><b style="color:#fbbf24;">Workflow Engine Impact:</b> Customer requests "3-level approval for leave > 5 days" — Traditional: 2-week release. <b style="color:#e2e8f0;">xTalent: Configure and deploy instantly.</b></p>
      </div>
    </div>
  `);
}

function slide10() {
  const items = [
    { t: 'Core RDBMS', d: 'PostgreSQL — ACID, strict schema' },
    { t: 'Flex Store', d: 'SurrealDB — schemaless custom fields' },
    { t: 'Graph Store', d: 'Neo4j — org charts, skill maps' },
    { t: 'Metadata & Audit', d: 'Catalog + lineage — AI traceability' },
    { t: 'AI-Native Store', d: 'Vector DB — embeddings, RAG' },
  ];
  const cards = items.map(i => `
    <div style="background:#1a2235;border-radius:8pt;padding:10pt;border:1px solid rgba(255,255,255,0.06);border-left:3pt solid #10b981;flex:1;">
      <h3 style="font-size:7.5pt;font-weight:600;color:#06b6d4;margin-bottom:3pt;">${i.t}</h3>
      <p style="font-size:6.5pt;color:#94a3b8;line-height:1.3;">${i.d}</p>
    </div>
  `).join('');
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;margin:24pt 34pt;">
      ${tag('Layer 4')}
      <h2 style="font-size:18pt;font-weight:700;color:#e2e8f0;">Multi-Modal Data Layer</h2>
      <p style="font-size:8pt;color:#94a3b8;margin:4pt 0 10pt;">The right storage paradigm for every type of data — from strict transactional records to AI-native stores.</p>
      <div style="display:flex;gap:8pt;">${cards}</div>
      <p style="font-size:7pt;color:#34d399;margin-top:10pt;font-weight:600;">Metadata and Audit is mandatory for HR compliance — labor law, data privacy, GDPR/PDPA, AI transparency.</p>
    </div>
  `);
}

function slide11() {
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;align-items:center;margin:24pt 40pt;">
      ${tag('Use Case')}
      <h2 style="font-size:18pt;font-weight:700;color:#e2e8f0;">Self-Evolving Employee Onboarding</h2>
      <p style="font-size:7.5pt;color:#94a3b8;margin:3pt 0 4pt;">6 AI-powered steps orchestrated across all 4 layers of the Self-Evolving Platform</p>
      <img src="${path.join(ASSETS, 'onboarding_flow.png')}" style="width:240pt;border-radius:8pt;">
    </div>
  `);
}

function slide12() {
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;align-items:center;margin:22pt 34pt;">
      ${tag('More Use Cases')}
      <h2 style="font-size:18pt;font-weight:700;color:#e2e8f0;margin-bottom:8pt;">AI-Driven HR Operations</h2>
      <div style="display:flex;gap:10pt;width:100%;">
        <div style="flex:1;background:#1a2235;border-radius:10pt;padding:12pt;border:1px solid rgba(255,255,255,0.06);border-left:3pt solid #6366f1;">
          <h3 style="font-size:9pt;font-weight:600;color:#06b6d4;margin-bottom:4pt;">AI Performance Review</h3>
          <p style="font-size:7pt;color:#94a3b8;line-height:1.4;margin-bottom:4pt;">Continuous data collection from attendance, projects, peer feedback. Performance Agent synthesizes insights. Manager sees Generative UI dashboard. Business Rules ensure fairness.</p>
          <p style="font-size:6.5pt;color:#818cf8;font-weight:600;">From annual subjective reviews to continuous data-driven assessment</p>
        </div>
        <div style="flex:1;background:#1a2235;border-radius:10pt;padding:12pt;border:1px solid rgba(255,255,255,0.06);border-left:3pt solid #f59e0b;">
          <h3 style="font-size:9pt;font-weight:600;color:#06b6d4;margin-bottom:4pt;">Adaptive Payroll Compliance</h3>
          <p style="font-size:7pt;color:#94a3b8;line-height:1.4;margin-bottom:4pt;">Tax rules encoded in Ontology. Regulation changes update ontology only. Payroll Agent runs and verifies in parallel. Full audit trail in Metadata layer.</p>
          <p style="font-size:6.5pt;color:#fbbf24;font-weight:600;">Zero code changes when regulations update — ontology-only updates</p>
        </div>
      </div>
      <div style="background:#1a2235;border-radius:10pt;padding:10pt;border:1px solid rgba(255,255,255,0.06);border-left:3pt solid #06b6d4;margin-top:8pt;text-align:center;width:100%;">
        <h3 style="font-size:9pt;font-weight:600;color:#06b6d4;margin-bottom:3pt;">Intent-Based HR Analytics</h3>
        <p style="font-size:7pt;color:#94a3b8;"><b style="color:#e2e8f0;">Employee:</b> "How many vacation days do I have?" <b style="color:#e2e8f0;">Manager:</b> "Show attrition risk" <b style="color:#e2e8f0;">CHRO:</b> "Headcount cost by region YoY"</p>
      </div>
    </div>
  `);
}

function slide13() {
  const phases = [
    {
      t: 'Phase 1: Foundation', p: 'Months 1-6', c: '#818cf8', bc: 'rgba(99,102,241,0.18)',
      its: ['Core HR Domain Ontology (LinkML)', 'Knowledge Graph — org structure', 'Headless REST/GraphQL APIs', 'Core UI — design system', 'RDBMS + Flex Store + Metadata']
    },
    {
      t: 'Phase 2: Intelligence', p: 'Months 7-12', c: '#22d3ee', bc: 'rgba(6,182,212,0.18)',
      its: ['Workflow Engine — visual designer', 'Agent Team: Onboard, Comply, Payroll', 'Configurable UI (JSON-driven)', 'Full Knowledge Graph + GraphRAG', 'Vector DB — semantic search']
    },
    {
      t: 'Phase 3: Evolution', p: 'Months 13-18', c: '#34d399', bc: 'rgba(16,185,129,0.18)',
      its: ['Generative UI — A2UI integration', 'Multi-Agent cross-functional teams', 'MAPE-K self-optimization loops', 'Predictive HR Analytics', 'Auto-evolving rules and workflows']
    },
  ];
  const phaseCards = phases.map(ph => {
    const lis = ph.its.map(i => `<li style="font-size:6.5pt;color:#94a3b8;padding:2pt 0;"><p>${i}</p></li>`).join('');
    return `
      <div style="flex:1;border-radius:10pt;padding:12pt;border:1px solid ${ph.bc};background:${ph.bc};">
        <h3 style="font-size:10pt;font-weight:600;color:${ph.c};margin-bottom:2pt;">${ph.t}</h3>
        <p style="font-size:6.5pt;color:#94a3b8;margin-bottom:6pt;">${ph.p}</p>
        <ul style="padding-left:12pt;margin:0;">${lis}</ul>
      </div>
    `;
  }).join('');
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;align-items:center;margin:24pt 34pt;">
      ${tag('Roadmap')}
      <h2 style="font-size:20pt;font-weight:700;color:#e2e8f0;margin-bottom:10pt;">Three Phases to Evolution</h2>
      <div style="display:flex;gap:10pt;width:100%;">${phaseCards}</div>
    </div>
  `);
}

function slide14() {
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;align-items:center;margin:26pt 40pt;">
      ${tag('Value')}
      <h2 style="font-size:18pt;font-weight:700;color:#e2e8f0;">ROI & Strategic Impact</h2>
      <img src="${path.join(ASSETS, 'roi_metrics.png')}" style="width:260pt;margin-top:4pt;border-radius:8pt;">
    </div>
  `);
}

function slide15() {
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;align-items:center;margin:24pt 40pt;">
      ${tag('Trust')}
      <h2 style="font-size:17pt;font-weight:700;color:#e2e8f0;">Governance & Security Framework</h2>
      <p style="font-size:7pt;color:#94a3b8;text-align:center;max-width:440pt;margin:2pt 0 4pt;">Every AI Agent operates under strict governance — with 5 pillars and 5 layers of defense-in-depth security.</p>
      <img src="${path.join(ASSETS, 'governance_framework.png')}" style="width:250pt;border-radius:8pt;">
    </div>
  `);
}

function slide16() {
  return slideHTML('', `
    <div style="display:flex;flex-direction:column;align-items:center;justify-content:center;width:720pt;height:405pt;">
      <div style="width:520pt;border-radius:16pt;overflow:hidden;">
        <img src="cta-bg.png" style="width:520pt;position:absolute;">
        <div style="position:relative;padding:30pt;text-align:center;">
          <h1 style="font-size:18pt;font-weight:800;color:#ffffff;">xTalent is not just the future of HCM.</h1>
          <h1 style="font-size:18pt;font-weight:800;color:#ffffff;">It is the future of enterprise software.</h1>
          <div style="width:50pt;height:2pt;background:rgba(255,255,255,0.3);margin:10pt auto;border-radius:1pt;"></div>
          <p style="color:rgba(255,255,255,0.85);font-size:8pt;line-height:1.6;">From static software to living systems. From configuration to conversation. From siloed data to unified knowledge. From manual compliance to automatic governance.</p>
          <div style="display:flex;gap:8pt;justify-content:center;margin-top:14pt;">
            <div style="background:rgba(255,255,255,0.15);padding:5pt 12pt;border-radius:6pt;"><p style="font-size:7pt;font-weight:600;color:#ffffff;">Ontology-First</p></div>
            <div style="background:rgba(255,255,255,0.15);padding:5pt 12pt;border-radius:6pt;"><p style="font-size:7pt;font-weight:600;color:#ffffff;">Intent-Over-Configuration</p></div>
            <div style="background:rgba(255,255,255,0.15);padding:5pt 12pt;border-radius:6pt;"><p style="font-size:7pt;font-weight:600;color:#ffffff;">Evolution-by-Design</p></div>
          </div>
        </div>
      </div>
    </div>
  `);
}

// ==================== MAIN ====================
async function main() {
  console.log('Step 1: Creating rasterized assets...');
  await createAssets();

  const slideGenerators = [
    { name: 'slide00-cover', fn: slide00 },
    { name: 'slide01-agenda', fn: slide01 },
    { name: 'slide02-market', fn: slide02 },
    { name: 'slide03-agentic-divide', fn: slide03 },
    { name: 'slide04-problem', fn: slide04 },
    { name: 'slide05-vision', fn: slide05 },
    { name: 'slide06-architecture', fn: slide06 },
    { name: 'slide07-layer1', fn: slide07 },
    { name: 'slide08-layer2', fn: slide08 },
    { name: 'slide09-layer3', fn: slide09 },
    { name: 'slide10-layer4', fn: slide10 },
    { name: 'slide11-onboarding', fn: slide11 },
    { name: 'slide12-usecases', fn: slide12 },
    { name: 'slide13-roadmap', fn: slide13 },
    { name: 'slide14-roi', fn: slide14 },
    { name: 'slide15-governance', fn: slide15 },
    { name: 'slide16-cta', fn: slide16 },
  ];

  // Write HTML files
  console.log('Step 2: Writing HTML slide files...');
  for (const sg of slideGenerators) {
    fs.writeFileSync(path.join(SLIDES_DIR, `${sg.name}.html`), sg.fn());
    console.log(`  Written: ${sg.name}.html`);
  }

  // Convert to PPTX
  console.log('\nStep 3: Converting to PPTX...');
  const pptx = new pptxgen();
  pptx.layout = 'LAYOUT_16x9';
  pptx.author = 'xTalent Team';
  pptx.title = 'xTalent — The Self-Evolving HCM Platform';

  let successCount = 0;
  let errorCount = 0;

  for (const sg of slideGenerators) {
    const htmlFile = path.join(SLIDES_DIR, `${sg.name}.html`);
    try {
      console.log(`  Processing: ${sg.name}...`);
      await html2pptx(htmlFile, pptx);
      successCount++;
      console.log(`  ✓ ${sg.name}`);
    } catch (e) {
      errorCount++;
      console.error(`  ✗ ${sg.name}: ${e.message}`);
    }
  }

  const outputPath = path.resolve(WORKSPACE, '..', 'xTalent-SEP-Presentation.pptx');
  await pptx.writeFile({ fileName: outputPath });
  console.log(`\nDone! ${successCount} slides OK, ${errorCount} errors.`);
  console.log(`Saved to: ${outputPath}`);
}

main().catch(console.error);

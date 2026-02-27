/**
 * Generate infographics for ODSA documentation
 * Run: node gen-infographics.mjs
 * Requires: @antv/infographic/ssr (from mcp-server-infographic dependencies)
 *
 * Output: ./charts/*.svg  (embed vào các *.md bằng: ![alt](./charts/ig-xx.svg))
 */

import { createRequire } from "module";
import { writeFileSync, mkdirSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);

// Use the SSR renderer — direct file path to bypass ESM exports resolution
const { renderToString } = require(
    "/Users/nguyenhuyvu/Library/CloudStorage/OneDrive-VNGCorporation/Apps/myapp/mcp-server-infographic/node_modules/@antv/infographic/lib/ssr/index.js"
);

const outputDir = join(__dirname, "charts");
mkdirSync(outputDir, { recursive: true });

// ─────────────────────────────────────────────────────────
// INFOGRAPHICS DEFINITIONS
// ─────────────────────────────────────────────────────────

const infographics = [

    // ── 01_odsa_overview.md ───────────────────────────────

    {
        filename: "ig-01-knowledge-fragmentation.svg",
        desc: "Vấn đề Knowledge Phân Mảnh trong quy trình truyền thống",
        dsl: `infographic list-grid-badge-card
data
  title Vấn Đề: Knowledge Phân Mảnh
  desc 5 nguồn lưu trữ không liên kết khiến AI mù và knowledge transfer tốn kém
  lists
    - label PRD / BRD (Word/PDF)
      desc Static text — AI không đọc được semantic, outdated nhanh
      icon file document outline
    - label DB Schema (SQL)
      desc Chỉ có cấu trúc kỹ thuật — mất business meaning hoàn toàn
      icon database
    - label Source Code
      desc Chỉ dev đọc được — không có context business cao hơn
      icon code braces
    - label ERD Diagram
      desc Outdated nhanh chóng — không liên kết được với document
      icon sitemap
    - label API Spec (Swagger)
      desc Chỉ mô tả technical contract — mất intent và business context
      icon api
theme
  palette
    - "#ef4444"
    - "#f97316"
    - "#eab308"
    - "#8b5cf6"
    - "#ec4899"`,
    },

    {
        filename: "ig-02-odsa-vs-traditional.svg",
        desc: "So sánh Traditional vs ODSA Development",
        dsl: `infographic compare-binary-horizontal-badge-card-arrow
data
  title Traditional vs ODSA
  desc Sự khác biệt căn bản trong phương pháp phát triển phần mềm
  compares
    - label Truyền Thống
      children
        - label Starting Point: DB Schema
        - label Docs: Word/PDF — AI không parse được
        - label AI Understanding: Yếu, không có semantic
        - label Cross-module: Manual meeting tốn kém
        - label Knowledge Transfer: Meetings & docs rời rạc
        - label Artifacts: Static text, outdated nhanh
    - label ODSA
      children
        - label Starting Point: Ontology làm SSOT
        - label Docs: Integrated, machine-readable
        - label AI Understanding: Native, ontology-aware
        - label Cross-module: Built-in via shared ontology
        - label Knowledge Transfer: Automatic via knowledge graph
        - label Artifacts: Executable knowledge, luôn in sync
theme
  palette
    - "#ef4444"
    - "#10b981"`,
    },

    {
        filename: "ig-03-odsa-5-principles.svg",
        desc: "5 Nguyên Tắc Cốt Lõi ODSA",
        dsl: `infographic list-column-vertical-icon-arrow
data
  title 5 Nguyên Tắc Cốt Lõi ODSA
  desc Nền tảng triết lý xây dựng phần mềm lấy Ontology làm trung tâm
  lists
    - label Principle 1 — Ontology-First
      desc Mọi entity, relationship, lifecycle phải định nghĩa trong Ontology trước khi implement
      icon alpha-o-circle
    - label Principle 2 — Executable Knowledge
      desc Tài liệu phải parseable, sinh output có thể deploy, linked semantic
      icon lightning-bolt
    - label Principle 3 — Narrative + Structured
      desc Kết hợp structured artifacts (LinkML/DBML/OpenAPI) + narrative docs (Markdown)
      icon file-document-multiple
    - label Principle 4 — AI-Native by Design
      desc Tất cả format phải AI-readable; AI Agent phải query được knowledge
      icon robot
    - label Principle 5 — Modular & Evolvable
      desc Mỗi module có ontology riêng; Ontology là living artifact, không bao giờ outdated
      icon puzzle
theme
  palette
    - "#1783FF"
    - "#00C9C9"
    - "#60C42D"
    - "#F0884D"
    - "#7863FF"`,
    },

    {
        filename: "ig-04-odsa-5-stages.svg",
        desc: "ODSA Pipeline 5 Stages",
        dsl: `infographic sequence-roadmap-vertical-simple
data
  title ODSA Pipeline — 5 Stages
  desc Từ Idea đến living system với Ontology làm trung tâm
  sequences
    - label Stage 1 — Idea → Ontology
      desc Model business concepts, relationships, workflows, rules trong LinkML YAML
    - label Stage 2 — Ontology → System Design
      desc Generate DB schema skeleton, API contract skeleton, event definitions
    - label Stage 3 — Ontology → Knowledge Graph
      desc Build semantic graph + Hybrid Memory (graph + vector + FTS)
    - label Stage 4 — Knowledge Graph → AI Integration
      desc AI Agent query knowledge, hỗ trợ design/dev/operation
    - label Stage 5 — Continuous Evolution
      desc Update ontology, regenerate artifacts, update graph memory
theme
  palette
    - "#1783FF"
    - "#00C9C9"
    - "#60C42D"
    - "#F0884D"
    - "#7863FF"`,
    },

    // ── 02_odds_standard.md ──────────────────────────────

    {
        filename: "ig-05-odds-doc-structure.svg",
        desc: "Cấu trúc Tài Liệu Chuẩn ODDS v1",
        dsl: `infographic hierarchy-structure
data
  title Cấu Trúc Module Chuẩn ODDS v1
  desc Thay thế PRD/BRD/FSD/SRS rời rạc bằng bộ tài liệu vừa human-readable vừa machine-readable
  items
    - label ontology/
      desc Semantic layer — định nghĩa business domain
      children
        - label concepts/
          desc 1 class = 1 YAML file (LinkML format)
        - label relationships.yaml
          desc Cross-concept relationships của module
        - label lifecycle.yaml
          desc State machines cho toàn module
        - label rules.yaml
          desc Business rules và constraints
    - label design/
      desc Narrative docs — thay thế PRD/BRD
      children
        - label purpose.md
          desc Module overview + business objectives
        - label use_cases.md
          desc Tất cả use cases và user stories
        - label workflows.md
          desc Business workflows (thay BPMN)
        - label api_intent.md
          desc Canonical API intent (không phải spec)
    - label system/
      desc Implementation skeleton
      children
        - label db.dbml
          desc Database schema (DBML format)
        - label canonical_api.openapi.yaml
          desc Resource APIs (OpenAPI format)
        - label events.yaml
          desc Domain event definitions
    - label governance/
      desc Audit và versioning
      children
        - label metadata.yaml
          desc Version, owner, reviewers, dependencies
theme
  palette
    - "#1783FF"
    - "#00C9C9"
    - "#60C42D"
    - "#F0884D"`,
    },

    {
        filename: "ig-06-odds-4-principles.svg",
        desc: "4 Nguyên Tắc Thiết Kế ODDS",
        dsl: `infographic list-grid-ribbon-card
data
  title 4 Nguyên Tắc Thiết Kế ODDS
  desc Governance rules đảm bảo tài liệu vừa human-readable vừa machine-readable
  lists
    - label 1. Concept Granularity
      desc Chỉ ontology/concepts/ tách nhỏ (1 class = 1 file). Lý do: thay đổi thường xuyên, AI chỉnh sửa độc lập
      icon numeric-1-circle
    - label 2. Sub-module Cohesion
      desc Lifecycle, rules, events gom theo sub-module: 1 sub-module = 1 file — tránh fragmentation
      icon numeric-2-circle
    - label 3. Canonical API Only
      desc Chỉ mô tả resource APIs và state transition APIs — không có UI/workflow/orchestration APIs
      icon numeric-3-circle
    - label 4. AI Context Boundaries
      desc Mỗi file: self-contained, ≤ 800 lines, represent 1 domain context rõ ràng
      icon numeric-4-circle
theme
  palette
    - "#1783FF"
    - "#7863FF"
    - "#00C9C9"
    - "#60C42D"`,
    },

    // ── 03_development_workflow.md ───────────────────────

    {
        filename: "ig-07-role-transformation.svg",
        desc: "Sự Dịch Chuyển Vai Trò trong ODSA",
        dsl: `infographic compare-binary-horizontal-simple-fold
data
  title Sự Dịch Chuyển Vai Trò trong ODSA
  desc ODSA không thay thế con người — nó thay đổi những gì mỗi người làm
  compares
    - label Trước ODSA
      children
        - label BA: Viết PRD/BRD bằng Word
        - label BA: Vẽ BPMN diagrams
        - label BA: Tổ chức knowledge transfer meetings
        - label Dev: Đọc 100 trang PRD để hiểu requirements
        - label Dev: Tự thiết kế DB schema từ đầu
        - label Architect: Review Word documents
        - label Architect: Cross-module check bằng meeting
    - label Sau ODSA
      children
        - label BA → Semantic Designer: Viết ontology YAML
        - label BA: Viết design/workflows.md thay BPMN
        - label BA: AI Agent tự query knowledge graph
        - label Dev → Knowledge Consumer: Query KnowledgeOS
        - label Dev: Implement từ db.dbml + openapi skeleton
        - label Architect: Review LinkML + DBML + OpenAPI
        - label Architect: Query graph để xem relationships
theme
  palette
    - "#ef4444"
    - "#10b981"`,
    },

    {
        filename: "ig-08-dev-workflow-phases.svg",
        desc: "Workflow 4 Phases theo ODSA",
        dsl: `infographic sequence-snake-steps-compact-card
data
  title Workflow Phát Triển theo ODSA — 4 Phases
  desc Từ domain ontology đến living system với AI-assisted development
  sequences
    - label Phase 1 — Product Design
      desc BA + PO: Viết ontology concepts, relationships, lifecycle, rules & design docs
    - label Phase 2 — System Design
      desc Architect + Dev Lead: Sinh DB skeleton, API spec, Events & ingest vào KnowledgeOS
    - label Phase 3 — AI-Assisted Development
      desc Developer: Query KnowledgeOS → Implement DB, APIs, Events, Business Rules
    - label Phase 4 — Continuous Evolution
      desc Cả team: Update ontology → Re-ingest → AI Agent tự động có context mới
theme
  palette
    - "#1783FF"
    - "#7863FF"
    - "#00C9C9"
    - "#60C42D"`,
    },

    // ── 04_knowledgeos_architecture.md ──────────────────

    {
        filename: "ig-09-hybrid-knowledge-memory.svg",
        desc: "Hybrid Knowledge Memory — 3 Tầng Storage",
        dsl: `infographic list-column-simple-vertical-arrow
data
  title Hybrid Knowledge Memory — 3 Tầng
  desc KnowledgeOS kết hợp 3 loại storage để cung cấp đầy đủ loại reasoning cho AI Agent
  lists
    - label Tầng 1 — Property Graph (LadybugDB)
      desc Lưu cấu trúc semantic: Concept, Slot, Lifecycle, State, Transition, Event, Table, APIEndpoint. Query bằng Cypher — Structural Reasoning
    - label Tầng 2 — Vector Store (sqlite-vec)
      desc Semantic similarity search từ Markdown chunks + concept descriptions. Query bằng embedding — Semantic Reasoning
    - label Tầng 3 — Full-Text Search (FTS5)
      desc Keyword-based search cho technical terms, proper nouns, exact match. Hybrid search = Tầng 1 + 2 + 3
theme
  palette
    - "#1783FF"
    - "#7863FF"
    - "#F0884D"`,
    },

    {
        filename: "ig-10-knowledgeos-mcp-tools.svg",
        desc: "8 MCP Tools cho AI Agents",
        dsl: `infographic list-grid-badge-card
data
  title 8 MCP Tools — KnowledgeOS Interface
  desc AI Agents (Gemini/Claude) truy cập knowledge qua 8 tools này
  lists
    - label knowledge_search
      desc Hybrid search: vector + FTS + graph traversal
      icon magnify
    - label graph_query
      desc Cypher query trực tiếp vào Property Graph
      icon database-search
    - label graph_explore
      desc Explore node neighbors và relationships
      icon graph
    - label graph_schema
      desc Xem schema của toàn bộ knowledge graph
      icon table-large
    - label list_concepts
      desc List tất cả domain concepts đã ingest
      icon format-list-bulleted
    - label concept_detail
      desc Full detail: slots, relationships, lifecycle của 1 concept
      icon card-account-details
    - label ingest_file
      desc Trigger ingest ODSA artifact từ AI Agent
      icon upload
    - label ingest_status
      desc Kiểm tra trạng thái của ingest jobs
      icon progress-check
theme
  palette
    - "#1783FF"
    - "#00C9C9"
    - "#60C42D"
    - "#7863FF"
    - "#F0884D"
    - "#D580FF"
    - "#BD8F24"
    - "#FF80CA"`,
    },

    {
        filename: "ig-11-knowledgeos-roadmap.svg",
        desc: "KnowledgeOS Roadmap — Phase 1 & 2",
        dsl: `infographic compare-binary-horizontal-badge-card-arrow
data
  title KnowledgeOS Roadmap
  desc Từ Knowledge Layer hiện tại đến Runtime Intelligence
  compares
    - label Phase 1 (Hiện Tại) — Knowledge Layer ✅
      children
        - label Ingest pipeline: LinkML, Markdown, DBML, OpenAPI
        - label Hybrid Knowledge Memory: Graph + Vector + FTS
        - label REST API layer (FastAPI)
        - label MCP interface (knowledgeos-mcp standalone)
        - label Admin UI (NiceGUI)
    - label Phase 2 (Tương Lai) — Runtime Intelligence
      children
        - label Runtime event feed: update knowledge graph dynamically
        - label AI Agent discover & call Canonical APIs trực tiếp
        - label Frontend-less paradigm: AI là UI
theme
  palette
    - "#10b981"
    - "#7863FF"`,
    },

];

// ─────────────────────────────────────────────────────────
// RENDER & SAVE
// ─────────────────────────────────────────────────────────

async function main() {
    console.log(`\n🎨 Generating ${infographics.length} infographics for ODSA docs...\n`);
    let success = 0;
    let failed = 0;

    for (const ig of infographics) {
        process.stdout.write(`  ⏳ ${ig.filename} — ${ig.desc} ... `);
        try {
            const svg = await renderToString(ig.dsl);
            const outPath = join(outputDir, ig.filename);
            writeFileSync(outPath, svg, "utf-8");
            console.log(`✅ saved (${Math.round(svg.length / 1024)}KB)`);
            success++;
        } catch (err) {
            console.log(`❌ FAILED: ${err.message}`);
            failed++;
        }
    }

    console.log(`\n📊 Results: ${success} success, ${failed} failed`);
    console.log(`📁 Output: ${outputDir}`);
    console.log(`\n📝 Embed vào markdown:\n   ![alt](./charts/ig-01-knowledge-fragmentation.svg)\n`);
}

main().catch(console.error);

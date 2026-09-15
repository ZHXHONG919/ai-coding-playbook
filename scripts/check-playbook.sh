#!/usr/bin/env bash
set -euo pipefail

# 轻量自检：确认关键文件存在，校验路由与安装状态。

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required=(
  "README.md"
  "AGENTS.md"
  "docs/conversation-usage.md"
  "docs/adoption-guide.md"
  "docs/codex-usage.md"
  "docs/cursor-usage.md"
  "docs/claude-usage.md"
  "agents/AGENTS.template.md"
  "agents/CLAUDE.template.md"
  "agents/cursor-rules.template.mdc"
  "platforms/codex/manifest.yaml"
  "platforms/cursor/manifest.yaml"
  "platforms/claude/manifest.yaml"
  "platforms/codex/overlays/ai-coding-playbook.md"
  "platforms/cursor/overlays/ai-coding-playbook.md"
  "platforms/claude/overlays/ai-coding-playbook.md"
  "references/stages/requirement.md"
  "references/stages/requirement-confirmation.md"
  "references/stages/feature-kickoff.md"
  "references/stages/plan.md"
  "references/stages/plan-light.md"
  "references/stages/goal-handoff.md"
  "references/stages/implementation.md"
  "references/stages/review.md"
  "references/stages/rule-diagnostics.md"
  "references/stages/bugfix.md"
  "references/stages/release.md"
  "references/git-safety.md"
  "references/plan/evidence-first.md"
  "references/plan/role-lens.md"
  "references/plan/domain-design.md"
  "references/plan/diagram-required.md"
  "references/plan/detail-gate.md"
  "references/plan/decision-table.md"
  "references/plan/field-ownership.md"
  "references/plan/task-breakdown.md"
  "references/delivery/evidence-driven-delivery.md"
  "references/delivery/tooling-prerequisites.md"
  "references/review-kit/review-flow.md"
  "references/review-kit/architecture.md"
  "references/review-kit/typescript-react.md"
  "references/review-kit/security.md"
  "references/review-kit/database.md"
  "references/scenarios/ai-ready.md"
  "references/scenarios/llm-analysis.md"
  "references/scenarios/ai-media-pipeline.md"
  "references/scenarios/chrome-extension.md"
  "references/scenarios/nest-react-postgres.md"
  "references/scenarios/pnpm-monorepo.md"
  "references/scenarios/open-design.md"
  "workflows/feature-workflow.md"
  "workflows/formal-technical-plan-authoring.md"
  "workflows/design-discussion-rules.md"
  "workflows/technical-plan-quality-gate.md"
  "workflows/release-workflow.md"
  "templates/feature-design.md"
  "templates/plan-light.md"
  "templates/goal/GOAL.md"
  "templates/goal/acceptance.md"
  "templates/goal/slices.yaml"
  "templates/goal/status.yaml"
  "templates/goal/review-policy.md"
  "templates/goal/worker-report.md"
  "templates/goal/validation-report.md"
  "templates/goal/evidence-confirmation.md"
  "templates/goal/tooling-prerequisites.yaml"
  "templates/goal/mock-ledger.md"
  "templates/goal/todo-ledger.md"
  "templates/goal/worktree-plan.md"
  "templates/goal/human-intervention.md"
  "templates/goal/resume.md"
  "templates/goal/risks-deferred.md"
  "templates/goal/design-handoff.md"
  "templates/goal/gate.md"
  "templates/goal/cr-template.md"
  "evals/README.md"
  "evals/ai-coding-playbook-routing.md"
  "evals/usage/simple-stage-commands.md"
  "evals/usage/claude-ui-flow-trigger.md"
  "evals/usage/plain-language-output.md"
  "evals/usage/chinese-first-skill-language.md"
  "evals/bugfix/source-agnostic-evidence-budget.md"
  "evals/plan/task-evidence-gate.md"
  "evals/goal-execute/legacy-evidence-migration.md"
  "evals/goal-execute/final-evidence-confirmation-code-gate.md"
  "evals/delivery/cli-first-third-party-tools.md"
  "evals/goal-execute/tooling-prerequisite-resume.md"
  "evals/goal-handoff/no-third-party-tooling.md"
  "evals/plan/boundary-cases-required.md"
  "evals/plan/latest-requirement-delta-gate.md"
  "evals/plan/prototype-confirmation-gate.md"
  "evals/plan/open-design-usage-gate.md"
  "evals/plan/open-design-existing-baseline.md"
  "evals/implementation/ui-drift-gate-impeccable.md"
  "evals/service-ops/restart-service-not-debug.md"
  "evals/release-safety/local-deploy-question-not-release.md"
  "evals/release-safety/staging-before-production.md"
  "evals/git-safety/no-automerge-main-into-feature.md"
  "evals/git-safety/plan-doc-write-requires-feature-branch.md"
  "evals/goal-handoff/goal-package-required.md"
  "evals/goal-handoff/design-cr-ready-requires-goal.md"
  "evals/goal-handoff/frontend-first-mock-lane.md"
  "evals/goal-execute/no-fake-cr.md"
  "evals/goal-execute/no-deferred-final-done.md"
  "evals/goal-execute/resume-from-status.md"
  "evals/goal-execute/codex-app-goal-mirror.md"
  "evals/goal-execute/no-new-thread-on-context.md"
  "evals/goal-execute/all-cr-findings-closed.md"
  "evals/goal-execute/continuous-default.md"
  "evals/goal-execute/release-gate-not-in-dev-slice.md"
  "evals/goal-execute/prepare-only-branch-ready.md"
  "evals/goal-execute/orchestrator-delegates-workers.md"
  "evals/goal-execute/no-main-thread-implementation.md"
  "evals/goal-execute/worker-cannot-update-status.md"
  "evals/goal-execute/validation-before-cr.md"
  "evals/goal-execute/mock-ledger-required.md"
  "evals/goal-execute/worktree-parallel-boundary.md"
  "evals/goal-execute/ui-drift-gate-impeccable.md"
  "evals/goal-execute/fixer-round-cap-escalates.md"
  "evals/goal-execute/requirement-delta-mid-slice.md"
  "evals/goal-execute/legacy-nit-zero-override.md"
  "evals/goal-execute/pre-cr-validation-cap.md"
  "evals/goal-execute/ui-drift-once-per-slice.md"
  "evals/goal-execute/local-todo-does-not-block-next-slice.md"
  "evals/review/ui-drift-gate-impeccable.md"
  "profiles/nest-react-postgres.md"
  "skills/ai-coding-playbook/SKILL.md"
  "skills/design-review/SKILL.md"
  "skills/goal-execute/SKILL.md"
  "skills/ts-code-review/SKILL.md"
  "skills/nest-api-design/SKILL.md"
  "skills/typeorm-postgres-migration/SKILL.md"
  "skills/react-vite-feature/SKILL.md"
  "skills/fullstack-ui-prototype/SKILL.md"
  "skills/test-scope-analysis/SKILL.md"
  "skills/ai-provider-integration/SKILL.md"
  "skills/release-safety-review/SKILL.md"
  "skills/browser-extension-development/SKILL.md"
  "skills/skill-maintenance/SKILL.md"
  "skills/skill-prompt-convert/SKILL.md"
  "skills/codegen-diagram/SKILL.md"
  "skills/codegen-doc/SKILL.md"
)

for path in "${required[@]}"; do
  if [ ! -f "$ROOT_DIR/$path" ]; then
    echo "missing: $path" >&2
    exit 1
  fi
done

# Skill frontmatter must stay routable and lightweight.
while IFS= read -r skill_file; do
  if ! grep -q '^---$' "$skill_file"; then
    echo "skill missing frontmatter fence: $skill_file" >&2
    exit 1
  fi
  if ! sed -n '1,12p' "$skill_file" | grep -q '^name: '; then
    echo "skill missing name frontmatter: $skill_file" >&2
    exit 1
  fi
  if ! sed -n '1,16p' "$skill_file" | grep -q '^description: '; then
    echo "skill missing description frontmatter: $skill_file" >&2
    exit 1
  fi

  desc_chars="$(awk '
    BEGIN { in_desc=0; count=0 }
    /^description:[[:space:]]*>?[[:space:]]*$/ { in_desc=1; next }
    /^description:[[:space:]]+/ {
      line=$0
      sub(/^description:[[:space:]]*/, "", line)
      count += length(line)
      next
    }
    in_desc && /^[[:space:]]+/ {
      line=$0
      sub(/^[[:space:]]+/, "", line)
      count += length(line)
      next
    }
    in_desc { in_desc=0 }
    END { print count }
  ' "$skill_file")"
  if [ "$desc_chars" -gt 1536 ]; then
    echo "skill description too long (>1536 chars): $skill_file ($desc_chars)" >&2
    exit 1
  fi
done < <(find "$ROOT_DIR/skills" -mindepth 2 -maxdepth 2 -name 'SKILL.md' | sort)

# README skill 列表应覆盖 skills/*/SKILL.md（除内部说明性例外）
while IFS= read -r skill_file; do
  skill_name="$(basename "$(dirname "$skill_file")")"
  if ! grep -q "\`$skill_name\`" "$ROOT_DIR/README.md"; then
    echo "README missing skill entry: $skill_name" >&2
    exit 1
  fi
done < <(find "$ROOT_DIR/skills" -mindepth 2 -maxdepth 2 -name 'SKILL.md' | sort)

# AGENTS 路由表应提及 design-review 与 plan-light
if ! grep -q 'design-review' "$ROOT_DIR/AGENTS.md"; then
  echo "AGENTS.md missing design-review route" >&2
  exit 1
fi

if ! grep -q 'plan-light' "$ROOT_DIR/AGENTS.md"; then
  echo "AGENTS.md missing plan-light route" >&2
  exit 1
fi

if ! grep -q 'rule-diagnostics' "$ROOT_DIR/AGENTS.md"; then
  echo "AGENTS.md missing rule-diagnostics route" >&2
  exit 1
fi

if ! grep -q 'references/git-safety.md' "$ROOT_DIR/AGENTS.md"; then
  echo "AGENTS.md missing git-safety route" >&2
  exit 1
fi

if ! grep -q 'ai-ready' "$ROOT_DIR/AGENTS.md"; then
  echo "AGENTS.md missing ai-ready route" >&2
  exit 1
fi

if ! grep -q '自然语言短指令' "$ROOT_DIR/AGENTS.md"; then
  echo "AGENTS.md missing natural-language short command section" >&2
  exit 1
fi

if ! grep -q '梳理需求' "$ROOT_DIR/platforms/codex/overlays/ai-coding-playbook.md"; then
  echo "codex overlay missing simple requirement trigger" >&2
  exit 1
fi

if ! grep -q '执行任务' "$ROOT_DIR/platforms/codex/overlays/ai-coding-playbook.md"; then
  echo "codex overlay missing simple implementation trigger" >&2
  exit 1
fi

if ! grep -q '继续 Goal' "$ROOT_DIR/platforms/codex/overlays/ai-coding-playbook.md"; then
  echo "codex overlay missing simple goal trigger" >&2
  exit 1
fi

if ! grep -q 'app goal 进度条' "$ROOT_DIR/platforms/codex/overlays/ai-coding-playbook.md"; then
  echo "codex overlay missing app goal progress trigger" >&2
  exit 1
fi

if ! grep -q 'Product Flow Gate' "$ROOT_DIR/references/stages/plan.md"; then
  echo "plan stage missing Product Flow Gate" >&2
  exit 1
fi

if ! grep -q 'Latest Requirement Delta Gate' "$ROOT_DIR/references/stages/plan.md"; then
  echo "plan stage missing Latest Requirement Delta Gate" >&2
  exit 1
fi

if ! grep -q 'Cross-doc Consistency Scan' "$ROOT_DIR/references/stages/implementation.md"; then
  echo "implementation stage missing cross-doc consistency scan" >&2
  exit 1
fi

if ! grep -q 'git merge origin/main' "$ROOT_DIR/references/git-safety.md"; then
  echo "git-safety missing protected main merge rule" >&2
  exit 1
fi

if ! grep -q -- '--autostash' "$ROOT_DIR/references/git-safety.md"; then
  echo "git-safety missing autostash ban" >&2
  exit 1
fi

if ! grep -q '用户原话和最新确认业务规则' "$ROOT_DIR/skills/design-review/SKILL.md"; then
  echo "design-review missing original business rule reconciliation" >&2
  exit 1
fi

if ! grep -q '更严格 / 更安全' "$ROOT_DIR/references/stages/plan.md"; then
  echo "plan stage missing business-rule-vs-safety conflict gate" >&2
  exit 1
fi

if ! grep -q '原型确认，进入详细技术方案' "$ROOT_DIR/skills/fullstack-ui-prototype/SKILL.md"; then
  echo "fullstack-ui-prototype missing explicit prototype confirmation gate" >&2
  exit 1
fi

if ! grep -q 'impeccable shape' "$ROOT_DIR/skills/fullstack-ui-prototype/SKILL.md"; then
  echo "fullstack-ui-prototype missing impeccable shape command mapping" >&2
  exit 1
fi

if ! grep -q 'impeccable audit' "$ROOT_DIR/skills/fullstack-ui-prototype/SKILL.md"; then
  echo "fullstack-ui-prototype missing impeccable audit command mapping" >&2
  exit 1
fi

if ! grep -q 'Open Design 接入' "$ROOT_DIR/skills/fullstack-ui-prototype/SKILL.md"; then
  echo "fullstack-ui-prototype missing Open Design usage gate" >&2
  exit 1
fi

if ! grep -q 'skip / existing-baseline / run / blocked' "$ROOT_DIR/skills/fullstack-ui-prototype/SKILL.md"; then
  echo "fullstack-ui-prototype missing Open Design decision states" >&2
  exit 1
fi

if ! grep -q '不得为 `skip` / `blocked` 编造 projectId' "$ROOT_DIR/evals/plan/open-design-usage-gate.md"; then
  echo "open-design usage eval missing anti-fabrication check for skip/blocked" >&2
  exit 1
fi

if ! grep -q 'Open Design decision 必须是 `existing-baseline`' "$ROOT_DIR/evals/plan/open-design-existing-baseline.md"; then
  echo "open-design existing-baseline eval missing decision assertion" >&2
  exit 1
fi

if ! grep -q 'start_run' "$ROOT_DIR/references/scenarios/open-design.md"; then
  echo "open-design scenario missing real run workflow" >&2
  exit 1
fi

if ! grep -q 'get_artifact' "$ROOT_DIR/references/scenarios/open-design.md"; then
  echo "open-design scenario missing artifact pull guidance" >&2
  exit 1
fi

if ! grep -q '局部字段、按钮、文案、间距' "$ROOT_DIR/references/stages/plan.md"; then
  echo "plan stage missing Open Design non-default boundary" >&2
  exit 1
fi

if ! grep -q 'Open Design 使用门禁' "$ROOT_DIR/AGENTS.md"; then
  echo "AGENTS.md missing Open Design route to scenario rules" >&2
  exit 1
fi

if ! grep -q 'Open Design 只在新页面' "$ROOT_DIR/agents/AGENTS.template.md"; then
  echo "AGENTS template missing Open Design usage boundary" >&2
  exit 1
fi

if ! grep -q 'Open Design baseline' "$ROOT_DIR/templates/goal/worker-report.md"; then
  echo "worker report template missing Open Design baseline evidence" >&2
  exit 1
fi

if ! grep -q 'Open Design artifact' "$ROOT_DIR/templates/goal/slices.yaml"; then
  echo "goal slices template missing Open Design artifact in ui-drift validator" >&2
  exit 1
fi

if ! grep -q 'impeccable 视角的原型质量检查' "$ROOT_DIR/references/stages/plan.md"; then
  echo "plan stage missing impeccable prototype quality check" >&2
  exit 1
fi

if ! grep -q 'UI Drift Gate' "$ROOT_DIR/references/stages/implementation.md"; then
  echo "implementation stage missing UI Drift Gate" >&2
  exit 1
fi

if ! grep -q 'UI Drift Review' "$ROOT_DIR/references/stages/review.md"; then
  echo "review stage missing UI Drift Review" >&2
  exit 1
fi

if ! grep -q 'UI Drift Review' "$ROOT_DIR/skills/ts-code-review/SKILL.md"; then
  echo "ts-code-review missing UI Drift Review guidance" >&2
  exit 1
fi

if ! grep -q 'impeccable polish' "$ROOT_DIR/references/stages/implementation.md"; then
  echo "implementation stage missing impeccable fix command mapping" >&2
  exit 1
fi

if ! grep -q 'UI Drift Gate' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing UI Drift Gate validation rule" >&2
  exit 1
fi

if ! grep -q 'evidence-driven-delivery.md' "$ROOT_DIR/references/stages/bugfix.md"; then
  echo "bugfix stage missing evidence-driven delivery routing" >&2
  exit 1
fi

if ! grep -q '界面基线' "$ROOT_DIR/references/plan/task-breakdown.md" || ! grep -q '证据门禁' "$ROOT_DIR/references/plan/task-breakdown.md"; then
  echo "task breakdown missing UI baseline or evidence gate" >&2
  exit 1
fi

if ! head -n 12 "$ROOT_DIR/skills/ai-coding-playbook/SKILL.md" | grep -q '共享的 AI 研发工作流入口'; then
  echo "ai-coding-playbook description is not Chinese-first" >&2
  exit 1
fi

for overlay in cursor claude codex; do
  if ! head -n 12 "$ROOT_DIR/platforms/$overlay/overlays/ai-coding-playbook.md" | grep -Eq '将自然语言研发指令|当用户需要 AI coding'; then
    echo "$overlay ai-coding-playbook overlay description is not Chinese-first" >&2
    exit 1
  fi
done

for evidence_field in 'level:' 'expected_baseline:' 'gate:' 'required_states:' 'required_roles:' 'required_clients:' 'pre_cr_ui_check:' 'final_capture_timing:' 'zero_blocker_confirmation:' 'max_ui_capture_methods:' 'max_attempts_per_method:'; do
  if ! grep -q "$evidence_field" "$ROOT_DIR/templates/goal/slices.yaml"; then
    echo "goal slices template missing evidence field: $evidence_field" >&2
    exit 1
  fi
done

if command -v ruby >/dev/null 2>&1; then
  ruby -e '
    require "yaml"
    doc = YAML.safe_load(File.read(ARGV[0]), aliases: true)
    required = %w[level expected_baseline gate required_states required_roles required_clients shared_with_task_ids pre_cr_ui_check final_capture_timing zero_blocker_confirmation max_ui_capture_methods max_attempts_per_method fallback]
    slices = doc.fetch("slices")
    slices.each do |slice|
      tooling_ids = slice.fetch("tooling_prerequisite_ids")
      abort("slice #{slice["id"]} tooling_prerequisite_ids must be an array") unless tooling_ids.is_a?(Array)
      evidence = slice.fetch("evidence")
      missing = required.reject { |key| evidence.key?(key) }
      abort("slice #{slice["id"]} evidence missing: #{missing.join(", ")}") unless missing.empty?
    end
  ' "$ROOT_DIR/templates/goal/slices.yaml" || {
    echo "goal slices template is not valid YAML" >&2
    exit 1
  }

  ruby -e '
    require "yaml"
    slices = YAML.safe_load(File.read(ARGV[0]), aliases: true).fetch("slices")
    catalog = YAML.safe_load(File.read(ARGV[1]), aliases: true).fetch("tooling_prerequisites")
    slices.each do |slice|
      ids = slice.fetch("tooling_prerequisite_ids")
      abort("slice #{slice["id"]} has duplicate tooling IDs") unless ids.uniq.length == ids.length
      missing = ids.reject { |id| catalog.key?(id) }
      abort("slice #{slice["id"]} references missing tooling IDs: #{missing.join(", ")}") unless missing.empty?
    end
  ' "$ROOT_DIR/templates/goal/slices.yaml" "$ROOT_DIR/templates/goal/tooling-prerequisites.yaml" || {
    echo "goal tooling references are inconsistent" >&2
    exit 1
  }
fi

if ! grep -Eq '^\| ID .*证据等级.*界面基线.*证据门禁.*\|$' "$ROOT_DIR/references/plan/task-breakdown.md" || ! grep -Eq '^\| ID .*证据等级.*界面基线.*证据门禁.*\|$' "$ROOT_DIR/references/stages/feature-kickoff.md"; then
  echo "task templates missing evidence level" >&2
  exit 1
fi

if [ "$(grep -c '^    evidence:' "$ROOT_DIR/templates/goal/slices.yaml")" -ne 2 ]; then
  echo "goal slices template must contain complete evidence blocks for development and global exit" >&2
  exit 1
fi

for evidence_field in 'level:' 'expected_baseline:' 'gate:' 'required_states:' 'required_roles:' 'required_clients:' 'pre_cr_ui_check:' 'final_capture_timing:' 'zero_blocker_confirmation:' 'max_ui_capture_methods:' 'max_attempts_per_method:' 'fallback:'; do
  if [ "$(grep -c "^      $evidence_field" "$ROOT_DIR/templates/goal/slices.yaml")" -ne 2 ]; then
    echo "each goal evidence block must contain: $evidence_field" >&2
    exit 1
  fi
done

if ! grep -q 'legacy_not_declared' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing legacy evidence migration strategy" >&2
  exit 1
fi

if ! grep -q 'tooling-prerequisite' "$ROOT_DIR/AGENTS.md" || [ "$(grep -c '^    tooling_prerequisite_ids:' "$ROOT_DIR/templates/goal/slices.yaml")" -ne 2 ]; then
  echo "third-party tooling prerequisite routing is incomplete" >&2
  exit 1
fi

if ! grep -Eq '^\| ID .*工具前置 ID.*证据等级.*界面基线.*证据门禁.*\|$' "$ROOT_DIR/references/plan/task-breakdown.md" || ! grep -Eq '^\| ID .*工具前置 ID.*证据等级.*界面基线.*证据门禁.*\|$' "$ROOT_DIR/references/stages/feature-kickoff.md"; then
  echo "task templates missing tooling prerequisite ID mapping" >&2
  exit 1
fi

if ! grep -q 'tooling-prerequisites.yaml' "$ROOT_DIR/skills/goal-execute/SKILL.md" || ! grep -q '旧 Goal 缺少工具字段' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing tooling persistence or legacy migration" >&2
  exit 1
fi

if command -v ruby >/dev/null 2>&1; then
  ruby -e '
    require "yaml"
    doc = YAML.safe_load(File.read(ARGV[0]), aliases: true)
    items = doc.fetch("tooling_prerequisites")
    abort("tooling_prerequisites must be a mapping") unless items.is_a?(Hash)
    required = %w[capability selected_method cli authentication capability_boundary readiness]
    items.each do |id, item|
      missing = required.reject { |key| item.key?(key) }
      abort("#{id} missing: #{missing.join(", ")}") unless missing.empty?
      kind = item.fetch("selected_method").fetch("kind")
      cli = item.fetch("cli")
      if kind == "cli"
        abort("#{id} selects cli but cli.required is not true") unless cli["required"] == true
        abort("#{id} selects cli but command is missing") if [nil, "", "not_applicable"].include?(cli["command"])
      else
        abort("#{id} does not select cli but cli.required is true") if cli["required"] == true
      end
    end
  ' "$ROOT_DIR/templates/goal/tooling-prerequisites.yaml" || {
    echo "tooling prerequisites template is invalid" >&2
    exit 1
  }
fi

if ! grep -q '不得写入密码、验证码' "$ROOT_DIR/references/delivery/tooling-prerequisites.md"; then
  echo "tooling prerequisites missing credential redaction boundary" >&2
  exit 1
fi

if ! grep -q 'Goal Gate 前置阶段' "$ROOT_DIR/references/stages/goal-handoff.md" || ! grep -q 'Goal Execute 不负责首次安装' "$ROOT_DIR/references/stages/goal-handoff.md"; then
  echo "tooling preparation timing is ambiguous" >&2
  exit 1
fi

if ! grep -q '每种方式最多两次完整尝试' "$ROOT_DIR/references/delivery/tooling-prerequisites.md" && ! grep -q '连续失败遵守证据驱动交付的尝试预算' "$ROOT_DIR/references/delivery/tooling-prerequisites.md"; then
  echo "third-party tooling rules missing UI control attempt budget" >&2
  exit 1
fi

if ! grep -q '运行时代码是否变化' "$ROOT_DIR/templates/goal/evidence-confirmation.md" || ! grep -q 'new_cr_present' "$ROOT_DIR/templates/goal/evidence-confirmation.md"; then
  echo "evidence confirmation template missing code-change gate" >&2
  exit 1
fi

if ! grep -q '替换原因' "$ROOT_DIR/templates/goal/evidence-confirmation.md"; then
  echo "evidence confirmation template missing reviewer fallback" >&2
  exit 1
fi

if ! grep -q '证据驱动执行' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing evidence-driven execution rules" >&2
  exit 1
fi

if ! grep -q 'ui-drift' "$ROOT_DIR/templates/goal/slices.yaml"; then
  echo "goal slices template missing ui-drift validator" >&2
  exit 1
fi

if ! grep -q 'Impeccable command' "$ROOT_DIR/templates/goal/validation-report.md"; then
  echo "validation report template missing impeccable command evidence" >&2
  exit 1
fi

if ! grep -q 'UI Drift Review' "$ROOT_DIR/templates/goal/cr-template.md"; then
  echo "CR template missing UI Drift Review section" >&2
  exit 1
fi

if ! grep -q 'Open Design baseline' "$ROOT_DIR/templates/goal/validation-report.md"; then
  echo "validation report template missing Open Design baseline evidence" >&2
  exit 1
fi

if ! grep -q 'Open Design baseline tuple' "$ROOT_DIR/templates/goal/cr-template.md"; then
  echo "CR template missing Open Design baseline tuple evidence" >&2
  exit 1
fi

if ! grep -q 'Open Design artifact' "$ROOT_DIR/templates/goal/review-policy.md"; then
  echo "review policy missing Open Design artifact input" >&2
  exit 1
fi

if ! grep -q 'UI / Impeccable Baseline' "$ROOT_DIR/templates/goal/design-handoff.md"; then
  echo "design handoff template missing UI / Impeccable baseline" >&2
  exit 1
fi

if ! grep -q '做 UI Flow' "$ROOT_DIR/platforms/claude/overlays/ai-coding-playbook.md"; then
  echo "claude overlay missing UI Flow trigger" >&2
  exit 1
fi

if ! grep -q '做原型' "$ROOT_DIR/platforms/claude/overlays/ai-coding-playbook.md"; then
  echo "claude overlay missing prototype trigger" >&2
  exit 1
fi

if ! grep -q 'impeccable polish' "$ROOT_DIR/README.md"; then
  echo "README missing impeccable command mapping" >&2
  exit 1
fi

if ! grep -q '用户不需要每次手写这些命令' "$ROOT_DIR/docs/conversation-usage.md"; then
  echo "conversation usage missing automatic impeccable command guidance" >&2
  exit 1
fi

if ! grep -q '未安装 impeccable 时，不阻塞' "$ROOT_DIR/references/stages/implementation.md"; then
  echo "implementation stage missing non-blocking impeccable fallback" >&2
  exit 1
fi

if ! grep -q '不得用视觉建议覆盖' "$ROOT_DIR/references/stages/review.md"; then
  echo "review stage missing business-contract override ban" >&2
  exit 1
fi

if ! grep -q '^\.agents/$' "$ROOT_DIR/.gitignore"; then
  echo ".gitignore missing local .agents ignore" >&2
  exit 1
fi

if ! grep -q '^\.codex/$' "$ROOT_DIR/.gitignore"; then
  echo ".gitignore missing local .codex ignore" >&2
  exit 1
fi

if ! grep -q '必须进入 Goal Handoff' "$ROOT_DIR/AGENTS.md"; then
  echo "AGENTS.md missing mandatory Goal Handoff gate" >&2
  exit 1
fi

if ! grep -q '不能直接进入代码实现' "$ROOT_DIR/references/stages/goal-handoff.md"; then
  echo "goal-handoff missing mandatory no-direct-implementation rule" >&2
  exit 1
fi

if ! grep -q 'gate.md: Ready' "$ROOT_DIR/references/stages/implementation.md"; then
  echo "implementation stage missing Goal Gate Ready precondition" >&2
  exit 1
fi

# Goal Execute invariants should be mechanically checked, not only file existence.
if ! grep -q 'run_mode' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing run_mode gate" >&2
  exit 1
fi

if ! grep -q 'continuous' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing continuous default" >&2
  exit 1
fi

if ! grep -q 'implementation_owner' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing implementation owner gate" >&2
  exit 1
fi

if ! grep -q 'P0/P1/Blocker/Should-fix' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing blocking finding closure rule" >&2
  exit 1
fi

if ! grep -q 'non-blocking follow-up' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing P2/Nit follow-up rule" >&2
  exit 1
fi

if ! grep -q '开发 Gate 与发布 Gate' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing dev/release gate split" >&2
  exit 1
fi

if ! grep -q 'needs_human_intervention' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing needs_human_intervention state" >&2
  exit 1
fi

if ! grep -q 'main-thread' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing main-thread implementation report rule" >&2
  exit 1
fi

if ! grep -q 'validation report' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing validation report evidence rule" >&2
  exit 1
fi

if ! grep -q 'mock-ledger.md' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing mock ledger rule" >&2
  exit 1
fi

if ! grep -q 'worktree-plan.md' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing worktree plan rule" >&2
  exit 1
fi

if ! grep -q 'Codex App Goal 镜像' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing Codex app goal mirror rule" >&2
  exit 1
fi

if ! grep -q '吞吐与防空转' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing throughput anti-thrash section" >&2
  exit 1
fi

if ! grep -q 'max_pre_cr_validation_rounds' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing pre-CR validation round cap" >&2
  exit 1
fi

if ! grep -q 'requirement_delta_pending' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing mid-slice requirement delta state" >&2
  exit 1
fi

if ! grep -q 'Legacy Goal 包兼容' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing legacy Goal package override rule" >&2
  exit 1
fi

if ! grep -q '禁止 silent fixer-3+' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing fixer round escalation rule" >&2
  exit 1
fi

if ! grep -q 'Slice Size Gate' "$ROOT_DIR/references/stages/goal-handoff.md"; then
  echo "goal-handoff missing Slice Size Gate" >&2
  exit 1
fi

if ! grep -q 'Throughput Gate' "$ROOT_DIR/references/stages/goal-handoff.md"; then
  echo "goal-handoff missing Throughput Gate" >&2
  exit 1
fi

if ! grep -q 'max_pre_cr_validation_rounds' "$ROOT_DIR/templates/goal/slices.yaml"; then
  echo "goal slices template missing max_pre_cr_validation_rounds" >&2
  exit 1
fi

if ! grep -q 'non_blocking_findings_routed' "$ROOT_DIR/templates/goal/slices.yaml"; then
  echo "goal slices template missing non_blocking_findings_routed exit" >&2
  exit 1
fi

if grep -q 'no_unresolved_nit_or_should_fix' "$ROOT_DIR/templates/goal/slices.yaml"; then
  echo "goal slices template still forces unresolved nit/should_fix exit on all slices" >&2
  exit 1
fi

if ! grep -q 'pre_cr_ui_check' "$ROOT_DIR/templates/goal/slices.yaml" || ! grep -q 'final_capture_timing' "$ROOT_DIR/templates/goal/slices.yaml"; then
  echo "goal slices template missing split UI evidence timing" >&2
  exit 1
fi

if grep -q 'once before first CR' "$ROOT_DIR/templates/goal/slices.yaml" || grep -q 'before_first_cr_and_after_ui_fix' "$ROOT_DIR/templates/goal/review-policy.md"; then
  echo "goal templates still force full UI drift before first CR" >&2
  exit 1
fi

if ! grep -q 'concurrency-checklist' "$ROOT_DIR/templates/goal/slices.yaml"; then
  echo "goal slices template missing concurrency-checklist validator" >&2
  exit 1
fi

if ! grep -q 'legacy_nit_zero_on_dev_slice: false' "$ROOT_DIR/templates/goal/review-policy.md"; then
  echo "review policy missing legacy nit-zero default false" >&2
  exit 1
fi

if ! grep -q 'requirement_delta' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status missing requirement_delta block" >&2
  exit 1
fi

if ! grep -q 'Slice Size Gate' "$ROOT_DIR/templates/goal/gate.md"; then
  echo "goal gate missing Slice Size Gate checklist" >&2
  exit 1
fi

if ! grep -q 'Goal 吞吐优先于仪式完整' "$ROOT_DIR/AGENTS.md"; then
  echo "AGENTS.md missing Goal throughput principle" >&2
  exit 1
fi

if grep -Eq 'open_deferred > 0.*(除非|允许|可).*waiver' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute allows final open deferred waiver" >&2
  exit 1
fi

if ! grep -q 'new_thread_allowed: false' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status missing new_thread_allowed=false" >&2
  exit 1
fi

if ! grep -q 'workers_may_update_status: false' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status missing worker status boundary" >&2
  exit 1
fi

if ! grep -q 'continue_after_each_slice: true' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status missing continue_after_each_slice default" >&2
  exit 1
fi

if ! grep -q 'main_agent_may_edit_business_code_when_owner: true' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status missing owner-scoped main-agent edit boundary" >&2
  exit 1
fi

if ! grep -q '^implementation_owner:' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status missing implementation_owner block" >&2
  exit 1
fi

if ! grep -q 'active_workers' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status missing active worker tracking" >&2
  exit 1
fi

if ! grep -q 'validation_reports_dir' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status missing validation report resume path" >&2
  exit 1
fi

if ! grep -q 'checkpoint_commit_allowed: false' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status missing checkpoint_commit_allowed=false" >&2
  exit 1
fi

if ! grep -q 'codex_app_goal:' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status missing Codex app goal mirror policy" >&2
  exit 1
fi

if ! awk '/^codex_app_goal:/{in_block=1; next} /^[^[:space:]][^:]*:/{in_block=0} in_block && /enabled: true/{found=1} END{exit !found}' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status Codex app goal should default enabled" >&2
  exit 1
fi

if ! awk '/^codex_app_goal:/{in_block=1; next} /^[^[:space:]][^:]*:/{in_block=0} in_block && /role: ui_mirror_only/{found=1} END{exit !found}' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status Codex app goal must remain UI mirror only" >&2
  exit 1
fi

if ! awk '/^codex_app_goal:/{in_block=1; next} /^[^[:space:]][^:]*:/{in_block=0} in_block && /source_of_truth: ".goal\/status.yaml"/{found=1} END{exit !found}' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status Codex app goal source of truth must be .goal/status.yaml" >&2
  exit 1
fi

if ! awk '/^codex_app_goal:/{in_block=1; next} /^[^[:space:]][^:]*:/{in_block=0} in_block && /create_on_execute_when_available: true/{found=1} END{exit !found}' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status Codex app goal should create on execute when available" >&2
  exit 1
fi

if ! grep -q 'codex_app_goal.enabled: false' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing Codex app goal disabled escape hatch" >&2
  exit 1
fi

if ! grep -q 'create_goal' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing automatic create_goal behavior" >&2
  exit 1
fi

if ! grep -q '不需要用户额外点名' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing automatic Codex app goal mirror default" >&2
  exit 1
fi

if ! grep -q 'human_intervention_zero_or_state_needs_human_intervention' "$ROOT_DIR/templates/goal/status.yaml"; then
  echo "goal status missing strict human intervention global exit" >&2
  exit 1
fi

if ! grep -q 'status_complete_or_needs_human_intervention' "$ROOT_DIR/templates/goal/slices.yaml"; then
  echo "goal slices missing final status complete/needs-human-intervention gate" >&2
  exit 1
fi

if ! grep -q 'output_pattern: ".goal/cr/R99-round-{n}.md"' "$ROOT_DIR/templates/goal/slices.yaml"; then
  echo "goal final slice missing required CR round output pattern" >&2
  exit 1
fi

if ! grep -q 'validators:' "$ROOT_DIR/templates/goal/slices.yaml"; then
  echo "goal slices missing validators" >&2
  exit 1
fi

if ! grep -q 'mock_ledger' "$ROOT_DIR/templates/goal/slices.yaml"; then
  echo "goal slices missing mock ledger linkage" >&2
  exit 1
fi

if ! grep -q 'Worktree Plan' "$ROOT_DIR/templates/goal/worktree-plan.md"; then
  echo "goal worktree plan template missing title" >&2
  exit 1
fi

if ! grep -q 'Mock Ledger' "$ROOT_DIR/templates/goal/mock-ledger.md"; then
  echo "goal mock ledger template missing title" >&2
  exit 1
fi

if ! grep -q 'open / fixed / rejected_false_positive / non_blocking_follow_up / later_slice_gate / release_gate / human_intervention' "$ROOT_DIR/templates/goal/cr-template.md"; then
  echo "goal CR template missing normalized finding statuses" >&2
  exit 1
fi

check_install_target() {
  local target_name="$1"
  local target_dir="$2"
  local build_dir="$ROOT_DIR/platforms/.build/$target_name"
  local warnings=0

  if [ ! -d "$target_dir" ]; then
    echo "install [$target_name]: missing dir $target_dir (run install-skills.sh --target $target_name)" >&2
    return 0
  fi

  for skill_dir in "$ROOT_DIR"/skills/*; do
    [ -d "$skill_dir" ] || continue
    name="$(basename "$skill_dir")"
    [ -f "$skill_dir/SKILL.md" ] || continue
    installed="$target_dir/$name"

    if [ ! -e "$installed" ]; then
      echo "install [$target_name]: not installed: $name" >&2
      warnings=$((warnings + 1))
      continue
    fi

    if [ ! -L "$installed" ]; then
      echo "install [$target_name]: not symlink (use --force): $installed" >&2
      warnings=$((warnings + 1))
      continue
    fi

    if [ -f "$ROOT_DIR/platforms/$target_name/overlays/${name}.md" ]; then
      expected="$build_dir/$name"
      actual="$(cd "$(dirname "$installed")" && readlink "$name" || true)"
      if [ "$actual" != "$expected" ]; then
        echo "install [$target_name]: overlay skill link drift: $name -> $actual (expected $expected)" >&2
        warnings=$((warnings + 1))
      fi
    else
      expected="$skill_dir"
      actual="$(cd "$(dirname "$installed")" && readlink "$name" || true)"
      if [ "$actual" != "$expected" ]; then
        echo "install [$target_name]: skill link drift: $name -> $actual (expected $expected)" >&2
        warnings=$((warnings + 1))
      fi
    fi
  done

  if [ "$warnings" -eq 0 ]; then
    echo "install [$target_name]: ok ($target_dir)"
  else
    echo "install [$target_name]: $warnings issue(s); run: bash scripts/install-skills.sh --target $target_name --force" >&2
  fi
}

check_install_target "codex" "$HOME/.codex/skills"
check_install_target "cursor" "$HOME/.cursor/skills"

echo "playbook structure ok"

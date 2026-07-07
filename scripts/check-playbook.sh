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
  "references/plan/evidence-first.md"
  "references/plan/role-lens.md"
  "references/plan/domain-design.md"
  "references/plan/diagram-required.md"
  "references/plan/detail-gate.md"
  "references/plan/decision-table.md"
  "references/plan/field-ownership.md"
  "references/plan/task-breakdown.md"
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
  "templates/goal/mock-ledger.md"
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
  "evals/plan/boundary-cases-required.md"
  "evals/plan/prototype-confirmation-gate.md"
  "evals/release-safety/staging-before-production.md"
  "evals/goal-handoff/goal-package-required.md"
  "evals/goal-handoff/design-cr-ready-requires-goal.md"
  "evals/goal-execute/no-fake-cr.md"
  "evals/goal-execute/no-deferred-final-done.md"
  "evals/goal-execute/resume-from-status.md"
  "evals/goal-execute/no-new-thread-on-context.md"
  "evals/goal-execute/all-cr-findings-closed.md"
  "evals/goal-execute/orchestrator-delegates-workers.md"
  "evals/goal-execute/worker-cannot-update-status.md"
  "evals/goal-execute/validation-before-cr.md"
  "evals/goal-execute/mock-ledger-required.md"
  "evals/goal-execute/worktree-parallel-boundary.md"
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

if ! grep -q 'Product Flow Gate' "$ROOT_DIR/references/stages/plan.md"; then
  echo "plan stage missing Product Flow Gate" >&2
  exit 1
fi

if ! grep -q '原型确认，进入详细技术方案' "$ROOT_DIR/skills/fullstack-ui-prototype/SKILL.md"; then
  echo "fullstack-ui-prototype missing explicit prototype confirmation gate" >&2
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
if ! grep -q 'Nit/P2' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing Nit/P2 closure rule" >&2
  exit 1
fi

if ! grep -q 'Should-fix' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing Should-fix closure rule" >&2
  exit 1
fi

if ! grep -q 'needs_human_intervention' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing needs_human_intervention state" >&2
  exit 1
fi

if ! grep -q 'orchestrator-worker' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing orchestrator-worker model" >&2
  exit 1
fi

if ! grep -q 'worker report' "$ROOT_DIR/skills/goal-execute/SKILL.md"; then
  echo "goal-execute missing worker report evidence rule" >&2
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

if ! grep -q 'open / fixed / rejected_false_positive / human_intervention' "$ROOT_DIR/templates/goal/cr-template.md"; then
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

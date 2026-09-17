#!/usr/bin/env bash
set -euo pipefail

# 自检仓库结构、路由与 Goal 契约；--repo-only 不读取安装链接。
REPO_ONLY=false
for arg in "$@"; do
  case "$arg" in
    --repo-only) REPO_ONLY=true ;;
    --help|-h)
      echo "用法：bash scripts/check-playbook.sh [--repo-only]"
      echo "--repo-only 仅检查候选仓库，不检查或修改全局安装。"
      exit 0 ;;
    *) echo "未知参数：$arg" >&2; exit 2 ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required=(
  "scripts/check-goal.rb"
  "scripts/test-check-goal.rb"
  "evals/workflow-v2/README.md"
  "evals/workflow-v2/checker.md"
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
  "references/delivery/agent-delivery-flow.md"
  "references/delivery/execution-evidence.md"
  "templates/execution-log.md"
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

if ! { grep -q 'ui-flow.md' "$ROOT_DIR/references/stages/plan.md" && grep -q '新的主用户路径需要确认' "$ROOT_DIR/references/stages/plan.md"; }; then
  echo "方案阶段缺少界面流程与新主路径确认边界" >&2
  exit 1
fi

if ! { grep -q '最新要求与一致性' "$ROOT_DIR/references/stages/plan.md" && grep -q 'decision-table.md' "$ROOT_DIR/references/stages/plan.md"; }; then
  echo "方案阶段缺少最新要求与单一业务决策同步规则" >&2
  exit 1
fi

if ! { grep -q '单一业务决定' "$ROOT_DIR/references/stages/implementation.md" && grep -q '已经授权的新要求不重复申请确认' "$ROOT_DIR/references/stages/implementation.md"; }; then
  echo "实现阶段缺少受影响契约同步或既有授权边界" >&2
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

if ! { grep -q '目标项目已安装 impeccable' "$ROOT_DIR/references/stages/plan.md" && grep -q '原型' "$ROOT_DIR/references/stages/plan.md"; }; then
  echo "方案阶段缺少按原型变化选择界面质量检查" >&2
  exit 1
fi

if ! { grep -q '有已确认界面时' "$ROOT_DIR/references/stages/implementation.md"; }; then
  echo "实现阶段缺少已确认界面与交互基线" >&2
  exit 1
fi

if ! { grep -q '前端与原型一致性' "$ROOT_DIR/references/stages/review.md"; }; then
  echo "审查阶段缺少前端与原型一致性规则" >&2
  exit 1
fi

if ! { grep -q 'references/stages/review.md' "$ROOT_DIR/skills/ts-code-review/SKILL.md" && grep -q '实际调用方' "$ROOT_DIR/skills/ts-code-review/SKILL.md"; }; then
  echo "代码审查Skill缺少统一规则入口或真实调用方检查" >&2
  exit 1
fi

if ! { grep -q 'audit / critique / polish' "$ROOT_DIR/references/stages/implementation.md"; }; then
  echo "实现阶段缺少按风险选择界面检查方式" >&2
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

if ! { grep -q '证据等级、界面基线与证据门禁' "$ROOT_DIR/references/plan/task-breakdown.md" && grep -q '证据等级' "$ROOT_DIR/references/stages/feature-kickoff.md"; }; then
  echo "任务拆解与开工模板缺少可复用证据要求" >&2
  exit 1
fi

if ! { grep -q 'tooling_prerequisite_ids' "$ROOT_DIR/references/plan/task-breakdown.md" && grep -q '工具前置清单' "$ROOT_DIR/references/stages/feature-kickoff.md"; }; then
  echo "任务拆解与开工模板缺少共享工具清单引用" >&2
  exit 1
fi

if ! grep -q '不得写入密码、验证码' "$ROOT_DIR/references/delivery/tooling-prerequisites.md"; then
  echo "tooling prerequisites missing credential redaction boundary" >&2
  exit 1
fi

if ! grep -q '每种方式最多两次完整尝试' "$ROOT_DIR/references/delivery/tooling-prerequisites.md" && ! grep -q '连续失败遵守证据驱动交付的尝试预算' "$ROOT_DIR/references/delivery/tooling-prerequisites.md"; then
  echo "third-party tooling rules missing UI control attempt budget" >&2
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

if ! { grep -q '目标项目已安装 impeccable 时' "$ROOT_DIR/references/stages/implementation.md"; }; then
  echo "实现阶段应仅在已安装时使用impeccable，不强制安装" >&2
  exit 1
fi

if ! { grep -q '视觉建议不能覆盖已确认产品规则' "$ROOT_DIR/references/stages/review.md"; }; then
  echo "审查阶段缺少视觉建议不能改写产品规则的边界" >&2
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

if ! { grep -q 'references/stages/goal-handoff.md' "$ROOT_DIR/AGENTS.md"; }; then
  echo "AGENTS缺少Goal交接路由" >&2
  exit 1
fi

if ! { grep -q 'references/stages/goal-handoff.md' "$ROOT_DIR/references/stages/implementation.md" && grep -q 'skills/goal-execute/SKILL.md' "$ROOT_DIR/references/stages/implementation.md"; }; then
  echo "实现阶段缺少Goal准备与恢复入口" >&2
  exit 1
fi

# Goal 第二版使用结构和状态语义检查，避免英文短语或固定切片数量绑住流程。
if ! command -v ruby >/dev/null 2>&1; then
  echo "Goal 契约检查需要 Ruby（仅使用标准库），未执行检查。" >&2
  exit 1
fi
ruby "$ROOT_DIR/scripts/check-goal.rb" --template "$ROOT_DIR/templates/goal"
ruby "$ROOT_DIR/scripts/test-check-goal.rb"
ruby -rjson -e '
  root = ARGV.fetch(0)
  cases = Dir.glob(File.join(root, "[0-9][0-9]-*" )).select { |p| File.directory?(p) }.sort
  required_ids = %w[01-real-identifier 02-e2e-business-result 03-upload-preview-intent 04-no-invented-legacy-data 05-fallback-is-not-real-mode 06-fix-family-and-impact 07-stale-status 08-ordinary-vs-foundation]
  missing = required_ids - cases.map { |dir| File.basename(dir) }
  abort("缺少既有行为场景：#{missing.join(", ")}") unless missing.empty?
  cases.each do |dir|
    input = File.join(dir, "input.md")
    expected = File.join(dir, "expected.json")
    abort("缺少场景输入或预期：#{dir}") unless File.file?(input) && File.file?(expected)
    data = JSON.parse(File.read(expected))
    abort("场景ID不匹配：#{dir}") unless data.fetch("case_id") == File.basename(dir)
    %w[expected_route must_include must_not].each do |key|
      items = data.fetch(key)
      abort("场景缺少非空#{key}：#{dir}") unless items.is_a?(Array) && !items.empty? && items.all? { |v| v.is_a?(String) && !v.empty? }
    end
  end
  puts "#{cases.length}组行为样例结构通过；未运行Agent，不能声称行为通过。"
' "$ROOT_DIR/evals/workflow-v2"

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

if [ "$REPO_ONLY" = false ]; then
  check_install_target "codex" "$HOME/.codex/skills"
  check_install_target "cursor" "$HOME/.cursor/skills"
else
  echo "仓库模式：未读取或修改全局安装链接。"
fi

echo "playbook 结构检查通过"

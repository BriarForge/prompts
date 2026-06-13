# ModernWorkplace Service Principal App-Only Auth Hardening Scope

**Category:** architecture  
**Tags:** [modernworkplace, service-principal, app-only, entra-id, powershell, m365, hermes-prime]

```text
Fable 5 one-shot mode (high effort, long-run scaffolding + git workflow enabled):

Objective: Produce a detailed, actionable scope document for significantly hardening and modernising the service-principal / app-only authentication implementation in the ModernWorkplace repository (branch feature/service-principal-app-only-auth). The scope must deliver a unified authentication and configuration architecture across all scripts while preserving full backward compatibility with existing interactive usage.

Grounding (verified paths):
- Repo root: /Users/mike/Projects/mainroads/DevOps/ModernWorkplace (Azure DevOps)
- Current branch: feature/service-principal-app-only-auth (v2.0.0 baseline)
- Key scripts: CreateModernWorkplace.ps1, Create-ProcurementTeams.ps1, LabelAutomation.ps1, LabelAutomationUpdateOwner.ps1, ProponentLabelAutomation.ps1
- Existing auth docs: docs/proposals/MWIP001-service-principal-setup.md, docs/proposals/MWIP001-service-principal-permissions-matrix.md
- Current state: Certificate thumbprint + ClientId/Organization parameters duplicated across scripts; interactive fallback via -servicePrincipal; PnP.PowerShell + ExchangeOnlineManagement modules

Scope (in this run):
- In: Full analysis of current authentication patterns, parameter surface, certificate handling, error paths, and configuration duplication.
- Primary output: /Users/mike/Projects/mainroads/DevOps/ModernWorkplace/docs/MWIP002-service-principal-auth-hardening-scope.md
- Allowed: Create the scope document with concrete recommendations, high-level architecture diagrams (Mermaid), migration phases, risk assessment, unified settings model, and a dedicated section on secrets / certificate management strategy.
- Out: Do not perform any code changes, certificate provisioning, or pipeline modifications in this run.
- Decide alone: Recommended authentication abstraction layer, configuration file format (or module), certificate storage options (thumbprint vs PFX vs Key Vault), logging/telemetry approach, and migration sequencing that keeps interactive mode untouched.
- Surface for human sign-off: Any decision that would require new Entra ID app registrations, changes to existing admin-consent permissions, or modifications to the Azure DevOps release pipeline.

Key areas the scope must cover:
1. Unified authentication architecture (single parameter set or helper module consumed by all scripts; elimination of duplicated -servicePrincipal vs -AppId/-CertificateThumbprint/-Organization surfaces)
2. Configuration and secrets management strategy (central config file, environment variables, or secure store; support for both interactive and unattended paths)
3. Certificate lifecycle (issuance, rotation, storage options including Azure Key Vault integration, fallback to local PFX, thumbprint resilience)
4. Error handling, logging, and diagnostics (consistent failure modes when cert is missing/expired/unauthorised, correlation IDs for pipeline runs)
5. Least-privilege permission verification tooling (script or module that audits the current app registration against the documented matrix)
6. CI/CD / Azure DevOps pipeline integration patterns (service connection usage, variable groups, secure file handling)
7. Phased migration roadmap with clear milestones, backward-compatibility guarantees, and rollback points
8. Risk register (thumbprint brittleness, certificate expiry in production, contributor onboarding, multi-tenant considerations)

Workflow contract:
- Use git-aoife for all commits and final push.
- Commit progressively after each major section.
- Output primary artifact: /Users/mike/Projects/mainroads/DevOps/ModernWorkplace/docs/MWIP002-service-principal-auth-hardening-scope.md
- Include: executive summary, detailed recommendations, Mermaid architecture diagrams, phased timeline (3–4 phases), explicit success criteria, and a "Recommended configuration model" statement.
- Final rubric self-score per /Users/mike/Projects/BriarForge/prompts/fable5/translation-layer/RUBRIC.md with evidence.

Done looks like:
1. MWIP002-service-principal-auth-hardening-scope.md exists and is comprehensive.
2. The unified auth layer is treated as a first-class workstream with concrete steps that all five scripts can adopt.
3. Certificate and secrets handling is defined such that both interactive and unattended modes consume the same underlying abstraction.
4. The document is committed and pushed via git-aoife from the feature/service-principal-app-only-auth branch.
5. Final rubric self-score per the translation-layer rubric with evidence.

Verification:
- The scope must be detailed enough that a developer could begin implementation without further high-level research.
- All recommendations must be grounded in the current script parameter lists and MWIP001 documents.
- End with explicit "Recommended auth abstraction: ..." and "Recommended certificate strategy: ..." statements.

If blocked:
- Parameter surface changes would break existing callers → propose adapter layer or parameter aliases.
- Azure Key Vault integration requires new infrastructure → provide on-prem / local-first fallback path first.
```

## Notes
- This prompt is additive to the existing MWIP001 service-principal documentation.
- Treat the hardening work as a strategic reliability and maintainability improvement, not a rewrite of business logic.
- The unified auth layer should be presented as an enabler for future pipeline automation and scheduled runs.
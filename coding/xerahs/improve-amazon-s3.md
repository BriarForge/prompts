---
tags: [xerahs, amazon-s3, aws, plugin, hardening, reusable]
category: xerahs
version: 1
---

# Improve Amazon S3 / AWS implementation

```text
You are improving the existing Amazon S3 / AWS implementation in XerahS. Host: /Users/mike/Projects/KovaForge/xerahs. Stay on existing develop. Follow root AGENTS.md. No new branches or issues. Verify with dotnet build and the S3 tests under tests/XerahS.Tests/Uploaders/.

User intent: make Amazon S3 / AWS better. Unify, harden, close real gaps. No new destination. No second UI stack.

Live surface (cite these; do not invent files):
- Plugin: src/desktop/plugins/AmazonS3.Plugin/ (AmazonS3Provider, AmazonS3Uploader, S3ConfigModel, S3AuthMode, S3CredentialSecrets, S3Provisioner, AwsS3Signer, AwsSso*, Multipart/S3MultipartUploader + Options, config VM + Avalonia view).
- AWSSDK.S3 4.0.101.6 in Directory.Packages.props.
- Mobile check only: android S3Uploader.kt + S3ConfigScreen.kt; ios S3ConfigScreen.swift + UploadScreen.swift. src/mobile-experimental/ is out of scope.

Status: XIP0054 (multipart) is Complete - do not re-implement. XIP0027 (SSO + auto-provision) is Open; SSO files already exist. Trust the live tree; XIP0027 cites stale src/Plugins/ShareX.AmazonS3.Plugin/ paths.

Investigate first:
1. Map: S3ConfigModel / S3CredentialSecrets -> AccessKeys vs AwsSso -> AwsS3Signer single PUT vs IAmazonS3 multipart -> returned URL / custom domain / ACL.
2. Dual-client smell: where AwsS3Signer and IAmazonS3 overlap; can one die without breaking the access-key happy path?
3. Real gaps only vs XIP0054 leftovers and XIP0027 actual code: abort, part-retry, memory, progress, cancel, secret-in-log. Plus secret-store hygiene and mobile-parity gaps.
4. Which existing tests cover which paths.

Deliver: current vs target; broken paths with file + line ranges; smallest-diff plan; per-file diffs; verify (dotnet build, S3 tests, manual access-key + SSO, mobile S3 config save/load); residual risk.

Constraints: reuse plugin abstractions; no architecture rewrite unless collapsing dual-client is the smallest fix; no secrets in repo or logs; code only after map + plan.
```

# Notes
- Feature + investigation, not bug-fix. Blends feature-or-investigate and understand-and-refactor-unfamiliar-code.
- XIP0054 is Complete - do not re-implement. XIP0027 is Open; trust live tree over XIP paths.
- Mobile parity is a check, not an expansion. src/mobile-experimental/ is out of scope.
- 1979 chars in the fenced body (under the 2k paste cap). Discord paste drops the <@> mention; send the fenced body alone.
- Stays under coding/xerahs/ (repo path, develop, AGENTS.md, no new branches).
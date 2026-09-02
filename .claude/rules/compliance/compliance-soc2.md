# SOC 2 Type II & ISO 27001 Compliance Rules

Load when: `compliance.soc2: true` — B2B SaaS selling to US/EU enterprises.
SOC 2 and ISO 27001 share ~70% of controls. Both covered here.

---

## The 5 Trust Service Criteria (TSC)

SOC 2 audits against these. Every control maps to one or more.

| Criteria | What It Means | Priority |
|----------|--------------|---------|
| **Security (CC)** | Protection against unauthorized access | Required |
| **Availability (A)** | System available as committed | Common addition |
| **Confidentiality (C)** | Confidential data protected | Common addition |
| **Processing Integrity (PI)** | Processing complete, valid, accurate | Fintech/data |
| **Privacy (P)** | PII collected, used, retained, disclosed per policy | If collecting PII |

**Minimum viable SOC 2:** Security criteria only (CC). Add others based on what enterprise customers ask for.

---

## Common Criteria (CC) — Security Controls

### CC1: Control Environment
- [ ] Organizational structure documented (who owns what)
- [ ] Security policies written and reviewed annually
- [ ] Roles and responsibilities defined for security functions
- [ ] Board/management oversight of security program documented

### CC2: Communication & Information
- [ ] Security policies communicated to all team members
- [ ] Incident communication protocol documented
- [ ] External communication (breach notification) protocol documented
- [ ] Vendor risk communication process documented

### CC3: Risk Assessment
- [ ] Annual risk assessment performed and documented
- [ ] Threat modeling for new features (document in DECISIONS.md)
- [ ] Risks tracked in risk register (add section to DECISIONS.md)
- [ ] Risk acceptance documented when controls are not implemented

### CC4: Monitoring
- [ ] Continuous monitoring via Cloudflare, Sentry, uptime monitoring
- [ ] Anomaly alerts configured (failed logins, unusual API patterns)
- [ ] Log retention 12 months (90 days hot, remainder cold)
- [ ] Quarterly internal control reviews

### CC5: Control Activities
- [ ] Change management: no direct commits to main, all changes reviewed
- [ ] Code review required before merge
- [ ] Deployment gated by CI/CD pipeline (tests, security scans)
- [ ] Config management: no hardcoded secrets, env vars only

### CC6: Logical & Physical Access
- [ ] MFA on all production systems, admin consoles, cloud providers
- [ ] RBAC with least privilege enforced
- [ ] Access provisioning and deprovisioning process documented
- [ ] Quarterly access reviews
- [ ] Production access limited — developers use staging, not prod data

### CC7: System Operations
- [ ] Vulnerability management: scan, patch SLAs documented
- [ ] Incident response plan in `docs/RUNBOOK.md`
- [ ] Backup and recovery tested quarterly
- [ ] Uptime SLA defined and monitored

### CC8: Change Management
- [ ] All changes tracked via git
- [ ] Schema migrations reviewed before execution
- [ ] Rollback capability for all deployments
- [ ] Release notes / changelog maintained

### CC9: Risk Mitigation
- [ ] Vendor contracts include security requirements
- [ ] DPAs in place with data processors
- [ ] Insurance: cyber liability reviewed annually

---

## Evidence Collection (What Auditors Ask For)

This is what makes SOC 2 painful. Start collecting evidence from day 1.

| Control | Evidence | How to Collect |
|---------|---------|----------------|
| MFA enabled | Screenshot + user list | Export from identity provider |
| Access reviews | Documented quarterly reviews | `docs/ACCESS_REVIEW.md` — date, reviewer, findings |
| Code reviews | PR history | Git provider (automatic) |
| Vuln scanning | Scan reports | `npm audit` output, Snyk reports — save to `docs/security/` |
| Pen test | Report from third party | Annual report saved to `docs/security/` |
| Training completed | Completion records | LMS export |
| Vendor DPAs | Signed agreements | `docs/vendors/` folder |
| Backup tests | Test results | `docs/backup-tests/` with dates |
| Incident log | All incidents documented | `docs/incidents/` |
| Risk assessment | Annual risk review doc | `docs/risk-assessment-YYYY.md` |

**Automate evidence collection where possible.** Many SOC 2 platforms (Vanta, Drata, Secureframe) integrate with GitHub, AWS, and identity providers to collect evidence automatically.

---

## ISO 27001 Additions

ISO 27001 requires an Information Security Management System (ISMS). Key additions over SOC 2:

- **Statement of Applicability (SoA):** Document all 93 controls from Annex A, justify inclusions/exclusions
- **ISMS Scope:** Define exactly what systems/processes are in scope
- **Internal audit:** Annual internal audit of the ISMS
- **Management review:** Annual review with leadership
- **Corrective actions:** Formal process for addressing nonconformities
- **Continual improvement:** Demonstrate the program gets better over time

---

## SOC 2 Readiness Checklist

**Before engaging an auditor (Type II requires 6-month observation period):**

- [ ] All CC1–CC9 controls implemented and documented
- [ ] Evidence collection process running (manual or automated)
- [ ] Incident log maintained (even for minor events)
- [ ] Access reviews completed quarterly for 6+ months
- [ ] Code review policy enforced in git for 6+ months
- [ ] Vulnerability scans run and documented for 6+ months
- [ ] Pen test completed within last 12 months
- [ ] Vendor inventory complete with DPAs
- [ ] All policies written: Security, Acceptable Use, Incident Response, Change Management
- [ ] Annual risk assessment documented
- [ ] Backup and recovery tested and documented

---

## Shared Controls Map (SOC 2 ↔ ISO 27001)

| SOC 2 | ISO 27001 Annex A | Control |
|-------|------------------|---------|
| CC6.1 | A.5.15, A.8.2 | Access control policy |
| CC6.3 | A.5.16, A.5.18 | User access management |
| CC7.1 | A.8.8 | Vulnerability management |
| CC7.2 | A.5.25, A.5.26 | Incident management |
| CC8.1 | A.8.32 | Change management |
| CC9.2 | A.5.19, A.5.20 | Supplier relationships |

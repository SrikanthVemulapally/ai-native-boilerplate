# Vendor Inventory

_Required for SOC 2, GDPR, HIPAA, and ISO 27001. Update when adding or removing vendors._
_Last reviewed: [date]_

## How to Use This File

For every third-party service that has access to your systems or user data:
1. Add a row to the table below
2. Classify the data they access (T1–T4)
3. Confirm DPA status (GDPR/DPDPA requirement for T3/T4)
4. Note BAA status (HIPAA requirement for PHI)
5. Record their compliance certifications

**Critical rule:** Never onboard a vendor who accesses T3/T4 data without a signed DPA.
**HIPAA rule:** Never send PHI to a vendor without a signed BAA.

---

## Core Vendor Inventory

| Vendor | Purpose | Data Access | Classification | DPA Signed | BAA Signed | Certifications | Review Date |
|--------|---------|-------------|----------------|------------|------------|----------------|-------------|
| Cloudflare | CDN, Workers, D1, R2 | App code, user data in DB | T2–T4 | ☐ Required | ☐ If PHI | SOC 2, ISO 27001 | [date] |
| Stripe | Payments | Billing data, payment tokens | T3–T4 | ☐ Required | N/A | PCI DSS Level 1, SOC 2 | [date] |
| Sentry | Error tracking | Errors, stack traces | T2–T3 | ☐ Required | ☐ If PHI | SOC 2 Type II | [date] |
| GitHub | Source code | Source code, secrets (encrypted) | T2 | ☐ | N/A | SOC 2, ISO 27001 | [date] |
| [Email Provider] | Transactional email | Email addresses | T3 | ☐ Required | ☐ If PHI | Varies | [date] |
| [Analytics] | Product analytics | Usage patterns | T1–T2 | ☐ | N/A | Varies | [date] |

---

## DPA Status Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | DPA signed and on file |
| ☐ Required | Must obtain before using with T3/T4 data |
| N/A | Vendor does not process personal data |

---

## How to Obtain DPAs

Most major vendors have self-service DPAs:
- **Cloudflare:** cloudflare.com/cloudflare-customer-dpa
- **Stripe:** dashboard.stripe.com → Settings → Data Processing Agreement
- **Sentry:** sentry.io/legal/dpa
- **GitHub:** GitHub Enterprise — contact sales for DPA
- **Resend:** resend.com/dpa
- **SendGrid:** sendgrid.com/policies/dpa

For smaller vendors without a standard DPA: use the EU Standard Contractual Clauses (SCCs) template and ask them to sign.

---

## Annual Vendor Review Checklist

Run this review every 12 months:

- [ ] All vendors with T3/T4 access confirmed to have valid DPAs
- [ ] SOC 2 / ISO 27001 reports collected and reviewed (not expired)
- [ ] Any new vendors added in the last year reviewed and documented
- [ ] Any vendors removed in the last year removed from this inventory
- [ ] HIPAA BAAs verified for any vendor touching PHI
- [ ] Vendor security incidents in the last 12 months noted
- [ ] Next review date set

_Review completed by: [name] on [date]_

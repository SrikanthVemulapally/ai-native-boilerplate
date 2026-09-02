# Email Templates — Transactional Design Rules

> Transactional emails are UI. They represent your brand in inboxes you don't control.
> Every email client renders differently. These rules ensure consistency.

---

## Stack

| Tool | Purpose |
|---|---|
| **react-email** | Component-based email templates (React) |
| **Resend** | Email delivery API (preferred) |
| **@react-email/components** | Cross-client email primitives |

```bash
pnpm add react-email @react-email/components resend
```

---

## Required Transactional Emails

Every SaaS must have these at launch:

| Email | Trigger | Priority |
|---|---|---|
| Welcome / Verify email | Signup | P0 |
| Magic link / OTP | Passwordless login | P0 |
| Password reset | Forgot password | P0 |
| Team invitation | User invited | P0 |
| Invoice / Receipt | Payment success | P0 |
| Trial ending | 7 days, 3 days, 1 day before | P1 |
| Payment failed | Card decline | P1 |
| Subscription cancelled | User cancels | P1 |
| Weekly digest | Cron trigger | P2 |
| Security alert | New device login | P1 |

---

## react-email Structure

```tsx
// emails/welcome.tsx
import {
  Body, Button, Container, Head, Heading, Hr,
  Html, Img, Preview, Section, Text, Tailwind
} from '@react-email/components'

interface WelcomeEmailProps {
  userFirstName: string
  verifyUrl: string
}

export function WelcomeEmail({ userFirstName, verifyUrl }: WelcomeEmailProps) {
  return (
    <Html lang="en" dir="ltr">
      <Head />
      <Preview>Welcome to YourApp — verify your email to get started</Preview>
      <Tailwind>
        <Body className="bg-[#f6f9fc] font-sans">
          <Container className="mx-auto py-8 px-4 max-w-[600px]">

            {/* Header */}
            <Img src="https://yourapp.com/logo.png" alt="YourApp"
                 width="120" height="40" className="mx-auto mb-8" />

            {/* Card */}
            <Section className="bg-white rounded-lg p-8 shadow-sm">
              <Heading className="text-2xl font-bold text-gray-900 mb-2">
                Welcome, {userFirstName}!
              </Heading>
              <Text className="text-gray-600 mb-6">
                Thanks for signing up. Verify your email to activate your account.
              </Text>
              <Button href={verifyUrl}
                      className="bg-[#18181b] text-white rounded-md px-6 py-3
                                 text-sm font-medium no-underline block text-center">
                Verify Email
              </Button>
              <Text className="text-xs text-gray-400 mt-4">
                Button not working?{' '}
                <a href={verifyUrl} className="text-gray-600 underline">
                  Copy this link
                </a>
              </Text>
            </Section>

            {/* Footer */}
            <Hr className="border-gray-200 my-6" />
            <Text className="text-xs text-gray-400 text-center">
              YourApp, 123 Street, City, Country
              <br />
              <a href="https://yourapp.com/unsubscribe" className="underline">
                Unsubscribe
              </a>
              {' · '}
              <a href="https://yourapp.com/privacy" className="underline">
                Privacy Policy
              </a>
            </Text>
          </Container>
        </Body>
      </Tailwind>
    </Html>
  )
}

export default WelcomeEmail
```

---

## Email Design Rules

### Layout
- **Max width: 600px.** The universal email safe zone. Some clients (Outlook) force 600px.
- **Single column always.** Multi-column emails break on mobile. One column only.
- **Table-based layout (handled by react-email).** `<Container>`, `<Section>`, `<Row>` compile to tables.
- **No floats, no flexbox, no grid.** Email clients don't support them consistently.
- **Inline styles.** Many clients (Gmail, Outlook) strip `<style>` tags. react-email handles this.

### Typography
- **Web-safe fonts only (inline, email clients):** Arial, Helvetica, Georgia, Times New Roman.
- **System font stack:** `font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif`
- **Minimum font size: 14px.** Mobile clients scale up smaller text, causing layout issues.
- **Line height: 1.5-1.6** for body text.
- **Left-align body text.** Center only for headings, CTAs, footers.

### CTAs (Call to Action)
```tsx
// ✅ Bulletproof button — works in all clients including Outlook
<Button
  href={ctaUrl}
  className="bg-[#18181b] text-white rounded-md px-6 py-3
             font-medium text-sm no-underline inline-block"
>
  Action Text
</Button>

// ✅ Always include a text fallback
<Text className="text-xs text-gray-400 mt-2">
  Or paste this link: <a href={ctaUrl}>{ctaUrl}</a>
</Text>
```

**CTA rules:**
- One primary CTA per email. Two at most.
- Button text: action verb + object. "Verify Email." "View Invoice." "Upgrade Now."
- Button color matches your primary brand color.
- Minimum button size: 44px tall, 200px wide.

### Images
```tsx
// ✅ Always specify width and height
<Img src="https://yourapp.com/logo.png" alt="YourApp" width="120" height="40" />

// ✅ Use absolute URLs — relative paths don't work in email
// ✅ Host images on CDN — email clients cache images aggressively
// ✅ Add alt text — many clients block images by default
```

**Image rules:**
- Absolute URLs only — no relative paths
- Always specify width + height
- Always include meaningful alt text
- Don't rely on images to convey critical information — text is always visible, images may not be
- Max image width: 600px

---

## Dark Mode Email

Email dark mode is handled differently than web dark mode. Some clients auto-invert, others support `prefers-color-scheme`.

```tsx
// In <Head /> — dark mode media query for supporting clients
<style>{`
  @media (prefers-color-scheme: dark) {
    .email-body { background-color: #1a1a1a !important; }
    .email-card { background-color: #2a2a2a !important; }
    .email-text { color: #e4e4e7 !important; }
    .email-muted { color: #a1a1aa !important; }
  }
`}</style>
```

**Dark mode rules:**
- Test in Gmail dark mode (Android + iOS)
- Test in Apple Mail dark mode
- Images: avoid pure white logos — they disappear on dark backgrounds. Use transparent backgrounds or include a dark-mode variant:
```html
<!-- Logo with dark mode variant -->
<img src="logo-light.png" alt="YourApp"
     style="display:block" class="logo-light" />
<img src="logo-dark.png" alt="YourApp"
     style="display:none" class="logo-dark" />
<!-- CSS media query shows/hides appropriately -->
```

---

## Preview Text

The preview text appears in the inbox after the subject line. Always set it.

```tsx
// ✅ Meaningful preview text — appears in inbox snippet
<Preview>Your invoice #1234 for $99 is ready to download</Preview>

// ❌ Don't let it default to your first sentence
// ❌ Don't repeat the subject line
// ✅ Complement the subject: subject = "Your invoice", preview = add detail
```

---

## Sending via Resend

```typescript
// lib/email.ts
import { Resend } from 'resend'
import { render } from '@react-email/render'
import { WelcomeEmail } from '@/emails/welcome'

const resend = new Resend(process.env.RESEND_API_KEY)

export async function sendWelcomeEmail(user: { email: string; firstName: string }, verifyUrl: string) {
  const html = await render(WelcomeEmail({ userFirstName: user.firstName, verifyUrl }))

  const { data, error } = await resend.emails.send({
    from: 'YourApp <hello@yourapp.com>',
    to: user.email,
    subject: 'Welcome to YourApp — verify your email',
    html,
    tags: [{ name: 'category', value: 'onboarding' }],  // for analytics
  })

  if (error) {
    console.error('Email send failed:', error)
    throw new Error(`Email send failed: ${error.message}`)
  }

  return data
}
```

**Email sending rules:**
- Always use a verified sending domain — not a free Gmail/Outlook
- `from` name should match your product (not your personal name)
- Include `Reply-To` for transactional emails where replies make sense
- Log email send attempts and failures to your error tracker
- Never send emails from a Cloudflare Worker synchronously — use a Queue:

```typescript
// ✅ Queue email sends — don't block the response
await env.EMAIL_QUEUE.send({ type: 'welcome', userId: user.id, verifyUrl })

// Worker picks up from queue, sends email
export default {
  async queue(batch: MessageBatch<EmailJob>, env: Env) {
    for (const message of batch.messages) {
      await sendEmail(message.body, env)
      message.ack()
    }
  }
}
```

---

## Email Preview & Testing

```bash
# react-email dev server — preview in browser
pnpm email:dev   # runs react-email preview at localhost:3001

# Test in real clients before launch
# - Gmail (web, iOS, Android)
# - Apple Mail (macOS, iOS)
# - Outlook (Windows, macOS, web)
# - Use Litmus or Email on Acid for full client testing
```

---

## Email Checklist

- [ ] Preview text set (not empty)
- [ ] Subject line ≤ 50 characters
- [ ] Single CTA per email (two max)
- [ ] Fallback URL text below every button
- [ ] All images have alt text and absolute URLs
- [ ] Unsubscribe link in footer (legally required for marketing)
- [ ] Physical address in footer (CAN-SPAM requirement)
- [ ] Privacy policy link
- [ ] Tested in Gmail web dark mode
- [ ] Tested in Apple Mail dark mode
- [ ] Tested on mobile (375px — iPhone SE)
- [ ] Sending domain has SPF, DKIM, DMARC records
- [ ] Email queued via Cloudflare Queue (not sent synchronously)

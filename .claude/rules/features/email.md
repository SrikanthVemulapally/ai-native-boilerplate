# Feature Rules: Email
> Loaded when: features.email=true

## Stack: Resend + React Email

```
packages/emails/
  templates/
    welcome.tsx         ← Welcome email
    magic-link.tsx      ← Magic link / OTP
    subscription.tsx    ← Subscription confirmation
    payment-failed.tsx  ← Payment failure alert
  index.ts             ← Email send function
```

## Send Pattern

```typescript
// packages/emails/index.ts
import { Resend } from 'resend'
import { render } from '@react-email/render'

export async function sendEmail<T extends Record<string, unknown>>(
  env: Env,
  to: string,
  template: (props: T) => React.ReactElement,
  props: T,
  subject: string,
) {
  const resend = new Resend(env.RESEND_API_KEY)
  const html = render(template(props))
  
  const { data, error } = await resend.emails.send({
    from: `${env.EMAIL_FROM_NAME} <${env.EMAIL_FROM_ADDRESS}>`,
    to,
    subject,
    html,
  })
  
  if (error) throw new Error(`Email failed: ${error.message}`)
  return data
}
```

## Rules

- **All emails use React Email templates.** No raw HTML strings. No string templates.
- **Test emails with Resend's test mode in dev.** Never send to real users from dev/staging.
- **Unsubscribe link in every marketing email.** Required by CAN-SPAM / GDPR.
- **Transactional emails from `noreply@`.** Marketing from `hello@` or `team@`.
- **Email queued via Cloudflare Queue.** Never block API responses waiting for email send.
- **Preview all templates before deploy.** `pnpm email:preview` renders in browser.
- **Plain text fallback for every email.** Not all clients render HTML.

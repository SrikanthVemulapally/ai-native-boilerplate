# Components — shadcn/ui Catalog & Usage Rules

> shadcn/ui is not a component library. It is how you build your component library. Components are copied into your project — you own the code.

## Why shadcn/ui

- **AI-native** — v0, Bolt, Cursor, Copilot all generate shadcn/ui by default
- **Open code** — full source in your repo, LLMs can read and modify
- **Accessible** — built on Radix UI primitives, WCAG compliant out of the box
- **Composable** — predictable API across all components
- **Themeable** — CSS variables, not hardcoded styles
- **No lock-in** — copy in, customize, own forever

## Component Catalog

### Layout & Navigation

| Component | When to Use | Key Props |
|---|---|---|
| `Sidebar` | Admin dashboards, app shells | `collapsible`, `variant` |
| `NavigationMenu` | Top nav with dropdowns | `orientation` |
| `Menubar` | Desktop menu bars | — |
| `Breadcrumbs` | Deep navigation context | `separator` |
| `Pagination` | List/table navigation | — |
| `Tabs` | Section switching within a page | `variant` |
| `ScrollArea` | Custom scrollable regions | `orientation` |

### Surfaces & Containers

| Component | When to Use | Key Props |
|---|---|---|
| `Card` | Grouping related content | — |
| `Sheet` | Slide-in panel (mobile-first) | `side` |
| `Drawer` | Bottom sheet panel | — |
| `Dialog` | Modal overlay (focus) | — |
| `AlertDialog` | Confirmation for destructive actions | — |
| `Separator` | Visual divider | `orientation` |
| `Resizable` | User-adjustable panels | — |

### Forms & Input

| Component | When to Use | Key Props |
|---|---|---|
| `Input` | Single-line text | `type` |
| `Textarea` | Multi-line text | — |
| `Select` | Dropdown selection | — |
| `Combobox` | Searchable dropdown | — |
| `Checkbox` | Multi-select | — |
| `RadioGroup` | Single select from options | — |
| `Switch` | Binary toggle | — |
| `Slider` | Range selection | `min`, `max`, `step` |
| `DatePicker` | Date selection | — |
| `InputOTP` | Verification codes | `length` |
| `Label` | Form field labels | — |
| `Field` | Form field wrapper (label+input+error) | — |

### Feedback & Status

| Component | When to Use | Key Props |
|---|---|---|
| `Toast` / `Sonner` | Transient notifications | `variant` |
| `Alert` | Inline page-level message | `variant` |
| `AlertDialog` | Destructive confirmation | — |
| `Progress` | Task completion indicator | `value` |
| `Skeleton` | Loading placeholder | — |
| `Spinner` | Inline loading | `size` |
| `Tooltip` | Contextual hint on hover | `side` |
| `HoverCard` | Rich preview on hover | — |
| `Popover` | Floating content | — |

### Data Display

| Component | When to Use | Key Props |
|---|---|---|
| `Table` | Static data display | — |
| `DataTable` | Sortable/filterable/paginated | `columns`, `data` |
| `Badge` | Status, category, count | `variant` |
| `Avatar` | User/org representation | `src`, `fallback` |
| `Accordion` | Collapsible content sections | `type` |
| `Collapsible` | Toggle visibility | — |
| `Carousel` | Horizontal scrolling content | — |
| `Chart` | Data visualization (Recharts) | `config` |

### Actions

| Component | When to Use | Key Props |
|---|---|---|
| `Button` | Primary action trigger | `variant`, `size` |
| `ButtonGroup` | Related actions | — |
| `DropdownMenu` | Action overflow menu | — |
| `ContextMenu` | Right-click actions | — |
| `Command` | Command palette (Cmd+K) | — |
| `Toggle` | Binary state button | — |
| `ToggleGroup` | Multi-option toggle | `type` |

## Button Variants — Decision Tree

```
Is this the primary action on the page?
  → YES → variant="default" (primary color)
  → NO → Is it a secondary action?
    → YES → variant="secondary"
    → NO → Is it destructive?
      → YES → variant="destructive"
      → NO → Is it in a compact space (toolbar, table row)?
        → YES → variant="ghost" size="sm" or size="icon"
        → NO → Is it an outline-style action?
          → YES → variant="outline"
          → NO → variant="ghost"
```

### Button Sizes

| Size | Height | When |
|---|---|---|
| `sm` | 32px | Tables, toolbars, inline |
| `default` | 40px | Standard UI |
| `lg` | 44px | Landing pages, CTAs |
| `icon` | 40x40px | Icon-only buttons |

## Component Composition Rules

1. **One component per concern.** Don't build a `UserCard` that's also a form. Build `Card` + `Form` separately.
2. **Compose, don't wrap.** Use `<Card><CardHeader><CardTitle>` not `<UserCard>`.
3. **Props pass through.** All custom wrappers must spread `...props` to the underlying shadcn component.
4. **Never override Radix behavior.** If you need different behavior, build a new component — don't fight Radix.
5. **Keep components small.** If a component file exceeds 150 lines, split it.

## When shadcn/ui Doesn't Have What You Need

1. **Search the registry** — `npx shadcn@latest add <block-name>` for pre-built blocks
2. **Check shadcn blocks** — full page sections (auth, dashboard, marketing)
3. **Check Magic UI** — animated components (marquee, globe, border-beam)
4. **Check Aceternity UI** — premium landing page components
5. **Build custom** — only if none of the above work. Follow the composition rules.

## Mandatory Components (Every Project)

These must be installed in every project:

```bash
npx shadcn@latest add button card input label textarea select \
  checkbox radio-group switch dialog alert-dialog sheet drawer \
  toast sonner tooltip dropdown-menu navigation-menu breadcrumb \
  tabs avatar badge separator skeleton progress table data-table \
  form command popover scroll-area sidebar
```

## Component Customization Rules

1. **Edit the copied source** — don't create wrappers that override styles
2. **Use tokens, not hardcoded values** — `bg-primary` not `bg-[#3b82f6]`
3. **Keep Radix props** — don't strip accessibility features
4. **Document deviations** — if you change a component significantly, note why in a comment
5. **Test in both themes** — light and dark, every time

## Anti-Patterns

- ❌ Installing Material UI alongside shadcn — conflicting systems
- ❌ Using `!important` to override shadcn styles — fix the token instead
- ❌ Building a custom modal when `Dialog` exists
- ❌ Wrapping shadcn components in unnecessary HOCs
- ❌ Importing from `shadcn-ui` package — components are local files
- ❌ Using non-tabular numbers in DataTable


## CVA — Class Variance Authority (Variant Architecture)

When building custom components that need multiple visual variants, use CVA. This is how shadcn/ui itself is built. It gives you type-safe variants with zero runtime overhead.

```bash
pnpm add class-variance-authority clsx tailwind-merge
```

### The Pattern
```tsx
import { cva, type VariantProps } from 'class-variance-authority'
import { clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

// ✅ Utility: merge Tailwind classes safely (prevents class conflicts)
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

// ✅ Define variants with CVA
const badgeVariants = cva(
  // Base classes — always applied
  'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium',
  {
    variants: {
      variant: {
        default:     'bg-primary text-primary-foreground',
        secondary:   'bg-secondary text-secondary-foreground',
        destructive: 'bg-destructive text-destructive-foreground',
        outline:     'border border-border text-foreground',
        success:     'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
        warning:     'bg-amber-100 text-amber-800 dark:bg-amber-900 dark:text-amber-200',
      },
      size: {
        sm: 'px-2 py-0.5 text-xs',
        md: 'px-2.5 py-0.5 text-xs',
        lg: 'px-3 py-1 text-sm',
      }
    },
    defaultVariants: {
      variant: 'default',
      size: 'md',
    }
  }
)

// ✅ Component uses VariantProps for full type safety
interface BadgeProps
  extends React.HTMLAttributes<HTMLDivElement>,
          VariantProps<typeof badgeVariants> {}

export function Badge({ className, variant, size, ...props }: BadgeProps) {
  return (
    <div className={cn(badgeVariants({ variant, size }), className)} {...props} />
  )
}

// Usage — TypeScript catches invalid variant values at compile time
<Badge variant="success" size="sm">Active</Badge>
<Badge variant="warning">Pending</Badge>
<Badge variant="invalid" /> // ← TypeScript error: Type '"invalid"' is not assignable
```

### When to Use CVA

- Building a custom component that has 2+ visual variants
- Wrapping a shadcn component to add project-specific variants
- Status badges (active/inactive/pending/error)
- Alert/callout boxes with type variants
- Button-like elements that aren't standard buttons

### When NOT to Use CVA

- One-off styling changes — just use `cn()` directly
- When shadcn/ui already has the variant you need
- Server components where bundle size is critical (CVA adds ~1KB)

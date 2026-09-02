/** @type {import("prettier").Config} */
export default {
  semi:           false,
  singleQuote:    true,
  tabWidth:       2,
  useTabs:        false,
  trailingComma:  'all',
  printWidth:     100,
  arrowParens:    'always',
  endOfLine:      'lf',
  plugins:        ['prettier-plugin-tailwindcss'],
  overrides: [
    {
      files: ['*.json', '*.jsonc'],
      options: { trailingComma: 'none' }
    },
    {
      files: ['*.md'],
      options: { proseWrap: 'always', printWidth: 80 }
    }
  ]
}

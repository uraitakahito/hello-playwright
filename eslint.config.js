import js from '@eslint/js';
import { flatConfigs as importFlatConfigs } from 'eslint-plugin-import-x';
import prettier from 'eslint-plugin-prettier/recommended';
import globals from 'globals';

export default [
  {
    ignores: ['node_modules/**', '.Trash-*/**'],
  },
  js.configs.recommended,
  importFlatConfigs.recommended,
  prettier,
  {
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.node,
      },
    },
    rules: {
      // Strict rules
      strict: 'error',
      'no-console': 'warn',
      'no-unused-vars': 'error',
      'no-undef': 'error',
      'no-var': 'error',
      'prefer-const': 'error',
      'no-magic-numbers': ['warn', { ignore: [0, 1] }],
      eqeqeq: ['error', 'always'],
      curly: ['error', 'all'],
      'no-implicit-coercion': 'error',
      'no-else-return': 'error',
      'no-empty-function': 'error',
      'no-eval': 'error',
      'no-implied-eval': 'error',
      'no-new-func': 'error',
      'no-return-await': 'error',
      'require-await': 'error',
      'no-shadow': 'error',
      'no-use-before-define': 'error',
      camelcase: 'error',
      'no-nested-ternary': 'error',
      'no-unneeded-ternary': 'error',
      'prefer-arrow-callback': 'error',
      'prefer-template': 'error',
      'no-duplicate-imports': 'error',
      'sort-imports': ['error', { ignoreDeclarationSort: true }],

      // Import plugin rules
      'import-x/order': [
        'error',
        {
          groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
          'newlines-between': 'always',
          alphabetize: { order: 'asc', caseInsensitive: true },
        },
      ],
      'import-x/no-duplicates': 'error',
      'import-x/no-unresolved': 'off',
      'import-x/extensions': ['error', 'always', { ignorePackages: true }],
    },
  },
  {
    files: ['**/*.cjs'],
    languageOptions: {
      sourceType: 'commonjs',
      globals: {
        ...globals.commonjs,
        ...globals.node,
      },
    },
    rules: {
      strict: 'off',
    },
  },
];

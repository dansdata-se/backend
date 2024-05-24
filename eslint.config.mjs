// @ts-check

import eslint from "@eslint/js";
import eslintConfigPrettier from "eslint-config-prettier";
import tseslint from "typescript-eslint";

export default [
  {
    ignores: [
      "node_modules",
      "dist",
      "commitlint.config.js",
      "eslint.config.js",
    ],
  },
  // Not sure why eslint complains about `eslint` here
  // but it works just fine so just ignore complaint.
  eslint.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  ...tseslint.configs.stylisticTypeChecked,
  ...tseslint.configs.strictTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        project: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
  },
  eslintConfigPrettier,
  {
    files: ["**/*.js", "**/*.mjs", "**/*.ts", "**/*.mts"],
    rules: {
      "no-fallthrough": "off",
      eqeqeq: "error",
      "@typescript-eslint/no-namespace": [
        "error",
        {
          allowDeclarations: true,
        },
      ],
      "no-restricted-imports": [
        "error",
        {
          patterns: [
            { group: ["/.*"], message: "Use `@/` for local imports." },
          ],
        },
      ],
      "@typescript-eslint/no-invalid-void-type": [
        "error",
        { allowAsThisParameter: true },
      ],
    },
  },
];

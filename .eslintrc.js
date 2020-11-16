module.exports = {
    root: true,
    parser: "@typescript-eslint/parser",
    "parserOptions": {
        "ecmaVersion": 2020
    },
    plugins: [
        "@typescript-eslint",
        "jest"
    ],
    extends: [
        "eslint:recommended",
        "plugin:@typescript-eslint/recommended",
        "plugin:jest/style",
        "plugin:eslint-comments/recommended",
        "plugin:import/warnings",
        "plugin:import/errors",
        "plugin:import/typescript",
        "plugin:node/recommended"
    ],
    "rules": {
        "jest/no-disabled-tests": "warn",
        "jest/no-focused-tests": "error",
        "jest/no-identical-title": "error",
        "jest/prefer-to-have-length": "warn",
        "jest/valid-expect": "error",
        "eslint-comments/no-unused-disable": "error",
        "no-console": 0,
        "semi": [
            "error",
            "always"
        ],
        "newline-before-return": 2,
        "indent": [
            "error",
            2, {
                "SwitchCase": 1
            }
        ],
        "quotes": [ "error", "double", { "allowTemplateLiterals": true } ],
        "object-curly-spacing": [ "error", "always" ],
        "array-bracket-spacing": [ "error", "always", {
            "singleValue": false
        } ],
        "arrow-body-style": [ "error", "as-needed" ],
        "computed-property-spacing": [ "error", "never" ],
        "no-multiple-empty-lines": [ "error", { "max": 1, "maxBOF": 0 } ],
        "prefer-arrow-callback": "error",
        "func-style": [ "warn", "expression" ],
        "no-multi-spaces": [ "error", { "ignoreEOLComments": false } ],
        "keyword-spacing": "error",
        "@typescript-eslint/semi": [
            "error",
            "always"
        ],
        "@typescript-eslint/indent": [
            "error",
            2, {
                "SwitchCase": 1
            }
        ],
        "@typescript-eslint/explicit-function-return-type": [
            "error",
            {
                "allowExpressions": true
            }
        ],
        "@typescript-eslint/member-delimiter-style": [
            "error",
            {
                "multiline": {
                    "delimiter": "none"
                },
            }
        ],
        "@typescript-eslint/interface-name-prefix": ["off"],
        "@typescript-eslint/camelcase": ["off"],
        "@typescript-eslint/no-use-before-define": ["off"],
        "@typescript-eslint/ban-ts-ignore": ["off"],
        "@typescript-eslint/no-inferrable-types": ["off"],
        "@typescript-eslint/no-unused-vars": [
            "error", {
                "argsIgnorePattern": "^_"
            }
        ],
        "@typescript-eslint/no-explicit-any": "error",
        "@typescript-eslint/explicit-member-accessibility": "error"
    },
    "env": {
        "jest": true,
        "jest/globals": true
    }
};

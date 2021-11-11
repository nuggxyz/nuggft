/** @format */

module.exports = {
    parser: '@typescript-eslint/parser', // Specifies the ESLint parser
    extends: ['universe/node'],
    plugins: ['prettier', 'unused-imports', 'import'],
    rules: {
        'prettier/prettier': 'error',
        '@typescript-eslint/no-unused-vars': 'off',
        // 'no-unused-vars': 'off',
        'unused-imports/no-unused-imports': 'error',
        // 'unused-imports/no-unused-vars': [
        //     'off',
        //     {
        //         vars: 'all',
        //         varsIgnorePattern: '^_',
        //         args: 'after-used',
        //         argsIgnorePattern: '^_',
        //     },
        // ],
        'import/order': [
            'error',
            {
                'newlines-between': 'always',
                groups: ['builtin', 'external', 'parent', 'sibling', 'index'],
            },
        ],
    },
};

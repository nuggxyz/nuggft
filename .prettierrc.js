/** @format */

module.exports = {
    trailingComma: 'all',
    tabWidth: 4,
    singleQuote: true,
    jsxBracketSameLine: true,
    printWidth: 140,

    overrides: [
        {
            files: '*.sol',
            options: {
                printWidth: 120,
                tabWidth: 4,
                useTabs: false,
                //  singleQuote: false,
                bracketSpacing: false,
                explicitTypes: 'always',
            },
        },
    ],
};

module.exports = {
  root: true,
  env: {
    node: true
  },
  extends: [
    'plugin:vue/essential',
    '@vue/standard'
  ],
  rules: {
    // allow paren-less arrow functions
    'arrow-parens': 0,
    // allow async-await
    'generator-star-spacing': 0,
    // vuejs screws up this anyways
    'no-use-before-define': 0,
    // allow debugger during development
    'standard/no-callback-literal': 0,
    'no-debugger': process.env.NODE_ENV === 'production' ? 2 : 0,
    'vue/no-v-html': 0,
    'vue/html-end-tags': 1,
    'vue/html-self-closing': 0,
    'vue/html-closing-bracket-newline': ['error', {
      singleline: 'never',
      multiline: 'never'
    }],
    'vue/html-closing-bracket-spacing': 1,
    'vue/html-indent': 1,
    'vue/mustache-interpolation-spacing': 1,
    'vue/multiline-html-element-content-newline': 1,
    'vue/max-attributes-per-line': ['error', {
      singleline: 1,
      multiline: {
        max: 1,
        allowFirstLine: false
      }
    }],
    'vue/no-mutating-props': 0,
    'vue/attributes-order': 1,
    'vue/order-in-components': 1,
    'vue/this-in-template': 1
  },
  parserOptions: {
    parser: 'babel-eslint'
  }
}

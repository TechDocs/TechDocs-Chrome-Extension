import riot from 'rollup-plugin-riot'
import nodeResolve from 'rollup-plugin-node-resolve'
import postcss from 'postcss'
import cssnext from 'postcss-cssnext'

export default {
  external: ['riot'],
  globals: { riot: 'riot' },
  plugins: [
    riot({
      style: 'cssnext',
      parsers: {
        css: { cssnext: (tagName, css) => {
          // A small hack: it passes :scope as :root to PostCSS.
          // This make it easy to use css variables inside tags.
          css = css.replace(/:scope/g, ':root')
          css = postcss([cssnext]).process(css).css
          css = css.replace(/:root/g, ':scope')
          return css
        }}
      }
    }),
    nodeResolve({jsnext: true})
  ],
  format: 'iife'
}

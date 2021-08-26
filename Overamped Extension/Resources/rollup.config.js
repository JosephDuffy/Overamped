import svelte from "rollup-plugin-svelte"
import commonjs from "@rollup/plugin-commonjs"
import resolve from "@rollup/plugin-node-resolve"
import { terser } from "rollup-plugin-terser"
import css from "rollup-plugin-css-only"
import sveltePreprocess from "svelte-preprocess"
import typescript from "@rollup/plugin-typescript"

const production = !process.env.ROLLUP_WATCH

function serve() {
  let server

  function toExit() {
    if (server) server.kill(0)
  }

  return {
    writeBundle() {
      if (server) return
      server = require("child_process").spawn(
        "npm",
        ["run", "start-popup", "--", "--dev"],
        {
          stdio: ["ignore", "inherit", "inherit"],
          shell: true,
        },
      )

      process.on("SIGTERM", toExit)
      process.on("exit", toExit)
    },
  }
}

export default {
  input: "src/popup/src/main.ts",
  output: {
    sourcemap: false,
    format: "iife",
    name: "app",
    file: "build/popup/bundle.js",
  },
  plugins: [
    svelte({
      preprocess: sveltePreprocess({ sourceMap: !production }),
      compilerOptions: {
        // enable run-time checks when not in production
        dev: !production,
      },
    }),
    // we'll extract any component CSS out into
    // a separate file - better for performance
    css({ output: "build/popup/bundle.css" }),

    // If you have external dependencies installed from
    // npm, you'll most likely need these plugins. In
    // some cases you'll need additional configuration -
    // consult the documentation for details:
    // https://github.com/rollup/plugins/tree/master/packages/commonjs
    resolve({
      browser: true,
      dedupe: ["svelte"],
    }),
    commonjs(),
    typescript({
      sourceMap: !production,
      inlineSources: !production,
      module: "esnext",
    }),

    // In dev mode, call `npm run start` once
    // the bundle has been generated
    !production && serve(),

    // If we're building for production (npm run build
    // instead of npm run dev), minify
    production && terser(),
  ],
  watch: {
    clearScreen: false,
  },
}

import { defineConfig } from 'tsup';

export default defineConfig({
  entry: ['src/index.ts'],
  target: 'node18',
  format: ['cjs'],
  outDir: 'dist',
  clean: true,
  dts: false,
  minify: false,
  shims: false,
  splitting: false,
  sourcemap: false,
});

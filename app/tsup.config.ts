import { defineConfig } from 'tsup';

export default defineConfig({
  entry: ['src/index.ts'],
  outDir: 'dist',
  target: 'node18',
  format: ['esm'],
  splitting: false,
  sourcemap: false,
  clean: true,
  minify: true,
});
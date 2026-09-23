// Refresh the mobile catalogs from the sibling dashboard without modifying it.
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const web = process.argv[2] || path.resolve(__dirname, '../../FitnessDashboard');
const ts = require(path.join(web, 'node_modules/typescript'));
for (const name of ['meal', 'food', 'exercise']) {
  const source = fs.readFileSync(path.join(web, `lib/${name}-library.ts`), 'utf8');
  const compiled = ts.transpileModule(source, {compilerOptions: {module: ts.ModuleKind.CommonJS}}).outputText;
  const context = {exports: {}};
  vm.runInNewContext(compiled, context);
  const rows = context.exports[`${name}Library`];
  fs.writeFileSync(path.resolve(__dirname, `../assets/catalogs/${name}s.json`), JSON.stringify(rows, null, 2) + '\n');
  console.log(`${name}: ${rows.length} records`);
}

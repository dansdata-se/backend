import { $, cd, chalk, path } from "zx";

cd(path.resolve(__dirname, "../..", "src/db/"));

const statusCode = await $`bun --silent graphile-migrate status`.exitCode;
switch (statusCode) {
  case 0:
    console.log(chalk.green("✅ Up-to-date"));
    break;
  case 1:
  case 3:
    console.log(
      chalk.yellow("⚠️ One or more migrations have not yet been deployed")
    );
    if (statusCode === 1) {
      break;
    }
  case 2:
    console.log(
      chalk.yellow("⚠️ The current migration has not yet been committed")
    );
    break;
  default:
    console.error(`❌ Unknown status: ${statusCode?.toString() ?? "null"}`);
}

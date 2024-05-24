import { cleanEnv, str } from "envalid";
import { chalk } from "zx";

const env = cleanEnv(process.env, {
  ENVIRONMENT: str(),
});

const colorFn =
  {
    development: chalk.green,
    stage: chalk.yellow,
    production: chalk.red,
  }[env.ENVIRONMENT] ?? ((s) => chalk.magenta(s) + chalk.red(" (unknown!)"));
console.log("Current environment: " + chalk.bold(colorFn(env.ENVIRONMENT)));

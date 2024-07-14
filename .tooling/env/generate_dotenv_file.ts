import { cleanEnv, str } from "envalid";
import type { Dirent } from "fs-extra";
import { chalk, fs, path } from "zx";

const env = cleanEnv(process.env, {
  DOTENV_PATH: str(),
  SECRETS_PATH: str(),
});

function verifyVariable(name: string, seenVariables: Set<string>) {
  if (!/^[a-zA-Z_]+[a-zA-Z0-9_]*$/.test(name)) {
    console.error(chalk.red(`Filename '${name}' is not a valid variable name`));
    process.exit(1);
  }

  if (seenVariables.has(name)) {
    console.error(
      chalk.red(`CONFLICT: variable name '${name}' is declared more than once`)
    );
    process.exit(1);
  }
  seenVariables.add(name);
}

async function readDir(path: string) {
  return (await fs.readdir(path, { withFileTypes: true }))
    .filter((it) => !it.name.startsWith("."))
    .sort((a, b) => a.name.localeCompare(b.name));
}

async function processFile(
  file: Dirent,
  seenVariables: Set<string>
): Promise<string> {
  if (file.name.startsWith(".")) return "";

  // Note: some file systems may be case-insensitive!
  const varname = file.name.toUpperCase();

  console.debug("Processing " + varname);
  verifyVariable(varname, seenVariables);

  const content = JSON.stringify(
    await fs
      .readFile(path.join(file.parentPath, file.name), {
        encoding: "utf8",
      })
      .then((it) => it.trim())
  );
  return varname + "=" + content + "\n";
}

async function processDirectory(
  dirPath: string,
  dotenvContents = "",
  isRootDir = true,
  seenVariables = new Set<string>()
): Promise<string> {
  // Ignore e.g. .gitignore
  if (path.basename(dirPath).startsWith(".")) return dotenvContents;
  if (!(await fs.exists(dirPath)) || !(await fs.stat(dirPath)).isDirectory()) {
    console.error(
      "Improper environment configuration: the '" +
        dirPath +
        "' directory does not exist"
    );
    process.exit(1);
  }

  console.debug(chalk.bold("== " + dirPath + "/"));

  dotenvContents += (isRootDir ? "" : "\n") + "# " + dirPath + "\n";

  const entries = await readDir(dirPath);
  for (const entry of entries.filter((it) => it.isFile())) {
    dotenvContents += await processFile(entry, seenVariables);
  }
  for (const entry of entries.filter((it) => it.isDirectory())) {
    dotenvContents = await processDirectory(
      path.join(entry.parentPath, entry.name),
      dotenvContents,
      false,
      seenVariables
    );
  }
  return dotenvContents;
}

const dotenvContents = await processDirectory(env.SECRETS_PATH);
await fs.ensureFile(env.DOTENV_PATH);
await fs.truncate(env.DOTENV_PATH);
await fs.writeFile(env.DOTENV_PATH, dotenvContents);

console.log(chalk.green("Generated dotenv file at '" + env.DOTENV_PATH + "'"));

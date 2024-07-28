import { cleanEnv, str } from "envalid";
import express from "express";
import { createServer } from "node:http";

process.on("SIGTERM", () => process.exit());
process.on("SIGINT", () => process.exit());

const env = cleanEnv(process.env, {
  APP_HOST: str(),
});

const app = express();
app.disable("x-powered-by");

app.get("/healthz", (_, res) => res.status(204).end());

const server = createServer(app);
server.on("error", (e) => {
  console.error(e);
});

server.listen(env.APP_HOST.split(":")[1]);

console.log(
  `Server listening at http://${env.APP_HOST === "devcontainer" ? "localhost" : env.APP_HOST}`
);

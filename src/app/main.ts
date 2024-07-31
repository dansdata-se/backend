import { cleanEnv, str } from "envalid";
import express from "express";
import { createServer } from "node:http";

process.on("SIGTERM", () => process.exit());
process.on("SIGINT", () => process.exit());

const env = cleanEnv(process.env, {
  DOCKER_DANCE_API_HOST: str(),
});

const app = express();
app.disable("x-powered-by");

app.get("/healthz", (_, res) => res.status(204).end());

const server = createServer(app);
server.on("error", (e) => {
  console.error(e);
});

server.listen(env.DOCKER_DANCE_API_HOST.split(":")[1]);

console.log(
  `Server listening at http://${env.DOCKER_DANCE_API_HOST === "devcontainer" ? "localhost" : env.DOCKER_DANCE_API_HOST}`
);

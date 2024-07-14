import config from "@/graphile.config";
import { cleanEnv, host, str } from "envalid";
import express, { type ErrorRequestHandler } from "express";
import type { Request as JwtRequest } from "express-jwt";
import { expressjwt, UnauthorizedError } from "express-jwt";
import type { Algorithm } from "jsonwebtoken";
import { createServer } from "node:http";
import postgraphile from "postgraphile";
import { grafserv } from "postgraphile/grafserv/express/v4";

const env = cleanEnv(process.env, {
  APP_HOST: host(),
  JWT_PUBLIC_KEY: str(),
  JWT_SIGN_ALGORITHM: str(),
});

const app = express();
app.use(
  "/graphql",
  // Validate incoming JWTs
  //
  // eslint bug: https://github.com/DefinitelyTyped/DefinitelyTyped/issues/50871
  // eslint-disable-next-line @typescript-eslint/no-misused-promises
  expressjwt({
    algorithms: [env.JWT_SIGN_ALGORITHM as Algorithm],
    issuer: "dansdata",
    audience: "dansdata",
    secret: env.JWT_PUBLIC_KEY,
    credentialsRequired: false,
  }),
  // Return JWT errors in GraphQL-compliant format
  ((error, _: JwtRequest, res, next) => {
    if (error instanceof UnauthorizedError) {
      console.error(error);
      res.status(error.status).json({ errors: [{ message: error.message }] });
      res.end();
    } else next(error);
  }) as ErrorRequestHandler
);

const server = createServer(app);
server.on("error", (e) => {
  console.error(e);
});

postgraphile(config)
  .createServ(grafserv)
  .addTo(app, server)
  .catch((e: unknown) => {
    console.error(e);
    process.exit(1);
  });

server.listen(env.APP_HOST.split(":")[1]);

console.log(
  `Server listening at http://${env.APP_HOST === "devcontainer" ? "localhost" : env.APP_HOST}`
);
console.debug(
  `Ruru listening at http://${env.APP_HOST === "devcontainer" ? "localhost" : env.APP_HOST}${config.grafserv?.graphiqlPath ?? "/"}`
);

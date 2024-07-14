import { buildTraceableErrorMessage } from "@/graphql/error";
import { makePgService } from "@dataplan/pg/adaptors/pg";
import { PgSimplifyInflectionPreset } from "@graphile/simplify-inflection";
import { cleanEnv, host, str } from "envalid";
import type { Request as JwtRequest } from "express-jwt";
import type {} from "postgraphile";
import { defaultMaskError } from "postgraphile/grafserv";
import { GraphQLError } from "postgraphile/graphql";
import { PostGraphileAmberPreset } from "postgraphile/presets/amber";
import { PostGraphileRelayPreset } from "postgraphile/presets/relay";

// https://www.npmjs.com/package/@graphile/depth-limit
// https://the-guild.dev/graphql/envelop/docs/getting-started

const env = cleanEnv(process.env, {
  APP_HOST: host(),
  DB_APP_AUTH_USER: str(),
  DB_APP_AUTH_PASSWORD: str(),
  DB_NAME: str(),
  DB_HOST: host(),
  JWT_PUBLIC_KEY: str(),
  NODE_ENV: str({ choices: ["development", "test", "production", "stage"] }),
  GRAPHILE_ENV: str({
    choices: ["development", "test", "production", "stage"],
  }),
});
const connectionString = `postgres://${encodeURIComponent(env.DB_APP_AUTH_USER)}:${encodeURIComponent(env.DB_APP_AUTH_PASSWORD)}@${env.DB_HOST}/${encodeURIComponent(env.DB_NAME)}`;

let superuserConnectionString: string | undefined = undefined;
if (env.NODE_ENV === "development") {
  const superEnv = cleanEnv(process.env, {
    DBMS_OWNER_USER: str(),
    DBMS_OWNER_PASSWORD: str(),
  });
  superuserConnectionString = `postgres://${encodeURIComponent(superEnv.DBMS_OWNER_USER)}:${encodeURIComponent(superEnv.DBMS_OWNER_PASSWORD)}@${env.DB_HOST}/${encodeURIComponent(env.DB_NAME)}`;
}

const preset: GraphileConfig.Preset = {
  extends: [
    PostGraphileAmberPreset,
    PostGraphileRelayPreset,
    PgSimplifyInflectionPreset,
  ],
  // plugins: [TranslationsPlugin],
  disablePlugins: ["PgPolymorphismOnlyArgumentPlugin"],
  pgServices: [
    makePgService({
      connectionString,
      superuserConnectionString,
      pubsub: true,
      schemas: ["dance_api_public"],
    }),
  ],
  gather: {
    pgStrictFunctions: true,
    installWatchFixtures: env.NODE_ENV === "development",
  },
  ruru: {
    htmlParts: {
      titleTag: "<title>Dansdata GraphQL API</title>",
    },
  },
  schema: {
    defaultBehavior: "-insert -update -delete",
    dontSwallowErrors: true,
    jsonScalarAsString: false,
    pgForbidSetofFunctionsToReturnNull: true,
    pgJwtSecret: env.JWT_PUBLIC_KEY,
  },
  grafserv: {
    host: env.APP_HOST.split(":")[0],
    port: parseInt(env.APP_HOST.split(":")[1]),
    graphiql: true,
    graphqlOverGET: false,
    graphqlPath: "/graphql",
    graphiqlPath: "/graphiql",
    watch: env.NODE_ENV === "development",
    maskError(error) {
      if (error.message.includes("permission denied")) {
        const trace = buildTraceableErrorMessage(error.message, error);
        console.warn(trace.message);
        return new GraphQLError(
          `permission denied (hash: '${trace.hash}', id: '${trace.errorId}')`,
          {
            nodes: error.nodes,
            path: error.path,
            positions: error.positions,
            source: error.source,
          }
        );
      }
      return defaultMaskError(error);
    },
  },
  grafast: {
    explain: env.NODE_ENV === "development",
    context(requestContext, args) {
      const req: JwtRequest<{ uid?: string; role?: string }> | undefined =
        requestContext.expressv4?.req;
      return {
        pgSettings: {
          ...args.contextValue.pgSettings,
          role: req?.auth?.role ?? "anonymous",
          "jwt.claims.uid": req?.auth?.uid ?? "",
          "jwt.claims.role": req?.auth?.role ?? "",
        },
      };
    },
    timeouts: {
      execution: 1500,
      planning: 750,
    },
  },
};

export default preset;

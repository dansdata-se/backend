import { createHash } from "crypto";
import { GraphQLError } from "postgraphile/graphql";
import { format } from "util";

// https://github.com/graphile/crystal/blob/ab3ac2259d00af95be81fdd8916bff5e9340be01/grafast/grafserv/src/options.ts#L9-L24
const RANDOM_STRING_LETTERS = "ABCDEFGHJKLMNPQRTUVWXYZ2346789";
const RANDOM_STRING_LETTERS_LENGTH = RANDOM_STRING_LETTERS.length;

const sha1 = (text: string) =>
  createHash("sha1").update(text).digest("base64url");

const randomString = (length = 10) => {
  let str = "";
  for (let i = 0; i < length; i++) {
    str +=
      RANDOM_STRING_LETTERS[
        Math.floor(Math.random() * RANDOM_STRING_LETTERS_LENGTH)
      ];
  }
  return str;
};

export function buildTraceableErrorMessage(
  message: string,
  error: unknown
): { hash: string; errorId: string; message: string } {
  const hash = sha1(String(error));
  const errorId = randomString();

  if (error instanceof GraphQLError) {
    return {
      hash,
      errorId,
      message: format(
        "%s [GraphQL error] (hash: '%s', id: '%s')\n%s\n%O",
        message,
        hash,
        errorId,
        error,
        error.originalError ?? error
      ),
    };
  }

  return {
    hash,
    errorId,
    message: format(
      "$%s (hash: '%s', id: '%s')\n%O",
      message,
      hash,
      errorId,
      error
    ),
  };
}

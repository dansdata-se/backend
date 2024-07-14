// // @ts-check

// import {
//   PgSelectSingleStep,
//   TYPES,
//   listOfCodec,
// } from "postgraphile/@dataplan/pg";

// declare global {
//   namespace GraphileBuild {
//     interface ScopeObject {
//       isDansdataTranslation?: boolean;
//     }
//   }
// }

// type CodecAndGraphQlType<
//   TGQL extends import("graphql").GraphQLType,
//   TCodec extends import("postgraphile/@dataplan/pg").PgCodec,
// > = (
//   codecKey: string,
//   build: GraphileBuild.Build,
//   situation: string
// ) => {
//   codec: TCodec;
//   graphQlType: TGQL;
// };

// function getCodec(codecKey: string, build: GraphileBuild.Build) {
//   const codec = build.input.pgRegistry.pgCodecs?.[codecKey];
//   if (!codec) {
//     throw new TypeError("Failed to resolve codec");
//   }
//   return codec;
// }

// // eslint-disable-next-line @typescript-eslint/no-explicit-any
// const getCodecAndGraphQlType: CodecAndGraphQlType<any, any> = (codecKey, build, situation) => {
//   const codec = getCodec(codecKey, build);

//   const graphQlType = build.getGraphQLTypeByPgCodec(codec, situation);
//   if (!graphQlType) {
//     throw new TypeError("Failed to resolve GraphQL type from the codec");
//   }

//   return { codec, graphQlType };
// };

// export const TranslationsPlugin: GraphileConfig.Plugin = {
//   name: "TranslationsPlugin",
//   version: "1.0.0",
//   schema: {
//     hooks: {
//       GraphQLObjectType_fields(fields, build, context) {
//         const attributes: unknown = context.scope.pgCodec?.attributes;
//         if (!context.scope.isPgClassType || !attributes) {
//           return fields;
//         }
//         const getTranslations =
//           build.input.pgRegistry.pgResources.translations_get_translations;
//         if (!getTranslations) {
//           throw new TypeError("Failed to resolve resource");
//         }

//         /**
//          * @type {ReturnType<CodecAndGraphQlType<import("graphql").GraphQLInputType, import("postgraphile/@dataplan/pg").PgCodec<string, any, any, any, any>>>}
//          */
//         const { codec: languageCodeCodec, graphQlType: GraphQLLanguageCode } =
//           getCodecAndGraphQlType("translationsLanguageCode", build, "input");
//         /**
//          * @type {ReturnType<CodecAndGraphQlType<import("graphql").GraphQLOutputType, import("postgraphile/@dataplan/pg").PgCodec<string, any, any, any, any>>>}
//          */
//         const { graphQlType: GraphQLTranslationType } = getCodecAndGraphQlType(
//           "Translation",
//           build,
//           "output"
//         );

//         for (const attributeName in attributes) {
//           /**
//            * @type {DataplanPg.PgCodecAttributeExtensions["tags"][string]}
//            */
//           const fieldName =
//             attributes[attributeName].extensions?.tags?.translation;
//           if (!fieldName) continue;
//           if (typeof fieldName !== "string") {
//             throw new TypeError(
//               `@translation must specify the field name to use (expected: ${typeof ""}, was: ${typeof fieldName})`
//             );
//           }

//           build.extend(
//             fields,
//             {
//               [fieldName]: context.fieldWithHooks(
//                 { fieldName, isDansdataTranslation: true },
//                 {
//                   type: new build.graphql.GraphQLNonNull(
//                     new build.graphql.GraphQLList(
//                       new build.graphql.GraphQLNonNull(GraphQLTranslationType)
//                     )
//                   ),
//                   args: {
//                     languages: {
//                       type: new build.graphql.GraphQLNonNull(
//                         new build.graphql.GraphQLList(
//                           new build.graphql.GraphQLNonNull(GraphQLLanguageCode)
//                         )
//                       ),
//                     },
//                   },
//                   /**
//                    * @param {PgSelectSingleStep} $parentPlan
//                    */
//                   plan($parentPlan, { $languages }) {
//                     const $translationId = $parentPlan.get(attributeName);
//                     const $translations = getTranslations.execute([
//                       { step: $translationId, pgCodec: TYPES.int },
//                       {
//                         step: $languages,
//                         pgCodec: listOfCodec(languageCodeCodec),
//                       },
//                     ]);
//                     return $translations;
//                   },
//                 }
//               ),
//             },
//             `Adding translation field ${fieldName} for column ${attributeName} on ${context.Self.name}`
//           );
//         }
//         return fields;
//       },
//     },
//   },
// };

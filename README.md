# Dansdata Backend

![Git Hooks: Husky](https://img.shields.io/badge/husky-blue?logo=git&label=Git%20Hooks&link=https%3A%2F%2Ftypicode.github.io%2Fhusky%2F)
![Code formatting: Prettier](https://img.shields.io/badge/prettier-blue?logo=prettier&label=Formatting&link=https%3A%2F%2Fprettier.io%2F)
![Commit Style: Conventional Commits](https://img.shields.io/badge/conventional-blue?logo=conventionalcommits&label=Commit%20Style&link=https%3A%2F%2Fwww.conventionalcommits.org%2Fen%2Fv1.0.0%2F)
![Commit Verification: Commitlint](https://img.shields.io/badge/commitlint-blue?logo=commitlint&label=Commit%20Verification&link=https%3A%2F%2Fcommitlint.js.org%2F)

Dansdata (lit. "dance data") is an open API for information relating to social dancing in Sweden.

Learn more at <https://dansdata.se>!

## Background

Social dancing is a popular activity in Sweden with multiple events per day, nearly every day of the year. Unfortunately, it can be quite hard for dancers to find these events as they are primarily advertised locally or on Facebook. There also are no good data sources for developers to build on, making it hard for organizers to reach out.

With Dansdata, we want to create a data repository for information about social dancing in Sweden: events, bands, photographers and more! We believe that the dancing community is full of people willing to develop dance related services, if only they had a platform to stand on.

By creating this platform and enabling developers, we hope to make social dancing more accessible in the digital era.

## Getting Started

_The project makes use of VSCode's [devcontainer feature](https://code.visualstudio.com/docs/devcontainers/containers) to create a basic, common development environment. The following instructions assume you are using this environment. If you do not want to use a devcontainer, necessary steps to configure your local environment can be deduced from files in the [`.devcontainer`](./.devcontainer) directory._

## Contributing

Dansdata is a project by dancers, for dancers. Contributions are welcome!

For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

### Tooling

The project is running on [bun](https://bun.sh/) and [postgraphile](https://postgraphile.org/) with a [PostgreSQL](https://www.postgresql.org/) database.

We use [just](https://just.systems/). Custom tooling is run via just and located in [`./tooling`](./.tooling).

Commits are checked with [commitlint](https://commitlint.js.org/).

Formatting via [prettier](https://prettier.io/)

Database migrations managed via [graphile-migrate](https://github.com/graphile/migrate).

Deployment via [docker compose](https://docs.docker.com/compose/).

## License

[MIT](https://choosealicense.com/licenses/mit/)

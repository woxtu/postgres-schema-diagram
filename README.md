# postgres-schema-diagram

![An example schema diagram](https://github.com/woxtu/postgres-schema-diagram/assets/5673994/7ecb7fa5-ad2f-4f03-9440-ac7c3dece2ee)

A PostgreSQL port of [SQLite Schema Diagram Generator](https://gitlab.com/Screwtapello/sqlite-schema-diagram) that generates a diagram of the database schema in [Graphviz](https://graphviz.org) format.

```console
$ psql -At -f postgres-schema-diagram.sql > schema.dot
$ dot -Tsvg schema.dot > schema.svg
```

## License

Licensed under the MIT license.

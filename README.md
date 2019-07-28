# POC Postgraphile - forum example

Roadmap:

- [x] Based on https://github.com/graphile/postgraphile/tree/master/examples/forum
- [x] Enable [graphql-voyager](https://github.com/APIs-guru/graphql-voyager)
- [ ] Write sample queries
  - [ ] Query
  - [ ] Mutations
  - [ ] [Row Security Policies](https://www.postgresql.org/docs/9.6/ddl-rowsecurity.html)

```
$ ./scripts/start-pg-and-wait-starting.sh
$ ./scripts/seed.sh
$ ./scripts/fixtures.sh
```


```
$ docker-compose up -d
```

Urls:

- http://0.0.0.0:5000/graphql
- http://0.0.0.0:5000/graphiql
- graphql-voyager: http://127.0.0.1:3001/

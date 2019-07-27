# POC Postgraphile - forum example

Roadmap:

- [ ] Based on https://github.com/graphile/postgraphile/tree/master/examples/forum
- [x] Enable [graphql-voyager](https://github.com/APIs-guru/graphql-voyager)
- [ ] Write sample queries
  - [ ] Query
  - [ ] Mutations
  - [ ] [Row Security Policies](https://www.postgresql.org/docs/9.6/ddl-rowsecurity.html)

```
$ docker-compose up -d postgres
```

```
$ cat sql/schema.sql | docker-compose exec -T postgres psql -U admin poc-forum
$ cat sql/demo-data.sql | docker-compose exec -T postgres psql -U admin poc-forum
```

```
$ docker-compose up -d
```

Urls:

- http://0.0.0.0:5000/graphql
- http://0.0.0.0:5000/graphiql
- graphql-voyager: http://127.0.0.1:3001/

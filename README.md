# POC Postgraphile - forum example

Roadmap:

- [x] Based on https://github.com/graphile/postgraphile/tree/master/examples/forum
- [x] Enable [graphql-voyager](https://github.com/APIs-guru/graphql-voyager)
- [x] Write sample queries
  - [x] Query
  - [x] Mutations
  - [x] [Row Security Policies](https://www.postgresql.org/docs/9.6/ddl-rowsecurity.html)
- [ ] Email worker
- [ ] YouTube screencast
- [ ] Small React app example
- [ ] Add [Full Text Search](https://www.postgresql.org/docs/11/textsearch.html) on `post.body`, `post.headline` fields

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

## Query

```
{
  posts {
    nodes {
      id
      headline
      body
      summary
      authorId
    }
  }
}
```

## Authenticate

```
mutation {
  authenticate(input: {email: "username001@example.com", password: "password"}) {
    clientMutationId
    jwtToken
  }
}
```

Result:

```
{
  "data": {
    "authenticate": {
      "clientMutationId": null,
      "jwtToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiZm9ydW1fZXhhbXBsZV9wZXJzb24iLCJwZXJzb25faWQiOiIxZGU5Yzk4Ny0wOGFiLTMyZmUtZTIxOC04OWMxMjRjZDAwMDEiLCJpYXQiOjE1NjQzMTk3ODgsImV4cCI6MTU2NDQwNjE4OCwiYXVkIjoicG9zdGdyYXBoaWxlIiwiaXNzIjoicG9zdGdyYXBoaWxlIn0.SxpP_2s8sG1-3Qc8aV9N1-A99oBPoqv1W_8BfKoYBtY"
    }
  }
}
```

## Use JWT Token in header

```
{
"Authorization": "bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiZm9ydW1fZXhhbXBsZV9wZXJzb24iLCJwZXJzb25faWQiOiIxZGU5Yzk4Ny0wOGFiLTMyZmUtZTIxOC04OWMxMjRjZDAwMDEiLCJpYXQiOjE1NjQzMTk3ODgsImV4cCI6MTU2NDQwNjE4OCwiYXVkIjoicG9zdGdyYXBoaWxlIiwiaXNzIjoicG9zdGdyYXBoaWxlIn0.SxpP_2s8sG1-3Qc8aV9N1-A99oBPoqv1W_8BfKoYBtY"
}
```

## Create a post

```
mutation {
  createPost(input: {post: {headline: "headline 1", authorId: "1de9c987-08ab-32fe-e218-89c124cd0001", body: "body1", topic: DISCUSSION}}) {
    clientMutationId
    post {
      id
      author {
        firstName
        id
      }
    }
  }
}
```

Result:

```
{
  "data": {
    "createPost": {
      "clientMutationId": null,
      "post": {
        "id": "b6799d54-ac68-4170-9b62-3536921bb164",
        "author": {
          "firstName": "first_name001",
          "id": "1de9c987-08ab-32fe-e218-89c124cd0001"
        }
      }
    }
  }
}
```

FROM graphile/postgraphile:v4.4.1
# FROM postgraphile:latest

RUN yarn add \
    @graphile/subscriptions-lds@4.x \
    @graphile/pg-pubsub@4.x \
    @graphile-contrib/pg-simplify-inflector@3.0.0 \
    postgraphile-plugin-connection-filter@1.x \
    @graphile-contrib/pg-order-by-related \
    @graphile-contrib/pg-many-to-many
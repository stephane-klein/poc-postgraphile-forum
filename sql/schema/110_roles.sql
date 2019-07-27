\echo "Roles creating..."
SET client_min_messages TO WARNING;

CREATE ROLE forum_example_postgraphile LOGIN PASSWORD 'password';

CREATE ROLE forum_example_anonymous LOGIN;
GRANT forum_example_anonymous TO forum_example_postgraphile;

CREATE ROLE forum_example_person;
GRANT forum_example_person TO forum_example_postgraphile;

GRANT USAGE ON SCHEMA forum_example TO forum_example_anonymous;
GRANT USAGE ON SCHEMA forum_example_private TO forum_example_anonymous;

\echo "Roles created"

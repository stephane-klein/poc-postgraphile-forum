\echo "Cleaning tables..."

SET client_min_messages TO WARNING;

TRUNCATE 
    forum_example.person,
    forum_example_private.person_account,
    forum_example.post;

\echo "Tables cleaned"

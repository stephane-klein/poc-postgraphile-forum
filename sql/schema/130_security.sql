\echo "Security creating..."
SET client_min_messages TO WARNING;

CREATE TYPE forum_example_private.jwt_token AS (
  role      TEXT,
  person_id INTEGER
);

create function forum_example.authenticate(
  email text,
  password text
) returns forum_example_private.jwt_token as $$
BEGIN
  RETURN (
    SELECT 
      ('forum_example_person', person_id)::forum_example_private.jwt_token
    FROM
      forum_example_private.person_account
    WHERE 
      person_account.email = $1 AND
      person_account.password_hash = crypt($2, person_account.password_hash)
  );
END;
$$ language plpgsql strict security definer;

comment on function forum_example.authenticate(text, text) is 'Creates a JWT token that will securely identify a person and give them certain permissions.';

alter default privileges revoke execute on functions from public;

grant usage on schema forum_example to forum_example_anonymous, forum_example_person;

grant select on table forum_example.person to forum_example_anonymous, forum_example_person;
grant update, delete on table forum_example.person to forum_example_person;

grant select on table forum_example.post to forum_example_anonymous, forum_example_person;
grant insert, update, delete on table forum_example.post to forum_example_person;
grant usage on sequence forum_example.post_id_seq to forum_example_person;

grant execute on 
    function forum_example.person_full_name(forum_example.person) 
    to forum_example_anonymous, forum_example_person;

grant execute on
    function forum_example.post_summary(forum_example.post, integer, text) 
    to forum_example_anonymous, forum_example_person;

grant execute on 
    function forum_example.person_latest_post(forum_example.person) 
    to forum_example_anonymous, forum_example_person;

grant execute on 
    function forum_example.search_posts(text)
    to forum_example_anonymous, forum_example_person;

grant execute on
    function forum_example.authenticate(text, text) 
    to forum_example_anonymous, forum_example_person;

grant execute on
    function forum_example.current_person() 
    to forum_example_anonymous, forum_example_person;

grant execute on
    function forum_example.change_password(text, text) 
    to forum_example_person;

grant execute on 
    function forum_example.register_person(text, text, text, text) 
    to forum_example_anonymous;

alter table forum_example.person enable row level security;
alter table forum_example.post enable row level security;

create policy select_person 
    on forum_example.person
    for select
    using (true);

create policy select_post 
    on forum_example.post 
    for select
    using (true);

create policy update_person 
    on forum_example.person 
    for update to forum_example_person
    using (id = current_setting('jwt.claims.person_id', true)::integer);

create policy delete_person 
    on forum_example.person
    for delete to forum_example_person
    using (id = current_setting('jwt.claims.person_id', true)::integer);

create policy insert_post
    on forum_example.post
    for insert to forum_example_person
    with check (author_id = current_setting('jwt.claims.person_id', true)::integer);

create policy update_post
    on forum_example.post
    for update to forum_example_person
    using (author_id = current_setting('jwt.claims.person_id', true)::integer);

create policy delete_post on forum_example.post for delete to forum_example_person
  using (author_id = current_setting('jwt.claims.person_id', true)::integer);

\echo "Security created"

\echo "Security creating..."

SET client_min_messages TO WARNING;

CREATE TYPE forum_example_private.jwt_token AS (
  role      TEXT,
  person_id UUID
);

CREATE FUNCTION forum_example.authenticate(
  email TEXT,
  password TEXT
) RETURNS forum_example_private.jwt_token AS $$
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
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION forum_example.authenticate(TEXT, TEXT) IS 'Creates a JWT token that will securely identify a person and give them certain permissions.';

ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM public;

GRANT USAGE ON SCHEMA forum_example TO forum_example_anonymous, forum_example_person;

GRANT SELECT ON TABLE forum_example.person TO forum_example_anonymous, forum_example_person;
GRANT UPDATE, DELETE ON TABLE forum_example.person TO forum_example_person;

GRANT SELECT ON TABLE forum_example.post TO forum_example_anonymous, forum_example_person;
GRANT INSERT, UPDATE, DELETE ON TABLE forum_example.post TO forum_example_person;

GRANT EXECUTE ON 
    FUNCTION forum_example.person_full_name(forum_example.person) 
    TO forum_example_anonymous, forum_example_person;

GRANT EXECUTE ON
    FUNCTION forum_example.post_summary(forum_example.post, INTEGER, TEXT) 
    TO forum_example_anonymous, forum_example_person;

GRANT EXECUTE ON
    FUNCTION forum_example.person_latest_post(forum_example.person) 
    TO forum_example_anonymous, forum_example_person;

GRANT EXECUTE ON
    FUNCTION forum_example.search_posts(TEXT)
    TO forum_example_anonymous, forum_example_person;

GRANT EXECUTE ON
    FUNCTION forum_example.authenticate(TEXT, TEXT) 
    TO forum_example_anonymous, forum_example_person;

GRANT EXECUTE ON
    FUNCTION forum_example.current_person() 
    TO forum_example_anonymous, forum_example_person;

GRANT EXECUTE ON
    FUNCTION forum_example.change_password(TEXT, TEXT) 
    TO forum_example_person;

GRANT EXECUTE ON 
    FUNCTION forum_example.register_person(TEXT, TEXT, TEXT, TEXT) 
    TO forum_example_anonymous;

ALTER TABLE forum_example.person ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_example.post ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_person 
    ON forum_example.person
    FOR SELECT
    USING (true);

CREATE POLICY select_post 
    ON forum_example.post 
    FOR SELECT
    USING (true);

CREATE POLICY update_person 
    ON forum_example.person 
    FOR UPDATE TO forum_example_person
    USING (id = current_setting('jwt.claims.person_id', true)::UUID);

CREATE POLICY delete_person 
    ON forum_example.person
    FOR DELETE TO forum_example_person
    USING (id = current_setting('jwt.claims.person_id', true)::UUID);

CREATE POLICY insert_post
    ON forum_example.post
    FOR INSERT TO forum_example_person
    WITH CHECK (author_id = current_setting('jwt.claims.person_id', true)::UUID);

CREATE POLICY update_post
    ON forum_example.post
    FOR UPDATE TO forum_example_person
    USING (author_id = current_setting('jwt.claims.person_id', true)::UUID);

CREATE POLICY delete_post
    ON forum_example.post
    FOR DELETE TO forum_example_person
    USING (author_id = current_setting('jwt.claims.person_id', true)::UUID);

\echo "Security created"

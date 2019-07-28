\echo "Schema creating..."

SET client_min_messages TO WARNING;

CREATE TABLE forum_example.person (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
  first_name       TEXT NOT NULL CHECK (CHAR_LENGTH(first_name) < 80),
  last_name        TEXT CHECK (CHAR_LENGTH(last_name) < 80),
  about            TEXT,
  created_at       TIMESTAMP DEFAULT NOW()
);


COMMENT ON TABLE forum_example.person IS E'@omit create\nA user of the forum.';
COMMENT ON COLUMN forum_example.person.id IS 'The primary unique identifier for the person.';
COMMENT ON COLUMN forum_example.person.first_name IS 'The person’s first name.';
COMMENT ON COLUMN forum_example.person.last_name IS 'The person’s last name.';
COMMENT ON COLUMN forum_example.person.about IS 'A short description about the user, written by the user.';
COMMENT ON COLUMN forum_example.person.created_at IS 'The time this person was created.';

CREATE TYPE forum_example.post_topic AS ENUM (
  'discussion',
  'inspiration',
  'help',
  'showcase'
);

CREATE TABLE forum_example.post (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
  author_id        UUID NOT NULL REFERENCES forum_example.person(id) DEFAULT current_setting('jwt.claims.person_id', true)::UUID,
  headline         TEXT NOT NULL CHECK (CHAR_LENGTH(headline) < 280),
  body             TEXT,
  topic            forum_example.post_topic,
  created_at       TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE forum_example.post IS 'A forum post written by a user.';
COMMENT ON COLUMN forum_example.post.id IS 'The primary key for the post.';
COMMENT ON COLUMN forum_example.post.headline IS 'The title written by the user.';
COMMENT ON COLUMN forum_example.post.author_id IS 'The id of the author user.';
COMMENT ON COLUMN forum_example.post.topic IS 'The topic this has been posted in.';
COMMENT ON COLUMN forum_example.post.body IS 'The main body text of our post.';
COMMENT ON COLUMN forum_example.post.created_at IS 'The time this post was created.';

CREATE FUNCTION forum_example.person_full_name(person forum_example.person) RETURNS TEXT AS $$
  SELECT person.first_name || ' ' || person.last_name
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION forum_example.person_full_name(forum_example.person) IS 'A person’s full name which is a concatenation of their first and last name.';

CREATE FUNCTION forum_example.post_summary(
  post forum_example.post,
  length INT DEFAULT 50,
  omission TEXT DEFAULT '…'
) RETURNS TEXT AS $$
  SELECT CASE
    WHEN post.body IS NULL THEN NULL
    ELSE substr(post.body, 0, length) || omission
  END
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION forum_example.post_summary(forum_example.post, INT, TEXT) IS 'A truncated version of the body for summaries.';

CREATE FUNCTION forum_example.person_latest_post(person forum_example.person) RETURNS forum_example.post AS $$
  SELECT
    post.*
  FROM
    forum_example.post AS post
  WHERE
    post.author_id = person.id
  ORDER BY
    created_at DESC
  LIMIT 1
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION forum_example.person_latest_post(forum_example.person) IS 'Gets the latest post written by the person.';

CREATE FUNCTION forum_example.search_posts(search text) RETURNS SETOF forum_example.post AS $$
  SELECT
    post.*
  FROM
    forum_example.post AS post
  WHERE
    post.headline ILIKE ('%' || search || '%') OR
    post.body ILIKE ('%' || search || '%')
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION forum_example.search_posts(text) IS 'Returns posts containing a given search term.';

ALTER TABLE forum_example.person add column updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE forum_example.post add column updated_at TIMESTAMP DEFAULT NOW();

CREATE FUNCTION forum_example_private.set_updated_at() RETURNS TRIGGER AS $$
BEGIN
  new.updated_at := current_timestamp;
  RETURN new;
END;
$$ LANGUAGE PLPGSQL;

CREATE trigger person_updated_at BEFORE UPDATE
  ON forum_example.person
  FOR EACH ROW
  EXECUTE PROCEDURE forum_example_private.set_updated_at();

CREATE trigger post_updated_at BEFORE UPDATE
  ON forum_example.post
  FOR EACH ROW
  EXECUTE PROCEDURE forum_example_private.set_updated_at();

CREATE TABLE forum_example_private.person_account (
  person_id        UUID PRIMARY KEY REFERENCES forum_example.person(id) ON DELETE CASCADE,
  email            TEXT NOT NULL UNIQUE CHECK (email ~* '^.+@.+\..+$'),
  password_hash    TEXT NOT NULL
);

COMMENT ON TABLE forum_example_private.person_account IS 'Private information about a person’s account.';
COMMENT ON COLUMN forum_example_private.person_account.person_id IS 'The id of the person associated with this account.';
COMMENT ON COLUMN forum_example_private.person_account.email IS 'The email address of the person.';
COMMENT ON COLUMN forum_example_private.person_account.password_hash IS 'An opaque hash of the person’s password.';

CREATE FUNCTION forum_example.register_person(
  first_name TEXT,
  last_name TEXT,
  email TEXT,
  password TEXT
) RETURNS forum_example.person AS $$
DECLARE
  person forum_example.person;
BEGIN
  INSERT INTO
    forum_example.person
  (
    first_name,
    last_name
  )
  VALUES
    (
      first_name,
      last_name
    )
  RETURNING * INTO person;

  INSERT INTO
    forum_example_private.person_account
  (
    person_id,
    email,
    password_hash
  )
  VALUES (
    person.id,
    email,
    crypt(password, gen_salt('bf'))
  );

  RETURN person;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION forum_example.register_person(TEXT, TEXT, TEXT, TEXT) IS 'Registers a single user and creates an account in our forum.';


CREATE FUNCTION forum_example.current_person() RETURNS forum_example.person AS $$
  SELECT
    *
  FROM
    forum_example.person
  WHERE
    id = current_setting('jwt.claims.person_id', true)::UUID
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION forum_example.current_person() IS 'Gets the person who was identified by our JWT.';

CREATE FUNCTION forum_example.change_password(current_password TEXT, new_password TEXT) 
RETURNS BOOLEAN AS $$
DECLARE
  current_person forum_example.person;
BEGIN
  current_person := forum_example.current_person();
  IF EXISTS (SELECT 1 FROM forum_example_private.person_account WHERE person_account.person_id = current_person.id AND person_account.password_hash = crypt($1, person_account.password_hash)) 
  THEN
    UPDATE forum_example_private.person_account SET password_hash = crypt($2, gen_salt('bf')) WHERE person_account.person_id = current_person.id; 
    RETURN true;
  ELSE 
    RETURN false;
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

\echo "Schema created"

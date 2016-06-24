BEGIN;
CREATE SEQUENCE user_id_seq;
CREATE TABLE users (
  id INT NOT NULL DEFAULT nextval('user_id_seq'),
  username VARCHAR NOT NULL,
  email VARCHAR NOT NULL,
  password VARCHAR NOT NULL,
  salt INT NOT NULL
);
ALTER SEQUENCE user_id_seq OWNED BY users.id;

CREATE UNIQUE INDEX user_id_idx ON users (id);
CREATE UNIQUE INDEX user_username_idx ON users (username);
CREATE INDEX user_email_idx ON users (email);
COMMIT;

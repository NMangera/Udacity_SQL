
-- a. Allow new users to register
CREATE TABLE "users" (
    id SERIAL PRIMARY KEY,
    username VARCHAR(25) NOT NULL,
    last_login TIMESTAMP,
    CONSTRAINT "unique_username" UNIQUE ("username"),
    CONSTRAINT "non_empty_username" CHECK (LENGTH(TRIM("username")) > 0)
);

-- b. Allow registered users to create new topics
CREATE TABLE "topics" (
    id SERIAL PRIMARY KEY,
    name  VARCHAR(30) NOT NULL,
    description VARCHAR(500),
    CONSTRAINT "unique_topics" UNIQUE ("name"),
    CONSTRAINT "non_empty_topic_name" CHECK (LENGTH(TRIM("name")) > 0)
);

-- c. Allow registered users to create new posts on existing topics
CREATE TABLE "posts" (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    created_on TIMESTAMP,
    url VARCHAR(400),
    text_content TEXT,
    topic_id INTEGER REFERENCES "topics" ON DELETE CASCADE,
    user_id INTEGER REFERENCES "users" ON DELETE SET NULL,
    CONSTRAINT "non_empty_title" CHECK (LENGTH(TRIM("title")) > 0),
    CONSTRAINT "url_or_text" CHECK (
        LENGTH(TRIM("url")) > 0 AND LENGTH(TRIM("text_content")) IS NULL OR
        LENGTH(TRIM("url")) IS NULL AND LENGTH(TRIM("text_content")) > 0
        )
);
CREATE INDEX ON “posts” (“url” VARCHAR_PATTERN_OPS);

-- d. Allow registered users to comment on existing posts
CREATE TABLE "comments" (
     id SERIAL PRIMARY KEY,
     text_content TEXT NOT NULL,
     created_on TIMESTAMP,
     post_id INTEGER REFERENCES "posts" ON DELETE CASCADE,
     user_id INTEGER REFERENCES "users" ON DELETE SET NULL,
     parent_comment_id INTEGER REFERENCES "comments" ON DELETE CASCADE,
     CONSTRAINT "non_empty_text_content" CHECK (LENGTH(TRIM("text_content")) > 0)
);

-- e. Make sure each user can only vote once for each post
CREATE TABLE "votes" (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES "users" ON DELETE SET NULL,
    post_id INTEGER,
    vote SMALLINT NOT NULL,
    CONSTRAINT "vote_plus_or_minus" CHECK("vote" = 1 OR "vote" = -1),
    CONSTRAINT "one_vote_per_user" UNIQUE (user_id, post_id)
);
CREATE INDEX ON “post_vote” ON “votes” (“post_id”);

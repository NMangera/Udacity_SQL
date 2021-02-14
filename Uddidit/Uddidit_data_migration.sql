INSERT INTO "users" ("username")
    SELECT DISTINCT username
    FROM bad_posts
    UNION
    SELECT DISTINCT username
    FROM bad_comments
    UNION
    SELECT DISTINCT regexp_split_to_table(upvotes, ',')
    FROM bad_posts
    UNION
    SELECT DISTINCT regexp_split_to_table(downvotes, ',')
    FROM bad_posts;

INSERT INTO "topics" ("name")
    SELECT DISTINCT topic
    FROM bad_posts;

INSERT INTO "posts" (
    "user_id",
    "topic_id",
    "title",
    "url",
    "text_content"
)
SELECT
    users.id,
    topics.id,
    LEFT(bad_posts.title, 100),
    bad_posts.url,
    bad_posts.text_content,
FROM bad_posts
JOIN users
    ON bad_posts.username = users.username
JOIN topics
    ON bad_posts.topic = topics.name;

INSERT INTO "comments" (
    "post_id",
    "user_id",
    "text_content"
)
SELECT
    posts.id,
    users.id,
    bad_comments.text_content
FROM bad_comments
JOIN users
    ON bad_comments.username = users.username
JOIN posts
    ON posts.id = bad_comments.post_id;

-- https://knowledge.udacity.com/questions/293663
INSERT INTO "votes" (
    "post_id",
    "user_id",
    "vote"
)
SELECT
    t1.id,
    users.id,
    1 AS vote_up
FROM (SELECT id, REGEXP_SPLIT_TO_TABLE(upvotes, ',')
      AS upvote_users FROM bad_posts) t1
JOIN users
    ON users.username = t1.upvote_users;

INSERT INTO "votes" (
    "post_id",
    "user_id",
    "vote"
)
SELECT
    t1.id,
    users.id,
    -1 AS vote_down
FROM (SELECT id, REGEXP_SPLIT_TO_TABLE(downvotes, ',')
      AS downvote_users FROM bad_posts) t1
JOIN users
    ON users.username = t1.downvote_users;

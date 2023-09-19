-- Connecting to the Email Data Source

CREATE DATABASE email_datasource
WITH ENGINE = 'email',
PARAMETERS = {
  "email": "techwithtim@viralnationtalent.com",
  "password": "fjuuxevtsgklqjvw"
};

-- Querying Our Emails

SELECT *
FROM email_datasource.emails;

-- Querying Our Emails

SELECT id, to, subject, body
FROM email_datasource.emails
WHERE subject = 'MindsDB'
ORDER BY id
LIMIT 5;

-- Creating/Sending Emails
   
INSERT INTO email_datasource.emails(to, subject, body)
VALUES ("toemail@email.com", "MindsDB", "Hello from MindsDB!");

-- Creating the Model

CREATE MODEL mindsdb.sponsorship_reply
PREDICT response
USING
engine = 'openai',
max_tokens = 300,
api_key = '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',
model_name = 'gpt-3.5-turbo',
prompt_template = 'First determine if the following email is related to sponsorships. If it is reply the following email in a personalized, polite and professional manner, make sure to include my sponsorship rates and explain what each one is. An insert (maximum 60 second integration into a video) costs $10 and dedicated youtube video costs $50. If it not related to sponsorships return the exact string of “no reply”. Here is the email: {{body}}'

-- Testing the Model

SELECT
 body, response
FROM mindsdb.sponsorship_reply
WHERE body = 'Hi there team! We were wondering if you could share some sponsorship rates.'

-- Combining Emails with Model

SELECT *
FROM (
    SELECT
        e.body as body,
        r.response as reply,
        e.subject
    FROM email_datasource.emails as e
    JOIN mindsdb.sponsorship_reply as r
    WHERE e.subject = 'Collaboration with ConfigCat'
    ORDER BY e.id
)
LIMIT 10;

-- Job Syntax

CREATE JOB mindsdb.email_reply AS (
   INSERT INTO email_datasource.emails(to, subject, body)
   SELECT
     e.to,
      e.subject,
      s.response as body
   FROM email_datasource.emails e
   JOIN mindsdb.sponsorship_reply s
      WHERE
         e.subject = 'Collaboration with Unacadamy'
   LIMIT 10
)
EVERY day;

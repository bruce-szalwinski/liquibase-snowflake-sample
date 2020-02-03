# liquibase-snowflake-sample <!-- omit in toc -->

- [Dependencies](#dependencies)
- [Setup](#setup)
- [Creating changes](#creating-changes)
- [Applying changes](#applying-changes)
- [Resolving common issues](#resolving-common-issues)
    - [Session does not have a current database](#session-does-not-have-a-current-database)
        - [Issue](#issue)
        - [Resolution](#resolution)
    - [No active warehouse](#no-active-warehouse)
        - [Issue](#issue-1)
        - [Resolution](#resolution-1)


# Dependencies

This project has a parent pom, [liquibase-snowflake-db-build](https://github.com/bruce-szalwinski/liquibase-snowflake-db-build), that manages the common dependencies.  Install that before continuing.

# Setup

Create a file called `db.properties` containing the contents below.  Store this file on your file system.

```bash
# update with your account information
snowflake.account=12345
db.username=my_user
db.password=my_password
db.database=my_database
db.warehouse=my_warehouse
db.schema=my_schema

db.host=${snowflake.account}.snowflakecomputing.com
db.url=jdbc:snowflake://${db.host}/?db=${db.database}&warehouse=${db.warehouse}&schema=${db.schema}
db.driver=net.snowflake.client.jdbc.SnowflakeDriver

liquibase.verbose: true
liquibase.dropFirst: false
liquibase.logging: debug
liquibase.driver: ${db.driver}
liquibase.url: ${db.url}
liquibase.username: ${db.username}
liquibase.password: ${db.password}
liquibase.defaultCatalogName: ${db.database}
liquibase.defaultSchemaName: ${db.username}
liquibase.contexts:
```

Define an environment variable `DB_PROPERTIES` that points at the location of this file.

```bash
export DB_PROPERTIES=$HOME/db.properties
```

# Creating changes

The [master.xml](src/main/resources/master.xml) is the top level [databasechangelog](https://www.liquibase.org/documentation/databasechangelog.html) for the project.  It contains a list of changelogs, organized by year.  Each of the yearly changelogs contains a list of changes for that year.  To add a change, create a file in the yearly directory and update the `changelog.xml` in that directory to include the newly created file.  See [changelog](src/main/resources/changesets/2020/changelog.xml) as an example.

This project currently just uses `plain SQL` [changelog files](https://www.liquibase.org/documentation/sql_format.html).  Each changelog file contains one or more `changeset` entries, with each entry having an `author:id` tag.  See [BPS-1.sql](src/main/resources/changesets/2020/BPS-1.sql) for an example.


# Applying changes

With the changes in place, apply them with:

```bash
mvn install
```

# Resolving common issues
## Session does not have a current database

### Issue
```bash
[ERROR] Failed to execute goal org.liquibase:liquibase-maven-plugin:3.8.5:update (default) on project sample-app: Error setting up or running Liquibase: liquibase.exception.DatabaseException: Cannot perform CREATE TABLE. This session does not have a current database. Call 'USE DATABASE', or use a qualified name. [Failed SQL: CREATE TABLE MY_SCHEMA.DATABASECHANGELOGLOCK (ID INT NOT NULL, LOCKED BOOLEAN NOT NULL, LOCKGRANTED TIMESTAMP_NTZ, LOCKEDBY VARCHAR(255), CONSTRAINT PK_DATABASECHANGELOGLOCK PRIMARY KEY (ID))] -> [Help 1]
[ERROR]
```

### Resolution
Ensure that the user has a default role.
```sql
alter user my_user set default_role = my_default_role
```

## No active warehouse

### Issue
```bash
[ERROR] Failed to execute goal org.liquibase:liquibase-maven-plugin:3.8.5:update (default) on project sample-app: Error setting up or running Liquibase: liquibase.exception.DatabaseException: No active warehouse selected in the current session.  Select an active warehouse with the 'use warehouse' command.
[ERROR]  [Failed SQL: DELETE FROM MY_SCHEMA.DATABASECHANGELOGLOCK]
[ERROR] -> [Help 1]
```

### Resolution

In the db.properties file, set `defaultSchema` equal to `db.username`.

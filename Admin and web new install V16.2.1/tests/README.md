# Running the test suite

This app's migrations assume the base schema already exists (see the root
`CLAUDE.md`: *"Never run `php artisan migrate` on an empty database. Import
`installation/backup/database.sql` first, then migrate."*) — several
migrations alter tables that no earlier migration ever creates. Because of
that, tests run against a real, pre-seeded MySQL database rather than an
ephemeral SQLite `:memory:` database rebuilt from migrations on every run.

## One-time setup

```sh
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS 6valley_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
mysql -uroot 6valley_test < installation/backup/database.sql
DB_DATABASE=6valley_test php artisan migrate --force
```

(`phpunit.xml` already points the `testing` environment at `6valley_test` on
`127.0.0.1:3306`, user `root`, no password — matching this project's own
`.env` default credentials. Adjust both if your local MySQL differs.)

Re-run the `migrate --force` step above whenever new migrations land, same
as you would for the main dev database.

## Writing tests

Use `Illuminate\Foundation\Testing\DatabaseTransactions`, **not**
`RefreshDatabase`, in any test that touches the database. `RefreshDatabase`
runs `migrate:fresh` against an empty schema — which fails for the same
reason described above. `DatabaseTransactions` wraps each test in a
transaction and rolls it back afterward, leaving the imported schema and any
seed data untouched between tests.

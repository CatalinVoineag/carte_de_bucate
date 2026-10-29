# Carte de bucate

A recipe ("receipe") app. Browse, create, edit and delete receipes in the **Receipes** tab. Save any published receipe to **My receipes** to keep your own list. Creating a receipe takes three steps (details and image, ingredients, instructions). When you publish it, it is also added to your My receipes.

## Requirements

- Ruby (see `.ruby-version`)
- Node.js and Yarn (for the CSS and JavaScript build)
- PostgreSQL
- libvips (used by Active Storage for images)

## Setup

```sh
bin/setup
```

This installs the gems and JavaScript packages, prepares the database and loads dummy data (two users, ingredients, public receipes and some of your own). Run it with `--skip-server` to skip starting the server.

## Running

```sh
bin/dev
```

Then open http://localhost:3000.

## Dummy data

```sh
bin/rails dev:seed     # add dummy data; safe to run again, existing records are kept
bin/rails dev:reseed   # delete all users, receipes and ingredients, then seed again
```

The demo user is `cook@example.com` (the app uses the most recently created user as the current user). The dummy data is development-only and refuses to run in production.

## Moving receipes from the old My receipes form

Receipes created before creation moved to the Receipes tab exist only in My receipes. Move them once, after deploying:

```sh
# Back up the database first, then check what would change (this is the default)
bin/rails data:move_my_receipes_to_receipes

# Apply it
DRY_RUN=0 bin/rails data:move_my_receipes_to_receipes
```

Running it again changes nothing. Each receipe is moved in its own transaction, and a failure is reported without stopping the rest.

## Tests

```sh
bundle exec rspec
bin/rubocop
bin/brakeman --no-pager
```

System specs use Selenium with a browser, so Chrome or Chromium must be installed.

# Plan: manage receipes from the Receipes tab, make My receipes a saved list, upgrade to Ruby 4.0.9

This plan is for an implementation agent. Read all of it before changing code.

## Ground rules
- **Do not commit or push.** The user reviews and commits.
- **Production already has data.** Every change must work with existing rows, and the deploy must not change data by itself. The one data change is a separate, manually-run task (section 5).
- Spelling in this codebase is **"receipe"** everywhere (classes, routes, tables). Keep it.
- Keep the GOV.UK look (`govuk-components`, `govuk_design_system_formbuilder` is the default form builder).
- After each section, run `bundle exec rspec` and `bin/rubocop` and keep both green.
- When something in this plan doesn't match the code, stop and check the code. Don't guess.

## 1. What the app does today (current branch `create-receipe`)

Rails 8.0, PostgreSQL, Hotwire, Stimulus, Active Storage. No login: `ApplicationController#current_user` is `User.last`. `require_user` is a `before_action` on actions that need a user.

Receipes live in one table, `receipes`, with STI on `type`:
- **`GlobalReceipe`**: the public list, shown in the **Receipes** tab (`ReceipesController`, `/receipes`). Most rows were scraped from BBC Food (`ScrapeJob`, `Scraper::*`, `ScraperOld`); those have `user_id = NULL`. `belongs_to :author, class_name: "User", foreign_key: :user_id, optional: true`. `has_many :saved_copies, class_name: "MyReceipe", foreign_key: :global_receipe_id, dependent: :nullify`.
- **`MyReceipe`**: a user's copy, shown in **My receipes** (`SavedReceipes::IndexController`, `/saved_receipes`). `belongs_to :user`, `belongs_to :global_receipe, optional: true`. Copies are made by `ReceipeService::User.save`, which dups the receipe, its ingredients, instructions and image.
- `Receipe` (base): `status` enum `draft`/`published`; `has_many :receipe_ingredients`, `has_many :instructions` (ordered by `step`), `has_one_attached :image`, nested attributes for both. `WIZARD_CONTEXTS = %i[draft ingredients publish]`: name and length rules only run in those validation contexts, so scraped receipes and copies keep saving with default contexts. **Keep this rule.**
- `ReceipeIngredient#ingredient_attributes=` links a row to an `Ingredient` by name (strip + downcase, `find_by || create_or_find_by!`). It never renames an existing ingredient. Keep it unchanged.
- `Instruction`: `step` must be an integer ≥ 0, because the scraper starts at 0.

The **create/edit flow currently lives in My receipes**. It's a 3-step wizard on `MyReceipe`:
- `SavedReceipes::StartController` with `SavedReceipes::StartForm` (`app/forms/saved_receipes/start_form.rb`): image, name, prep/cook time, servings, tags, description.
- `SavedReceipes::IngredientsController` and `SavedReceipes::InstructionsController`, using the Stimulus `nested-form` controller.
- On publish, `ReceipeService::Publish` copies the `MyReceipe` into a `GlobalReceipe` authored by the user, and later edits sync that one public copy.
- My receipes has a Drafts table (`@drafts`), "Edit receipe", "Remove from my receipes" (`remove` member route) and "Delete receipe" (`destroy`). `ReceipeService::DestroyMyReceipe` deletes the copy and its public receipe.
- In the Receipes tab, `ReceipesController` has old scaffold `new/create/edit/update/destroy` actions, views `receipes/_form`, `_ingredient`, `_instruction`, `new`, `edit`, and an `ensure_owner` filter. `SaveReceipeComponent` shows Save/Remove buttons, or "Your receipe" for the author.

Key files to read first: `config/routes.rb`, `app/controllers/receipes_controller.rb`, `app/controllers/saved_receipes/*`, `app/forms/saved_receipes/start_form.rb`, `app/models/{receipe,global_receipe,my_receipe,receipe_ingredient}.rb`, `app/services/receipe_service/*`, `app/components/save_receipe_component.*`, `app/views/saved_receipes/**`, `app/views/receipes/**`, `db/seeds/dev_seeder.rb`, `spec/**`.

## 2. What the user wants (decisions are final)

1. **All create, edit and delete happens in the Receipes tab, on `GlobalReceipe`.**
2. **Anyone can edit or delete any receipe** in the Receipes tab, including scraped ones with no author. There's no login, and this is intended. Record the creator in `user_id` (author) when a receipe is created.
3. **Creating** uses the existing 3-step wizard, moved to the Receipes tab. When the receipe is **published**, it's **automatically added to the creator's My receipes** as a copy.
4. **Editing** a published receipe **updates every copy** of it in everyone's My receipes. Copies mirror the public receipe.
5. **Deleting** a receipe from the Receipes tab **deletes it and every copy** in everyone's My receipes.
6. **My receipes only lists and removes.** No create, edit or delete there. "Remove from my receipes" deletes only that user's copy and never touches the public receipe.
7. The **Drafts table moves to the Receipes tab** and shows the current user's draft receipes.
8. **Existing production data is migrated safely** by a separate task (section 5). Receipes created through the old My receipes form become proper Receipes-tab receipes.
9. **Upgrade Ruby to 4.0.9** (section 6).

## 3. Target design

### 3.1 Routes (`config/routes.rb`)
Replace the `saved_receipes` block and `resources :receipes` with:

```ruby
resources :receipes, only: %i[index show destroy] do
  collection do
    get  "start", to: "receipes/start#new", as: :start
    post "create", to: "receipes/start#create", as: :create
  end
  member do
    get "edit",   to: "receipes/start#edit",   as: :edit
    put "update", to: "receipes/start#update", as: :update
  end
  resources :ingredients,  only: %i[new create], controller: "receipes/ingredients"
  resources :instructions, only: %i[new create], controller: "receipes/instructions"
end

resources :save_receipes, only: %i[create destroy]

resources :saved_receipes, only: %i[index show], controller: "saved_receipes/index" do
  member { delete :remove }
end
```
Run `bin/rails routes` and check the helper names: `start_receipes_path`, `create_receipes_path`, `edit_receipe_path(r)`, `update_receipe_path(r)`, `new_receipe_ingredient_path(r)`, `receipe_ingredients_path(r)`, `new_receipe_instruction_path(r)`, `receipe_instructions_path(r)`, `remove_saved_receipe_path(r)`. Use whatever Rails actually generates, and update every caller (`grep -rn "saved_receipes\|_saved_receipe" app spec`).

### 3.2 Wizard moves to the Receipes tab, on `GlobalReceipe`
- Move the three controllers to `app/controllers/receipes/start_controller.rb`, `ingredients_controller.rb` and `instructions_controller.rb` (module `Receipes`). Move the form object to `app/forms/receipes/start_form.rb` (`Receipes::StartForm`). Move the views to `app/views/receipes/start/*`, `app/views/receipes/ingredients/*` and `app/views/receipes/instructions/*`. Delete the old `SavedReceipes::Start/Ingredients/Instructions` controllers, `SavedReceipes::StartForm`, and their views.
- Find records with `GlobalReceipe.find(params[:receipe_id] || params[:id])`, **not** scoped to the user (decision 2). `create` builds `GlobalReceipe.new(status: "draft", author: current_user)`.
- Keep every behaviour that works today:
  - GOV.UK error summary, and errors on blank ingredient and instruction rows (no `reject_if`).
  - An empty row is rebuilt when the error page has none.
  - Re-uploading the image is optional when one is already attached.
  - `tags` are entered as comma-separated text.
  - "Step N of 3" captions.
  - Hidden `id` fields so re-submitting doesn't duplicate rows.
  - Removed rows are hidden but submitted with `_destroy`.
  - Plain `<button type="button">` add/remove buttons.
  - Text quantity field.
- Form param keys change: `Receipes::StartForm` posts as `receipes_start_form`, and the ingredients/instructions forms post under `global_receipe` (`form_with model: @receipe` on a `GlobalReceipe`). Update `params.expect(...)` and specs to match. The image field id becomes `receipes-start-form-image-field-input`. Check it in the rendered HTML.
- Move the publish-time validations from `MyReceipe` to `GlobalReceipe`, keeping the same contexts so scraped receipes are unaffected:
  - `validates :description, :prep_time, :cook_time, :servings, presence: true, on: :publish`
  - `must_have_ingredients`, `must_have_instructions` and `must_have_image`, all `on: :publish`.
  - `ingredient_names_given` and `ingredients_unique`, `on: Receipe::WIZARD_CONTEXTS`.

  Remove these from `MyReceipe`. Copies are never validated with wizard contexts.
- Save contexts: step 1 saves with `:draft` (or `:publish` if already published). Step 2 saves with `:ingredients` (or `:publish`). Step 3 sets `status = "published"` and saves with `:publish`.
- **After a successful save of a published receipe** (step 3, and steps 1–2 when it's already published), call the new `ReceipeService::SyncCopies.call(receipe:)` (3.4). On the **first publish**, also call `ReceipeService::User.save(receipe:, user: current_user)` so the creator gets a copy. Skip that if they already have one. Run these after the save commits: an uploaded image is only on disk after commit, and its bytes are copied.
- Step 3 success redirects to `receipe_path(receipe)` with the notice "Receipe published". Step 1 back link: `receipes_path`. Step 2 back link: `edit_receipe_path`. Step 3 back link: `new_receipe_ingredient_path`.
- Delete the old scaffold: `ReceipesController#new/create/edit/update`, `ensure_owner`, `receipe_params`, and the views `receipes/_form.html.erb`, `_ingredient.html.erb`, `_instruction.html.erb`, `new.html.erb`, `edit.html.erb`. Delete `ReceipeService::Publish` and `ReceipeService::DestroyMyReceipe` once nothing uses them.

### 3.3 Receipes tab pages
- **Index** (`receipes/index.html.erb`):
  - Add a "Create new receipe" button (`start_receipes_path`) above the grid, with the same spacing classes My receipes uses now: `govuk-!-margin-top-4 govuk-!-margin-bottom-6`.
  - Below it, add the **Drafts** table, moved from `saved_receipes/index/index.html.erb`: GOV.UK summary list, Draft tag, "Last edited", a "Continue" action (`edit_receipe_path(draft)`), and a "Delete" action (`turbo_method: :delete`, `turbo_confirm`, `visually_hidden_text:`). `@drafts = GlobalReceipe.draft.where(user_id: current_user.id).order(updated_at: :desc)`. Only show the table when `current_user` is present.
  - The grid keeps listing published receipes only. The filter already uses `GlobalReceipe.published`.
- **Show** (`receipes/show.html.erb`):
  - Add "Edit receipe" (`edit_receipe_path`, which goes to step 1) and "Delete receipe" (`button_to receipe_path, method: :delete`, warning style, `turbo_confirm: "Delete this receipe? It will also be removed from everyone's My receipes. This cannot be undone."`).
  - Keep the Save/Remove buttons (`SaveReceipeComponent`).
  - Drafts (`/receipes/:id` of a draft) should still show, so authors can preview. Show the Draft tag, and hide Save/Remove for drafts.
- **`ReceipesController#destroy`**: add `before_action :require_user`. Call `ReceipeService::DestroyReceipe.call(receipe:)` (3.4), then redirect to `receipes_path` with the notice "Receipe deleted" and `status: :see_other`.
- **`SaveReceipeComponent`**: remove the "Your receipe" branch. It shows "Remove from my receipes" if the user has a copy (`user.my_receipes.find_by(global_receipe_id: receipe.id)`), otherwise "Save to my receipes". Render nothing for drafts. `ReceipeService::User.save` must no longer refuse authors, and `.remove` must only destroy the user's copy, never the public receipe. Keep `create.turbo_stream.erb` / `destroy.turbo_stream.erb` rendering the component.

### 3.4 Services (`app/services/receipe_service/`)
- **`SyncCopies.call(receipe:)`**: for every `MyReceipe.where(global_receipe_id: receipe.id)`, make the copy match. Copy `name, description, prep_time, cook_time, servings, tags`, and set `status: "published"`. Replace `receipe_ingredients` and `instructions` (delete them, rebuild from the receipe, same `Ingredient` rows). Copy the image with `ReceipeService::CopyImage` only when the receipe's blob changed: compare `copy.image.blob&.checksum` with `receipe.image.blob.checksum`. Use one transaction per copy, and `save!` with the default context. Copies are mirrors (decision 4), so overwriting them is expected.
- **`DestroyReceipe.call(receipe:)`**: in a transaction, destroy all copies (`MyReceipe.where(global_receipe_id: receipe.id).destroy_all`), then destroy the receipe. Change `GlobalReceipe has_many :saved_copies` to `dependent: :destroy`, so any other path that destroys a `GlobalReceipe` also removes its copies.
- `User.save` already copies image bytes through `CopyImage`, falling back to sharing the blob when the file is missing. Keep that. Active Storage doesn't purge a blob that is still attached elsewhere, so shared blobs from old data are safe.

### 3.5 My receipes becomes a saved list
- `SavedReceipes::IndexController`: keep `index` (filters, pagination, `base_scope: current_user.my_receipes.published`), `show` and `remove`. Remove `destroy` and the drafts query. `remove` destroys only the user's copy, with the notice "Receipe removed from my receipes".
- `saved_receipes/index/index.html.erb`: remove the "Create new receipe" button and the Drafts table.
- `saved_receipes/index/show.html.erb`: remove "Edit receipe" and "Delete receipe". Keep "Remove from my receipes" (`button_to remove_saved_receipe_path, method: :delete`, secondary style) and "Back to my receipes". Add a "View in Receipes" link to `receipe_path(@my_receipe.global_receipe)` when it exists and is published.
- `MyReceipe`: remove `authored_global`, `authored?` and the publish validations. Keep `saved_copy?` only if still used; otherwise delete it.
- The navigation already underlines "My receipes" for `saved_receipes/*` and "Receipes" for everything else, which now includes `receipes/*`. Check it still works.

### 3.6 Seeds (`db/seeds/dev_seeder.rb`)
Update so `bin/rails dev:seed` / `dev:reseed` matches the new model:
- **cook's own receipes:** `GlobalReceipe`s with `author: cook`. When published, they're auto-added to cook's My receipes via `ReceipeService::User.save`.
- **draft:** one draft `GlobalReceipe` authored by cook.
- **saved:** three scraped-style receipes saved to cook's My receipes.

The seeder must still be idempotent, must refuse to run in production, and must stay outside autoload paths.

## 4. Tests
Update or replace the specs that cover the old My receipes wizard: `spec/requests/create_receipe_wizard_spec.rb`, `spec/requests/published_receipes_spec.rb`, `spec/system/recipe_creation_flow_spec.rb`, `spec/system/create_receipe_validation_spec.rb`, factories, and `spec/lib/dev_seeder_spec.rb`. Keep `spec/requests/production_safety_spec.rb` passing and extend it. Required coverage:
- **Wizard in the Receipes tab:** create a draft with image (sets author, appears in the Receipes-tab Drafts table, not in the grid, not in My receipes). Blank or duplicate ingredient errors. Shared ingredients never renamed. Re-submitting instructions doesn't duplicate them. Publishing requires ingredients, instructions and image. Publishing adds exactly one copy to the creator's My receipes, and publishing again doesn't add a second.
- **Edit by anyone:** a user who isn't the author can edit any receipe, including a scraped one with `user_id: nil`. Editing a published receipe updates **all** users' copies (name, ingredients, instructions, image), and doesn't change the copy count.
- **Delete by anyone:** deleting from the Receipes tab removes the receipe and every copy in all users' My receipes. Drafts are deletable from the Drafts table.
- **My receipes:** no create, edit or delete links or routes (`/saved_receipes/start` and `DELETE /saved_receipes/:id` are not routable). Remove deletes only the user's copy, and the public receipe stays. Users only see their own copies.
- **Save / Remove on the Receipes tab** works for any published receipe, including the user's own.
- **Production safety:** scraper-style `GlobalReceipe.create!` (step 0, long ingredient names) still works. Old copies that share a blob with the public receipe keep the image after remove or delete. Saving a receipe whose image file is missing still works.
- **Data task (section 5)** specs, including running it twice.
- **System specs** (`js: true`): the full create → publish flow from the Receipes tab, the receipe appearing in both tabs, edit and delete from the Receipes tab, and remove from My receipes.

## 5. Safe data migration for existing production rows

Add `lib/tasks/data.rake` with `bin/rails data:move_my_receipes_to_receipes`. Put the logic in `app/services/data_migrations/move_my_receipes_to_receipes.rb`, or in `lib/` if you exclude it from eager loading; it must not run at boot. **Deploying must not run it.** The user runs it once, by hand, after deploy.

Which rows: every `MyReceipe` with `global_receipe_id: nil`. These are receipes created through the old My receipes form, published or draft. Saved copies always have a `global_receipe_id`. Before writing, query production-like data to confirm this (see "Safety" below).

For each such row:
- **Published:** create a `GlobalReceipe` with the same `name, description, prep_time, cook_time, servings, tags`, `status: "published"` and `user_id` = the row's user. Copy the ingredient rows (same `Ingredient`s), instructions, and image (`CopyImage`). Then set the row's `global_receipe_id` to the new receipe. The row stays in My receipes as the creator's copy.
- **Draft:** create a draft `GlobalReceipe` authored by the user, in the same way, then **destroy the old `MyReceipe` draft**. Drafts now live in the Receipes tab, and My receipes only shows published copies. Destroy only after the new receipe, its ingredients, instructions and image have been verified as saved.

Safety:
- `DRY_RUN=1` (default **on** unless `DRY_RUN=0`) prints what it would do, with counts and IDs, and changes nothing.
- Use one transaction per row, so a failure rolls back only that row. Log each error and keep going, then print a summary (moved published, moved drafts, skipped, failed).
- It must be idempotent: rows already linked are skipped, so running it twice changes nothing.
- Save with the default validation context, never wizard contexts, so incomplete old drafts still move.
- Don't touch saved copies, scraped receipes, users or ingredients.
- In the plan's deploy notes, tell the user to **back up the database before running it** (`pg_dump`), and to run it with `DRY_RUN=1` first.

## 6. Upgrade Ruby to 4.0.9

The developer's machine already runs Ruby 4.0.9. Production builds from the `Dockerfile`, currently on 3.4.4.
1. `.ruby-version` → `ruby-4.0.9`. In the `Dockerfile`, `ARG RUBY_VERSION=4.0.9`. Check that the `docker.io/library/ruby:4.0.9-slim` image tag exists. CI (`.github/workflows/ci.yml`) reads `.ruby-version`, so no change there.
2. Booting in production mode under Ruby 4.0.9 currently fails inside the `net-imap` gem (0.5.10):
   ```
   net-imap-0.5.10/lib/net/imap/config/attr_type_coercion.rb:32:in 'Ractor.make_shareable': cannot make a shareable Proc because the outer variable 'enum' may be reassigned. (Ractor::IsolationError)
   ```
   Reproduce: `RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bin/rails runner 'Rails.application.eager_load!; puts "ok"'`. Fix it by updating `net-imap` (`bundle update net-imap --conservative`) to a release that supports Ruby 4.0. Check its changelog, and don't guess a version.
3. Rails 8.0.2.1 is end-of-life (brakeman warns). Update to the latest **8.0.x** patch with `bundle update rails --conservative`. Do not jump to a new minor version in this change.
4. The working tree already has uncommitted `Gemfile.lock` changes, made locally under Ruby 4.0.9: `ffi` and `nokogiri` ruby-platform entries, `mini_portile2`, minitest 5.25.5 → 6.0.6, unicode-emoji 4.1.0 → 4.3.0. Run `bundle install` under Ruby 4.0.9, then review `git diff Gemfile.lock`. Keep only what's needed and explain each change in your summary. Make sure `bundle lock --add-platform` covers the Docker platform (x86_64-linux and/or aarch64-linux). Keep `BUNDLED WITH` consistent with the bundler shipped with Ruby 4.0.9.
5. Verify, and paste the results into your summary:
   - `bundle exec rspec` (all green)
   - `bin/rubocop`
   - `bin/brakeman --no-pager` (the Rails end-of-life warning should be gone)
   - the production boot command above prints `ok`
   - `SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bin/rails assets:precompile` succeeds
   - `docker build .` succeeds, if Docker is available. If it isn't, say so.

## 7. Deploy notes to include in your final summary
- **No schema migrations.** The deploy itself doesn't change data.
- After deploy: **back up the DB**, run `bin/rails data:move_my_receipes_to_receipes` with `DRY_RUN=1`, review the output, then run it with `DRY_RUN=0`.
- **Behaviour changes users will notice:**
  - Create, edit and delete moved to the Receipes tab.
  - Anyone can edit or delete any receipe.
  - Edits overwrite everyone's copies.
  - Delete removes everyone's copies.
  - My receipes only removes.

## 8. Acceptance checklist
- [ ] Receipes tab: create (3 steps), Drafts table with Continue and Delete, edit and delete on any receipe including scraped ones.
- [ ] Publishing adds the receipe to the creator's My receipes once. Edits sync all copies. Delete removes all copies.
- [ ] My receipes: list, view, "Remove from my receipes" only. The public receipe is unaffected by Remove.
- [ ] Data task: dry-run by default, idempotent, per-row transactions, summary output.
- [ ] Ruby 4.0.9: `.ruby-version`, `Dockerfile`, gems updated, production boot OK, assets precompile OK.
- [ ] `bundle exec rspec`, `bin/rubocop` and `bin/brakeman` clean. Nothing committed or pushed.

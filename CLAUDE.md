# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bin/setup        # Install dependencies, prepare DB, create git hooks
bin/dev          # Start dev server (web + JS + CSS via foreman)
bin/check        # Run zeitwerk check + full RSpec test suite
bin/lint         # Run rubocop, erb-lint, eslint, stylelint, brakeman
bin/lint --fix   # Auto-fix lint issues where possible
```

To run a single test file: `bundle exec rspec spec/path/to/spec.rb`

## Architecture

KitchenSync is an AI-powered recipe suggestion app. Users manage a "Fridge" of ingredients and generate recipe suggestions from them.

**Stack**: Rails 7 / PostgreSQL / Hotwire (Turbo + Stimulus) / Bootstrap 5 / ViewComponent

### Core Data Model

`Fridge` is the central model. Ingredients are **not** a separate table — they are stored as a JSON array on `fridges.ingredients` using the `StoreModel` gem. The generated recipe text is stored on `fridges.recipe`.

### Key Flow

1. User adds ingredients to a Fridge (manual entry, barcode scan, or photo)
2. Barcode scans resolve product names via `BarcodeResolverService` → GoUPC API
3. Photo uploads detect ingredients via `ImageService` → Ultralytics object detection + GPT-3.5-turbo validation
4. Recipe generation calls `RecipeSuggestionService` → GPT-4 with streaming, broadcasting chunks back to the UI via Turbo

### Service Objects

All external API calls are encapsulated in `app/services/`:

- `RecipeSuggestionService` — Streams GPT-4 completions, broadcasts each chunk via Turbo to the client
- `ImageService` — Sends image to Ultralytics for object detection, then uses GPT-3.5-turbo to filter results to food items only
- `BarcodeResolverService` — Resolves barcodes to product names via GoUPC API

### Frontend

- **Turbo Streams** for real-time recipe streaming and ingredient list updates
- **Stimulus** controllers for barcode scanning (`html5-qrcode`) and camera/image capture
- **ViewComponent** for reusable UI components (see `app/components/`)

### Credentials

Rails encrypted credentials store API keys under these keys:
- `openai` — OpenAI API key
- `ultralytics` — Ultralytics API key
- `goupc` — GoUPC barcode API key

### Testing

- RSpec with FactoryBot and Capybara (Selenium) for system tests
- VCR cassettes for external API calls (recorded locally; CI uses `:none` mode)
- Run `bin/check` which also validates autoloading with `zeitwerk:check`

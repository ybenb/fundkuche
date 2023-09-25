# KitchenSync 🥦 🥕 🍽️

**KitchenSync** is a project from Learning-Week 2023 AI-MVP (Team 2). It offers gourmet recipe suggestions tailored to
the ingredients you have left in your fridge. Elevate your culinary journey with the power of AI!

## Environments

| Branch | Domain                                                    | Deployment | CI Status                                                                                                                                                                            |
|--------|-----------------------------------------------------------|------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| main   | [KitchenSync Main](https://kitchen-sync-main.renuoapp.ch) | release    | [![Build Status](https://renuo.semaphoreci.com/badges/kitchen-sync/branches/main.svg?key=9366d2b6-803c-473d-8c35-dbdd40b60d5c)](https://renuo.semaphoreci.com/projects/kitchen-sync) |

## Getting Started

### Setup

1. Clone the repository:
    ```sh
    git clone git@github.com:renuo/kitchen-sync.git
    cd kitchen-sync
    ```

2. Run the setup script:
    ```sh
    bin/setup
    ```

3. Copy the Rails master key from the 1Password vault into `config/master.key`.

4. Configure the environment variables in `.env`

### Running the Application

To start the application for local development, run:

```sh
bin/dev
```

### Dependencies

Ensure you have the following dependencies installed:

* Ruby 3.2.2
* Node.js 18.16.0
* PostgreSQL
* Redis

### Running Tests

Execute the tests with:

```sh
bin/check
```

### Linting

To check for linting issues, run:

```sh
bin/lint
```

If you encounter any linting errors, many of them can be automatically corrected by using the `--fix` option:

```sh
bin/lint --fix
```

## Copyright

Copyright © 2023 [Renuo AG](https://www.renuo.ch/).

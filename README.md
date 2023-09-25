# KitchenSync 🥦 🍅 🍔

This is a Learning-Week 2023 AI-MVP (Team 2) project. Discover gourmet recipe suggestions tailored to the leftovers in your fridge. Elevate your culinary experience with the power of AI!

## Environments

| Branch | Domain                                | Deployment | CI                                                                                                                                                                                   |
|--------|---------------------------------------|------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| main   | https://kitchen-sync-main.renuoapp.ch | release    | [![Build Status](https://renuo.semaphoreci.com/badges/kitchen-sync/branches/main.svg?key=9366d2b6-803c-473d-8c35-dbdd40b60d5c)](https://renuo.semaphoreci.com/projects/kitchen-sync) |

## Setup

```sh
git clone git@github.com:renuo/kitchen-sync.git
cd kitchen-sync
bin/setup
```

### Configuration

Configure the following:

* .env

### Run

```sh
bin/dev
```
### Dependencies

* Ruby 3.2.2
* PostgreSQL 13+
* Redis 7

### Tests / Checks

```sh
bin/check
```

## Copyright

Copyright 2023 [Renuo AG](https://www.renuo.ch/).

# LiveWebServer - a pure-Elixir web server backed by PostgreSQL

## Requirements

* Docker 27 or above

## Installation

```bash
git clone git@github.com:oiax/live_web_server.git
cd live_web_server
docker compose build
```

## Usage

```bash
docker compose up -d
docker compose exec app bash
```

```bash
mix deps.get
mix ecto.setup
mix phx.server
```

Open `http://admin.lvh.me:4000` with your browser.


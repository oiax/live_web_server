# LiveReverseProxy - a pure-Elixir reverse proxy backed by PostgreSQL

## Requirements

* Docker 27 or above

## Installation

```bash
git clone git@github.com:oiax/live_reverse_proxy.git
cd live_reverse_proxy
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


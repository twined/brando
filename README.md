![Brando logo](https://raw.githubusercontent.com/twined/brando/master/priv/static/brando/img/brando-big.png)

*EXPERIMENTAL, DO NOT USE*

Install:
--------
Add Brando, Ecto, bcrypt and postgrex to your `deps` and `applications`
in your project's `mix.exs`:

    def application do
      [mod: {MyApp, []},
       applications: [:phoenix, :cowboy, :logger, :postgrex,
                      :ecto, :bcrypt, :brando]]
    end

    defp deps do
      [{:postgrex, "~> 0.5"},
       {:ecto, "~> 0.5"},
       {:bcrypt, github: "opscode/erlang-bcrypt"},
       {:brando, github: "twined/brando"]}
    end

Remember to start the Ecto repo in your `lib/my_app.ex`:

    children = [
      # Define workers and child supervisors to be supervised
      # worker(MyApp.Worker, [arg1, arg2, arg3])
      worker(MyApp.Repo, [])
    ]

Install Brando:

    $ mix brando.install

Create the database:

    $ mix ecto.create MyApp.Repo

Create an initial migration for the `users` table:

    $ mix ecto.gen.migration MyApp.Repo add_users_table

then add the following to the generated file:

    defmodule MyApp.Repo.Migrations.AddUsersTable do
      use Ecto.Migration

      def up do
        ["CREATE TABLE users (
            id serial PRIMARY KEY,
            username text,
            full_name text,
            email text UNIQUE,
            password text,
            avatar text,
            administrator bool,
            editor bool,
            last_login timestamp,
            inserted_at timestamp,
            updated_at timestamp)",

          "CREATE UNIQUE INDEX ON users (lower(username))"]
      end

      def down do
        "DROP TABLE IF EXISTS users"
      end
    end

Now run the migration:

    $ mix ecto.migrate MyApp.Repo

Routes/pipelines/plugs in `router.ex`:

    plug LoginRequired,
      helpers: MyApp.Router.Helpers

Endpoint config in `endpoint.ex`:

    plug Plug.Static,
      at: "/static", from: :brando

    plug Plug.Static,
      at: "/media", from: "priv/media"

Configuration:
--------------

In your `config/config.exs`:

    config :brando,
      app_name: "MyApp",
      router: MyApp.Router,
      endpoint: MyApp.Endpoint,
      repo: MyApp.Repo,
      media_url: "/media",
      templates_path: "path/to/brando/templates",
      use_modules: [MyApp.Admin, MyApp.Users, MyApp.MyModule],
      menu_colors: ["#FBA026;", "#F87117;", "#CF3510;", "#890606;", "#FF1B79;",
                    "#520E24;", "#8F2041;", "#DC554F;", "#FF905E;", "#FAC51C;",
                    "#D6145F;", "#AA0D43;", "#7A0623;", "#430202;", "#500422;",
                    "#870B46;", "#D0201A;", "#FF641A;"]

    config :my_app, MyApp.Repo,
      database: "my_app",
      username: "postgres",
      password: "postgres",
      hostname: "localhost"

Mugshots
========

Image processing and thumbnails for Brando

Config
------
Optimizing images: (not implemented yet)

    config :brando, :mugshots, :optimize
      png: [enabled: true,
            bin: "/usr/local/bin/pngquant",
            params: "--speed 1 --force --output \"#{new_filename}\" -- \"#{filename}\""],
      jpeg: [enabled: true,
             bin: "/usr/local/bin/jpegoptim",
             params: "#{filename}"]

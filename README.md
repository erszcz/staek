# Staek - split your bills with ease

A local-first Phoenix and Elixir Desktop bill-splitting app loosely modeled after Splitwise.
This experiment also explores using CR-SQLite as an Ecto backend with
eventually consistent sync between desktop and web instances of the app.
All the code is hosted in this single repo as a Phoenix umbrella project:
- `staek` - the Ecto model app
- `staek_web` - the traditional Phoenix web app
- `staek_desktop` - the Elixir Desktop standalone app

There's almost no extra code needed for the desktop version,
it's almost the same as the web app, apart from a somewhat different app
structure and startup.


## Usage

Create or reset the independent desktop and web databases:

```
mix reset
```

Start the desktop version - a new desktop window should pop up:

```
mix start_desktop
```

Start the web version - open the web endpoint as with any other Phoenix web app:

```
mix start_web
```


## ESL internal

Check out [the tech dojo slides on local-first Elixir Desktop apps][slides].

[slides]: https://docs.google.com/presentation/d/1kXenLPUzEDBFkCW23hXPs7uOl7jAFFSJmYM31hsHEc4/edit?usp=sharing

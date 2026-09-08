# VisibleSim Easy Install

This project packages [VisibleSim](https://github.com/ProgrammableMatterProject/VisibleSim) — the modular/programmable matter simulator developed by the Programmable Matter Project — into a ready-to-use Docker environment.

VisibleSim normally requires a fairly involved manual setup: installing the right system dependencies, cloning the repository, compiling the simulator core and its robot libraries, and then compiling each application against it with the correct flags. This project removes all of that friction. It builds a container that already contains a fully compiled VisibleSim, a graphical desktop to work in, and a VSCode server to write code in, so that all you have to do is `docker compose up` and start writing applications.

Concretely, the container gives you:

- A full **Linux desktop** (Xfce, via [Webtop](https://github.com/linuxserver/docker-webtop)), accessible from your browser, with VisibleSim's graphical dependencies already installed.
- A **VSCode server**, accessible from your browser, to comfortably edit your application code.
- A **precompiled VisibleSim**, so the heavy, error-prone parts of the build happen once, at image-build time, instead of on every run.
- A simple **`run` command** that takes care of compiling and launching your own application against VisibleSim.

## Getting Started

```bash
docker compose up -d
```

Once the container is up, open the desktop and the code editor in your browser (see below), write your application in `src/`, and use the `run` command from a terminal inside the desktop to compile and launch it.

## User Guide

A few points worth knowing before you get started.

### Accessing the desktop and the code editor

The container exposes two separate web interfaces:

- The **desktop** is available at [`localhost:5000`](http://localhost:5000).
- The **VSCode server** is available at [`localhost:8000`](http://localhost:8000).

These two are intentionally kept separate rather than running VSCode *inside* the desktop's browser. Running a browser-based editor inside a remote desktop that is itself displayed inside a browser adds a lot of unnecessary overhead for no real benefit, so VSCode gets its own dedicated page instead. As a bonus, this also makes it easy to set up a multi-screen workflow: put the desktop tab on one screen and the editor tab on another.

### Running a project

Once your application source code is in place, you can compile and run it with:

```bash
run <project_name>
```

This command **must be run from a terminal inside the desktop** (at `localhost:5000`), not from the VSCode server and not from your host machine. VisibleSim needs a graphical interface to run its simulations, so it can only be launched from an environment that actually has one.

It is also strongly recommended that you use `run` rather than compiling and launching the project manually. The default VisibleSim build process won't work out of the box for this setup: for instance, `applicationsSrc` needs a `Makefile` that is copied into place before compilation and removed again afterwards (see below), among a few other adjustments. The `run` script handles all of this for you.

### Customizing the setup

Everything here is just plain Docker, so nothing is off-limits — you're free to edit `docker-compose.yml`, the `Dockerfile`, or any other file to adapt the project to your needs.

By default:

- Two ports are exposed: `5000` for the desktop and `8000` for the VSCode server.
- Your application code is stored on your host machine under `src/`, which is mounted into the container as `/opt/VisibleSim/applicationsSrc`.

## Developer Guide

This section explains what each of the non-obvious files in the repository is for.

### `VisibleSim/Makefile` and `VisibleSim/simulatorCore/src/Makefile`

These two files replace the corresponding Makefiles in the upstream VisibleSim repository. They exist to fix a bug that otherwise prevents the **Datoms** robot library from compiling. They are copied into the cloned repository at image-build time, before VisibleSim itself is compiled.

### `VisibleSim/.applicationsSrc/Makefile`

This Makefile is not used directly by VisibleSim's default build. Instead, it's copied into `applicationsSrc/` at compile time (by the `run` script) and removed again once compilation finishes. It plays two roles:

- It's the reason `run` needs to copy/remove a Makefile around each compilation in the first place (this was necessary, as the entirety of `VisibleSim/applicationsSrc` was mounted, and this Makefile was part of it).
- It also adjusts a few values so that they can be driven by variables (in particular, which application to target) instead of being hardcoded, which is what allows `run <project_name>` to build an arbitrary project without editing any file by hand.

### `scripts/`

This folder holds helper scripts meant to make day-to-day usage more convenient. It contains the following scripts:

- **`run`** — compiles and runs a given project. It copies the `.applicationsSrc/Makefile` into place, builds the target application (using `DOCKER_CUSTOM_VAR__TARGET_APP` to select it), removes the temporary Makefile, copies the project's `config.xml` next to the resulting binary, and finally launches it.

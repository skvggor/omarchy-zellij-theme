# mugdoc

Generate a documentation site from your project's README using Astro and Starlight.

---

<img height="50" src="assets/star.svg" alt="if you liked it, give it a star" />

---

## How it works

Clone this repo into your project, run `setup.sh`, and get a static documentation site. The setup script detects your project name and description, converts your README into the site content, copies referenced images, installs dependencies, and removes itself.

The generated site is a single page with your README content, no sidebar, and a table of contents on the right.

## Usage

```bash
git clone --depth 1 git@github.com:skvggor/mugdoc.git docs && rm -rf docs/.git && ./docs/setup.sh
```

### Options

| Flag | Description | Required |
|---|---|---|
| `--domain` | Base domain for the site URL | Yes |
| `--deploy` | Absolute path on the server to deploy via SSH | No |
| `--port` | Container port for the docs site (requires --deploy) | No |

### Examples

With a custom domain:

```bash
./docs/setup.sh --domain example.com
```

Deploy to a VPS:

```bash
./docs/setup.sh --domain example.com --deploy /root/projects/my-project
```

Deploy with custom port:

```bash
./docs/setup.sh --domain example.com --deploy /root/projects/my-project --port 3001
```

After setup:

```bash
cd docs && npm run dev       # development server
cd docs && npm run build     # build static site
cd docs && npm run preview   # preview build
```

## Project detection

The setup script detects your project name from (in order):

| File | Field |
|---|---|
| `package.json` | `name` |
| `Cargo.toml` | `[package] name` |
| `go.mod` | `module` |
| `pyproject.toml` | `[project] name` |

Falls back to the parent directory name.

Description is extracted from the first text line in the README (skipping headings, HTML tags, links, and code blocks), then from `package.json` description, then a generic fallback.

## Images

Local images referenced in the README (both markdown and HTML `<img>` syntax) are automatically copied to the site's public directory and their paths are rewritten. External URLs are left unchanged.

If the project has an `assets/` directory at the root, its contents are also copied.

## Deploy

The `--deploy` flag generates everything needed to deploy the docs site to a VPS using Docker, Caddy, and GitHub Actions.

This creates:

- `docs/Dockerfile` -- multi-stage build: Node builds the Astro site, Caddy serves the static files
- `docs/compose.yml` -- Docker Compose service with [caddy-docker-proxy](https://github.com/lucaslorentz/caddy-docker-proxy) labels for automatic HTTPS
- `.github/workflows/deploy-docs.yml` -- GitHub Actions workflow that deploys via SSH on push to `main`

The site URL is `https://{project-name}.{domain}`.

The workflow uses [appleboy/ssh-action](https://github.com/appleboy/ssh-action) and requires these repository secrets:

| Secret | Description |
|---|---|
| `HOST` | Server IP or hostname |
| `USERNAME` | SSH user |
| `SSH_PRIVATE_KEY` | Private key for authentication |
| `PORT` | SSH port (optional, defaults to 22) |

Without `--deploy`, the deploy files are removed and only the local development setup is kept.

## Requirements

- Node.js
- npm, pnpm, or yarn

## Stack

- [Astro](https://astro.build) + [Starlight](https://starlight.astro.build)
- [Tailwind CSS](https://tailwindcss.com) via `@astrojs/starlight-tailwind`

## License

[GNU General Public License v3.0](LICENSE)

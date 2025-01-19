# Configuration Directory

This directory contains environment-specific and application-specific configuration files for the load testing solution. Each application has its own folder, and within it, separate folders for `dev`, `staging`, and `prod`.

## Example Structure

```
configs/
├── app1/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── app2/
│   ├── dev/
│   ├── staging/
│   └── prod/
```

## Adding a New Application
- Create a folder for the new application.
- Add environment-specific subfolders (e.g., `dev`, `staging`, `prod`).
- Copy the content of `configs/app.example` in the appropriate folders.
- Rename `config.env.example`into ìnto `config.env` and set variables with your configuration

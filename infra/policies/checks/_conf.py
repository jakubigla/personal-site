"""Helpers for reading Checkov's list-wrapped Terraform resource configuration."""


def first(value, default=None):
    """Unwrap the single-item list Checkov wraps around every attribute and block."""
    while isinstance(value, list):
        if not value:
            return default
        value = value[0]
    return default if value is None else value


def blocks(conf, name):
    """Every instance of a repeated nested block as a plain dict."""
    found = conf.get(name) or []
    return [b for b in found if isinstance(b, dict)]

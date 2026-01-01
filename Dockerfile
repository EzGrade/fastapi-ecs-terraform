FROM python:3.13-alpine AS build
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /code
COPY pyproject.toml uv.lock /code/

RUN uv sync --frozen --no-install-project --no-dev

FROM python:3.13-alpine AS runtime

WORKDIR /code

COPY --from=build /code/.venv /code/.venv
COPY app /code/app

ENV PATH="/code/.venv/bin:$PATH"

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

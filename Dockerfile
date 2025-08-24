# -------- Stage 1: Build environment (install dependencies) --------
FROM python:3.12-slim AS builder

# Set work directory
WORKDIR /app

# Install/update dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean


# Install uv (fast dependency manager)
RUN pip install uv

# Create virtual environment, install python dependencies
COPY pyproject.toml pyproject.toml
RUN uv venv .venv && \
    . /app/.venv/bin/activate && \
    uv sync --no-cache --active

# -------- Stage 2: Runtime image --------
FROM python:3.12-slim AS runtime

# Set work directory
WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /app/.venv  /app/.venv

# Make virtualenv the default Python
ENV PATH="/app/.venv/bin:$PATH"

# Copy app code
COPY . .

#  Adding new user "appuser"
RUN useradd -u 1000  -c "App user" -m appuser  

# Changing ownership of the files from "root" user to "appuser"
RUN chown -R appuser:appuser /app

# Changing read+write+execute to the folder "/app"  
RUN chmod -R 777 /app

# Switch to appuser
USER appuser

# Expose port
EXPOSE 8000

# Run app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

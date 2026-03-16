FROM odoo@sha256:aba5b4d3b94e568fb34aa5527f5e65b4d49c8f972692249850126767bcb35ec0

USER root

RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

USER odoo
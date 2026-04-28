FROM debian:trixie-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        jq \
        gnupg \
        ca-certificates \
        python3 \
	python3-jsonschema \
	&& rm -rf /var/lib/apt/lists/*

COPY recipe_tool.sh /usr/local/bin/recipe_tool.sh
COPY validate_recipe.py /usr/local/bin/validate_recipe.py
RUN chmod +x /usr/local/bin/recipe_tool.sh /usr/local/bin/validate_recipe.py

WORKDIR /workspace

ENTRYPOINT ["recipe_tool.sh"]

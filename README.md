# Generative AI Stack
- Stripped from https://github.com/docker/genai-stack
- Set up for OpenAI/Amazon/Google/Ollama, the .env file's LLM variable determines which backend is selected

Run with `./launch.sh`, or `docker compose --profile ollama up --build`.

The `ollama-gpu` profile can be used to enable GPU support, but it must be uncommented first (in `docker-compose.yml`). The `.env` OLLAMA_BASE_URL must also match the profile's service (`http://llm:11434` for ollama profile, `http://llm-gpu:11434` for ollama-gpu profile).

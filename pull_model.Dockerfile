FROM ollama/ollama:latest AS ollama
FROM python:3.9-slim

# just using as a client - never as a server
COPY --from=ollama /bin/ollama /usr/local/bin/ollama

COPY <<EOF pull_model.py
import os
import time
import subprocess
import asyncio

def main():
  try:
    llm = os.getenv("LLM")
    url = os.getenv("OLLAMA_BASE_URL")
    if llm and url and llm not in {"gpt-4", "gpt-3.5", "claudev2"}:
      print(f"pulling ollama model {llm} using {url}")

      async def show_progress():
        n = 0
        while True:
          await asyncio.sleep(5)
          n += 1
          print(f"... pulling model ({n * 10}s) - will take several minutes")

      async def pull_model():
        process = await asyncio.create_subprocess_shell(
          # the following `ollama show` command will produce "Error: model 'llama2' not found", it is expected to error at this point
          f"bash -c './usr/local/bin/ollama show {llm} --modelfile > /dev/null || ./usr/local/bin/ollama pull {llm}'",
          env={"OLLAMA_HOST": url}
        )
        await process.communicate()

      loop = asyncio.get_event_loop()
      done, pending = loop.run_until_complete(
        asyncio.wait([show_progress(), pull_model()], return_when=asyncio.FIRST_COMPLETED)
      )

      for task in pending:
        task.cancel()
    else:
      print("OLLAMA model only pulled if both LLM and OLLAMA_BASE_URL are set and the LLM model is not gpt")
  except Exception as e:
    print(e)
    exit(1)

if __name__ == "__main__":
  main()
EOF

ENTRYPOINT ["python", "pull_model.py"]
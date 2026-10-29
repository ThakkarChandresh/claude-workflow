# Sync References Prompt

Dispatch a fresh general-purpose subagent with this prompt to clone or
update the reference repos. Fill in the paths and the service you're
in. It's mechanical work, so a fast, inexpensive model is enough.

```
Run this command and wait for it to finish:

    bash [SCRIPT_PATH] [REPOS_FILE] [REFERENCES_DIR] [THIS_SERVICE]

Don't fix, delete, re-clone or edit anything yourself, even if a repo
fails. Reply with the lines the command printed, exactly as printed,
and nothing else.
```

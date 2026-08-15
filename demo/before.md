Thanks for sharing this — the function is straightforward, but there are a few issues worth fixing before it ships, one of them serious.

**1. SQL injection (critical).** Building the query with string concatenation means any caller-controlled `id` can inject SQL — `str(id)` does not sanitize anything, and even if `id` is currently always an int, that's an assumption the function can't enforce. Use a parameterized query:

```python
result = db.query("SELECT * FROM users WHERE id = %s", (id,))
```

(placeholder syntax depends on your driver — `?` for sqlite3, `%s` for psycopg/MySQL).

**2. The error handling creates a new crash.** If the query throws, `result` becomes `None`, and then `for r in result` raises `TypeError: 'NoneType' object is not iterable` — so the `except` doesn't actually protect anything; it just converts a meaningful DB error into a confusing one two lines later. Either let the exception propagate (usually the right call for a data-access helper) or return `[]` directly from the handler.

**3. Bare `except:` swallows too much.** It catches everything including `KeyboardInterrupt` and `SystemExit`, and it hides the real failure (bad connection, syntax error, etc.) with no logging. If you do catch here, catch the driver's specific exception type and log it.

**4. Minor points:**
- `id` shadows the Python builtin — prefer `user_id`.
- The `data = []` / append loop is just a copy; `return list(result)` does the same thing.
- `SELECT *` couples callers to the table schema — selecting explicit columns is more robust to migrations.
- A type hint and docstring would help: does this return a list of rows for a single-user lookup? If `id` is unique, maybe the function should return one row (or `None`) rather than a list.

A cleaned-up version:

```python
def get_user_data(user_id: int) -> list:
    """Return all rows for the given user id."""
    result = db.query("SELECT * FROM users WHERE id = %s", (user_id,))
    return list(result)
```

The injection fix is the must-do; the rest is polish. Happy to look at the calling code if you want to decide between raising vs. returning `[]` on failure.

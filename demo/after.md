Four problems, one of them severe.

**SQL injection.** The query concatenates `id` into the SQL string. Any caller-controlled value can rewrite the query. Use a parameterized query: `db.query("SELECT * FROM users WHERE id = %s", (id,))`.

**The except clause hides every failure, then crashes anyway.** Bare `except` catches everything — connection errors, syntax errors, even `KeyboardInterrupt` — and sets `result = None`. The loop then raises `TypeError: 'NoneType' object is not iterable`, far from the real cause. Catch the specific database exception, and either handle it or let it propagate.

**The loop copies the result one row at a time.** `return list(result)` does the same work in one line.

**`id` shadows the builtin.** Rename it `user_id`, which also documents the parameter. `SELECT *` deserves the same treatment: name the columns you need, so schema changes surface here instead of in callers.

Rewritten:

```python
def get_user_data(user_id):
    result = db.query("SELECT id, name, email FROM users WHERE id = %s", (user_id,))
    return list(result)
```

Let database errors propagate unless this function can genuinely recover — and returning an empty list is not recovery; it makes a dead database look like a missing user.

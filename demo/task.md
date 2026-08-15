# Review task

Review this function and write feedback for its author.

```python
def get_user_data(id):
    try:
        result = db.query("SELECT * FROM users WHERE id = " + str(id))
    except:
        result = None
    data = []
    for r in result:
        data.append(r)
    return data
```

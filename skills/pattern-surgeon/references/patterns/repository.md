# Repository

## Smell signature
Raw ORM/SQL/`fetch` data access lives inline inside services, UI, or business
logic; query strings are interleaved with domain rules. Example:
```ts
async function activate(id: string) {
  const row = await db.query("SELECT * FROM users WHERE id = $1", [id]);
  if (!row) throw new Error("not found");
  if (row.status === "banned") throw new Error("banned");
  await db.query("UPDATE users SET status='active' WHERE id=$1", [id]);
}
```

## When NOT to apply
- Data access is already behind a data-access layer.
- A one-off script or migration with no domain logic.
- A trivial single query with no logic coupling and no reuse.

## Transform recipe
1. Define `interface UserRepository` in domain terms (no SQL, no ORM types).
2. Move all data access into a concrete implementation of it.
3. Inject the repository into services; services hold only rules.

```python
# TODO(phase-1): python example
```
```java
// TODO(phase-2): java example
```
```csharp
// TODO(phase-3): csharp example
```
```php
// TODO(phase-4): php example
```

## Framework idiom
- Spring Boot: extend Spring Data `JpaRepository<T,ID>`; do not hand-roll a DAO.
- .NET Core: use EF Core `DbContext`/`DbSet<T>` (optionally a repository over it).
- Laravel: use an Eloquent model or a repository bound in a ServiceProvider; do not bypass Eloquent.

## Before / After
Before: `await db.query("SELECT ...")` inside the service.
After:
```ts
interface User { id: string; status: string }
interface UserRepository {
  findById(id: string): Promise<User | null>;
  save(u: User): Promise<void>;
}

async function activate(id: string, users: UserRepository) {
  const u = await users.findById(id);
  if (!u) throw new Error("not found");
  if (u.status === "banned") throw new Error("banned");
  await users.save({ ...u, status: "active" });
}
```

## Verification focus
Same data returned and persisted; identical query results for existing call
paths (round-trip a known id and compare).

## Pitfalls
Don't leak ORM/row types through the interface — keep it domain-shaped, or the
abstraction becomes useless when the ORM changes.

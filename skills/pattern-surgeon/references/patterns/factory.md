# Factory

## Smell signature
`new X()` of one family is scattered across ≥3 places and construction needs a
conditional or config to pick the concrete type. Example:
```ts
// repeated in 3+ modules
const conn = cfg.driver === "pg"
  ? new PgConn(cfg.url)
  : new MySQLConn(cfg.url);
```

## When NOT to apply
- Trivial single construction (`new Foo()` with no branching).
- A DI container / composition root already owns construction.
- Only one concrete type exists and it is stable (YAGNI).

## Transform recipe
1. Define the product interface, e.g. `interface Conn { query(sql: string): Promise<Row[]> }`.
2. Extract a `createConn(cfg): Conn` factory function (or class).
3. Move the conditional construction into the factory only.
4. Callers depend on `createConn` + `Conn`, never on concretes.

## Before / After
Before: `new MySQLConn()` / `new PgConn()` chosen inline in many modules.
After:
```ts
interface Conn { query(sql: string): Promise<Row[]> }

export function createConn(cfg: DbConfig): Conn {
  switch (cfg.driver) {
    case "pg": return new PgConn(cfg.url);
    case "mysql": return new MySQLConn(cfg.url);
    default: throw new Error(`unknown driver ${cfg.driver}`);
  }
}

// callers:
const conn = createConn(cfg);
```

## Verification focus
Same concrete type chosen for each input config; no behavior change in the
constructed object's methods.

## Pitfalls
Don't add a factory for a single stable constructor (YAGNI). Don't let the
factory leak concrete types in its return signature.

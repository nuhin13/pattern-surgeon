# Dependency Injection

## Smell signature
A class does `new Collaborator()` internally, reads hard-coded
singletons/globals, or hidden dependencies make it untestable. Example:
```ts
class OrderService {
  private db = new Db(process.env.DB_URL!);   // hidden, untestable
  private clock = Date;                        // global
  place(o: Order) { /* uses this.db, this.clock */ }
}
```

## When NOT to apply
- Pure functions and value objects (no collaborators).
- Leaf utilities with no I/O or external dependencies.
- Plain config constants.

## Transform recipe
1. Lift each collaborator to a constructor parameter, typed by an interface.
2. Construct and wire the real implementations at the composition root.
3. Pass test doubles in tests via the same constructor.

## Before / After
Before: `class OrderService { db = new Db() }`.
After:
```ts
interface DbPort { insert(o: Order): Promise<void> }
interface Clock { now(): Date }

class OrderService {
  constructor(private db: DbPort, private clock: Clock) {}
  place(o: Order) { return this.db.insert({ ...o, at: this.clock.now() }); }
}

// composition root:
const svc = new OrderService(new Db(process.env.DB_URL!), { now: () => new Date() });

// test:
const svc = new OrderService(fakeDb, { now: () => new Date("2026-01-01") });
```

## Verification focus
Identical runtime wiring in the production path; behavior unchanged; tests can
now inject fakes for previously-hidden deps.

## Pitfalls
Don't introduce a DI framework for a small object graph. Prefer constructor
injection over a service locator (which just hides the dependency again).

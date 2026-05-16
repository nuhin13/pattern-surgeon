# Observer

## Smell signature
Manual cross-object notification chains, callback fan-out, or polling a flag to
detect state change; adding a new reaction means editing the producer. Example:
```ts
class Order {
  complete() {
    this.status = "done";
    emailService.send(this);   // producer knows every consumer
    analytics.track(this);
    inventory.release(this);
  }
}
```

## When NOT to apply
- There is a single listener (just call it directly).
- The framework is already reactive (RxJS, signals, `EventTarget`).
- A synchronous one-shot callback is sufficient.

## Transform recipe
1. Introduce a subject: `subscribe(listener)` and `notify(event)`.
2. Producer emits a domain event instead of calling consumers.
3. Consumers register themselves; producer no longer imports them.

## Before / After
Before: `Order.complete()` calls `emailService` / `analytics` / `inventory`.
After:
```ts
type Listener<E> = (e: E) => void;

class Subject<E> {
  private ls: Listener<E>[] = [];
  subscribe(l: Listener<E>): () => void {
    this.ls.push(l);
    return () => { this.ls = this.ls.filter((x) => x !== l); };
  }
  notify(e: E) { for (const l of this.ls) l(e); }
}

const orderCompleted = new Subject<Order>();
orderCompleted.subscribe((o) => emailService.send(o));
orderCompleted.subscribe((o) => analytics.track(o));

class Order {
  complete() { this.status = "done"; orderCompleted.notify(this); }
}
```

## Verification focus
Every previously-notified party still reacts, in the same order if order
mattered.

## Pitfalls
Beware listener leaks — keep and call the unsubscribe handle. Don't introduce
an async event bus where a direct call suffices.

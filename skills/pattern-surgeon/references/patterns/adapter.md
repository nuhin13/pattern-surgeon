# Adapter

## Smell signature
A 3rd-party library API is called directly across many modules, its signature
mismatches the domain, and swapping the library would touch every call site.
Example:
```ts
// in checkout.ts, refund.ts, subscription.ts ...
await stripe.charges.create({ amount, currency, source });
```

## When NOT to apply
- The library is used in exactly one place.
- The library API already matches the domain shape closely.
- A thin pass-through wrapper would add indirection but no value.

## Transform recipe
1. Define a domain `Port` interface expressing what the app needs, in app terms.
2. Implement one `XAdapter implements Port` that wraps the library calls.
3. Convert library shapes ↔ domain shapes inside the adapter only.
4. Callers depend on `Port`; the adapter is wired at the composition root.

## Before / After
Before: `stripe.charges.create(...)` sprinkled everywhere.
After:
```ts
interface PaymentPort {
  charge(input: { cents: number; currency: string; token: string }): Promise<{ id: string }>;
}

class StripeAdapter implements PaymentPort {
  constructor(private stripe: Stripe) {}
  async charge(i: { cents: number; currency: string; token: string }) {
    const c = await this.stripe.charges.create({
      amount: i.cents, currency: i.currency, source: i.token,
    });
    return { id: c.id };
  }
}

// callers:
await payments.charge({ cents, currency, token });
```

## Verification focus
Same external calls and results for existing inputs; field mapping preserved.

## Pitfalls
Don't mirror the library 1:1 — the port models the domain, not the vendor.
A port that just renames vendor methods provides no decoupling.

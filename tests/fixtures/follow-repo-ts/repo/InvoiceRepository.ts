// Non-conforming: lives in repo/ but ignores the established Repository
// convention (no `*Repository` class, no `byId`, raw fetch in a bare fn).
export async function getInvoice(id: string): Promise<any> {
  const r = await fetch(`/api/invoices/${id}`);
  return r.ok ? await r.json() : null;
}

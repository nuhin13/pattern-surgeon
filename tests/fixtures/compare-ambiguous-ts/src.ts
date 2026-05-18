// Genuine dual smell.
// Strategy: the SAME `switch (kind)` on a string type recurs at 3 call sites,
//   branches differing only by which notifier algorithm runs.
// Factory: conditional `new <X>Notifier()` construction of one family is
//   scattered across those same 3 places (≥3 → meets Factory threshold).
interface Notifier { send(msg: string): void }

class EmailNotifier implements Notifier { send(m: string) { console.log("email", m); } }
class SmsNotifier implements Notifier { send(m: string) { console.log("sms", m); } }
class PushNotifier implements Notifier { send(m: string) { console.log("push", m); } }

export function notifyWelcome(kind: string, user: string): void {
  let n: Notifier;
  switch (kind) {
    case "email": n = new EmailNotifier(); break;
    case "sms":   n = new SmsNotifier();   break;
    case "push":  n = new PushNotifier();  break;
    default: throw new Error("unknown kind");
  }
  n.send(`welcome ${user}`);
}

export function notifyReceipt(kind: string, amount: number): void {
  let n: Notifier;
  switch (kind) {
    case "email": n = new EmailNotifier(); break;
    case "sms":   n = new SmsNotifier();   break;
    case "push":  n = new PushNotifier();  break;
    default: throw new Error("unknown kind");
  }
  n.send(`receipt ${amount}`);
}

export function notifyAlert(kind: string, code: string): void {
  let n: Notifier;
  switch (kind) {
    case "email": n = new EmailNotifier(); break;
    case "sms":   n = new SmsNotifier();   break;
    case "push":  n = new PushNotifier();  break;
    default: throw new Error("unknown kind");
  }
  n.send(`alert ${code}`);
}

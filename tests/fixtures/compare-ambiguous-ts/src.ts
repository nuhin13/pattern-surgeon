// Dual smell: switch on `kind` (Strategy candidate) AND constructs a
// different collaborator per branch (Factory candidate). Used across 3 sites.
interface Notifier { send(msg: string): void }

class EmailNotifier implements Notifier { send(m: string) { console.log("email", m); } }
class SmsNotifier implements Notifier { send(m: string) { console.log("sms", m); } }
class PushNotifier implements Notifier { send(m: string) { console.log("push", m); } }

export function notify(kind: string, msg: string): void {
  let n: Notifier;
  switch (kind) {
    case "email": n = new EmailNotifier(); break;
    case "sms":   n = new SmsNotifier();   break;
    case "push":  n = new PushNotifier();  break;
    default: throw new Error("unknown kind");
  }
  n.send(msg);
}

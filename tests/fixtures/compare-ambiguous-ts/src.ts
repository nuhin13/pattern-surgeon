// Dual smell: a 3-case switch on `kind` (Strategy candidate) that also
// constructs a different collaborator per branch (Factory candidate). In a
// real codebase `notify` is invoked from multiple call sites; the fixture
// isolates the scope under review.
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

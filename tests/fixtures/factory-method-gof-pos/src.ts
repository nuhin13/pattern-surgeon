// SMELL: the product type (Conn variant) is determined by which Creator
// subclass is used — classic GoF Factory Method. Each ConcreteCreator
// hard-wires one ConcreteProduct; callers depend on ConnCreator + Conn only.

export interface Conn {
  kind: string;
  query(sql: string): string[];
}

export class PgConn implements Conn {
  kind = "pg";
  constructor(private url: string) {}
  query(sql: string): string[] { return [`pg:${sql}@${this.url}`]; }
}

export class MySQLConn implements Conn {
  kind = "mysql";
  constructor(private url: string) {}
  query(sql: string): string[] { return [`mysql:${sql}@${this.url}`]; }
}

// GoF Creator — declares the factory method; subclasses override it
export abstract class ConnCreator {
  protected url: string;
  constructor(url: string) { this.url = url; }

  abstract createConn(): Conn;          // factory method

  connect(): Conn {
    return this.createConn();           // Creator delegates to the factory method
  }
}

// GoF ConcreteCreator — fixes the product to PgConn
export class PgCreator extends ConnCreator {
  createConn(): Conn { return new PgConn(this.url); }
}

// GoF ConcreteCreator — fixes the product to MySQLConn
export class MySQLCreator extends ConnCreator {
  createConn(): Conn { return new MySQLConn(this.url); }
}

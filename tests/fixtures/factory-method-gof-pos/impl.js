"use strict";
// Plain-JS implementation of the GoF Factory Method fixture (no build step needed).

class PgConn {
  constructor(url) { this.kind = "pg"; this._url = url; }
  query(sql) { return [`pg:${sql}@${this._url}`]; }
}

class MySQLConn {
  constructor(url) { this.kind = "mysql"; this._url = url; }
  query(sql) { return [`mysql:${sql}@${this._url}`]; }
}

class ConnCreator {
  constructor(url) { this.url = url; }
  createConn() { throw new Error("abstract"); }
  connect() { return this.createConn(); }
}

class PgCreator extends ConnCreator {
  createConn() { return new PgConn(this.url); }
}

class MySQLCreator extends ConnCreator {
  createConn() { return new MySQLConn(this.url); }
}

module.exports = { PgCreator, MySQLCreator, ConnCreator };

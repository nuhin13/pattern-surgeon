"use strict";
// Plain-Node test — no test framework needed.
// Validates that the GoF Factory Method fixture produces the correct products.

const assert = require("node:assert/strict");

// Load compiled output if available; fall back to impl stub for greenfield mode
let impl;
try {
  impl = require("./impl.js");
} catch {
  // impl.js not present — this test intentionally fails in greenfield mode
  console.error("impl.js not found");
  process.exit(1);
}

const { PgCreator, MySQLCreator } = impl;

// PgCreator always produces a pg Conn
const pgConn = new PgCreator("localhost:5432").connect();
assert.equal(pgConn.kind, "pg", "PgCreator must produce a PgConn");
assert.ok(pgConn.query("SELECT 1")[0].startsWith("pg:"), "PgConn query output must be prefixed with pg:");

// MySQLCreator always produces a mysql Conn
const myConn = new MySQLCreator("localhost:3306").connect();
assert.equal(myConn.kind, "mysql", "MySQLCreator must produce a MySQLConn");
assert.ok(myConn.query("SELECT 1")[0].startsWith("mysql:"), "MySQLConn query output must be prefixed with mysql:");

// Callers depend on ConnCreator interface, not concrete classes
assert.ok(pgConn !== myConn, "Two creators produce distinct instances");

console.log("factory-method-gof-pos: all assertions passed");

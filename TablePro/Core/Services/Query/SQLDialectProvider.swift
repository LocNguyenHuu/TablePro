//
//  SQLDialectProvider.swift
//  TablePro
//
//  Created by OpenCode on 1/17/26.
//

import Foundation
import TableProPluginKit

// MARK: - Plugin Dialect Adapter

struct PluginDialectAdapter: SQLDialectProvider {
    let identifierQuote: String
    let keywords: Set<String>
    let functions: Set<String>
    let dataTypes: Set<String>

    init(descriptor: SQLDialectDescriptor) {
        self.identifierQuote = descriptor.identifierQuote
        self.keywords = descriptor.keywords
        self.functions = descriptor.functions
        self.dataTypes = descriptor.dataTypes
    }
}

// MARK: - Empty Dialect

private struct EmptyDialect: SQLDialectProvider {
    let identifierQuote = "\""
    let keywords: Set<String> = []
    let functions: Set<String> = []
    let dataTypes: Set<String> = []
}

// MARK: - Cassandra/ScyllaDB Dialect

struct CassandraDialect: SQLDialectProvider {
    let identifierQuote = "\""

    let keywords: Set<String> = [
        // Core DML keywords
        "SELECT", "FROM", "WHERE", "AND", "OR", "NOT", "IN", "AS",
        "ORDER", "BY", "LIMIT",
        "INSERT", "INTO", "VALUES", "UPDATE", "SET", "DELETE",

        // DDL keywords
        "CREATE", "ALTER", "DROP", "TABLE", "INDEX", "VIEW",
        "PRIMARY", "KEY", "ADD", "COLUMN", "RENAME",

        // Data attributes
        "NULL", "IS", "ASC", "DESC", "DISTINCT",

        // Control flow
        "CASE", "WHEN", "THEN", "ELSE", "END",

        // Cassandra-specific
        "KEYSPACE", "USE", "TRUNCATE", "BATCH", "GRANT", "REVOKE",
        "CLUSTERING", "PARTITION", "TTL", "WRITETIME",
        "ALLOW FILTERING", "IF NOT EXISTS", "IF EXISTS",
        "USING TIMESTAMP", "USING TTL",
        "MATERIALIZED VIEW", "CONTAINS", "FROZEN", "COUNTER", "TOKEN"
    ]

    let functions: Set<String> = [
        // Aggregate
        "COUNT", "SUM", "AVG", "MAX", "MIN",

        // Cassandra-specific
        "NOW", "UUID", "TOTIMESTAMP", "TOKEN", "TTL", "WRITETIME",
        "MINTIMEUUID", "MAXTIMEUUID", "TODATE", "TOUNIXTIMESTAMP",

        // Conversion
        "CAST"
    ]

    let dataTypes: Set<String> = [
        // String types
        "TEXT", "VARCHAR", "ASCII",

        // Integer types
        "INT", "BIGINT", "SMALLINT", "TINYINT", "VARINT",

        // Decimal types
        "FLOAT", "DOUBLE", "DECIMAL",

        // Other types
        "BOOLEAN", "UUID", "TIMEUUID",
        "TIMESTAMP", "DATE", "TIME",
        "BLOB", "INET", "COUNTER",

        // Collection types
        "LIST", "SET", "MAP", "TUPLE", "FROZEN"
    ]
}

// MARK: - Dialect Factory

struct SQLDialectFactory {
    @MainActor
    static func createDialect(for databaseType: DatabaseType) -> SQLDialectProvider {
        if let descriptor = PluginManager.shared.sqlDialect(for: databaseType) {
            return PluginDialectAdapter(descriptor: descriptor)
        }
        return EmptyDialect()
    }
}

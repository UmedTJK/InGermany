//
//  NetworkMetrics.swift
//  InGermany
//
//  Created by SUM TJK on 22.02.26.
//

import Foundation

/// Collects network-related counters for observability.
///
/// - Note: This is intentionally lightweight (counters only). Latency metrics can be added later if needed.
protocol NetworkMetricsCollecting: Sendable {
    /// Increment a counter for a specific metric and file key.
    func increment(_ metric: NetworkMetric, file: String) async
}

/// Counter metrics emitted by `NetworkService`.
///
/// `file` is typically a JSON filename (e.g. `articles.json`). For global operations (e.g. cache clear)
/// `NetworkService` may pass `"*"`.
enum NetworkMetric: String, Sendable {
    // Offline-first source hits
    case load_bundle_hit
    case load_filecache_hit

    // Network load lifecycle
    case load_network_start
    case load_network_success
    case load_network_failure

    // Dedupe
    case load_network_dedupe_hit

    // Retry
    case retry_scheduled
    case retry_exhausted

    // Cancellation
    case cancelled

    // Background refresh
    case refresh_scheduled
    case refresh_dedupe_hit
    case refresh_success
    case refresh_failure

    // Cache
    case cache_save_failure
    case cache_clear_success
    case cache_clear_failure
}

/// No-op collector used by default to avoid optional handling in production code.
struct NoopNetworkMetricsCollector: NetworkMetricsCollecting {
    func increment(_ metric: NetworkMetric, file: String) async { }
}

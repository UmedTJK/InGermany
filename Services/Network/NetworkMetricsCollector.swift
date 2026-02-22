//  NetworkMetricsCollector.swift
//  InGermany
//
//  Created by UmedGPT on 2026-02-22.
//

import Foundation

/// In-memory actor-based collector for network counters used by NetworkService.
/// Lightweight: stores integer counters per (metric, file) pair and exposes snapshots.
actor NetworkMetricsCollector: NetworkMetricsCollecting {

    // Key is combination metric.rawValue + "::" + file
    private var counters: [String: Int] = [:]

    private func key(for metric: NetworkMetric, file: String) -> String {
        return metric.rawValue + "::" + file
    }

    /// Increment counter for (metric, file). If `file`=="*" treat as global.
    func increment(_ metric: NetworkMetric, file: String) async {
        let k = key(for: metric, file: file)
        let prev = counters[k] ?? 0
        counters[k] = prev + 1
    }

    /// Produce a structured snapshot of collected counters and optionally reset.
    nonisolated struct Snapshot: Sendable {
        public let timestamp: Date
        public let counters: [NetworkMetric: [String: Int]]

        public func prettyDescription(maxEntries: Int = 200) -> String {
            var lines: [String] = []
            lines.append("NetworkMetrics snapshot at: \(timestamp)")
            for metric in counters.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
                lines.append("")
                lines.append("- \(metric.rawValue):")
                let files = counters[metric] ?? [:]
                let sorted = files.sorted { $0.key < $1.key }
                var count = 0
                for (file, value) in sorted {
                    lines.append("    \(file): \(value)")
                    count += 1
                    if count >= maxEntries { break }
                }
            }
            return lines.joined(separator: "\n")
        }
    }

    /// Returns snapshot of counters without clearing.
    func snapshot() -> Snapshot {
        var byMetric: [NetworkMetric: [String: Int]] = [:]

        for (k, v) in counters {
            guard let delimiterRange = k.range(of: "::") else { continue }
            let metricRaw = String(k[..<delimiterRange.lowerBound])
            let file = String(k[delimiterRange.upperBound...])

            guard let metric = NetworkMetric(rawValue: metricRaw) else { continue }
            var bucket = byMetric[metric] ?? [:]
            bucket[file] = v
            byMetric[metric] = bucket
        }

        return Snapshot(timestamp: Date(), counters: byMetric)
    }

    /// Returns snapshot and clears all collected counters.
    func snapshotAndReset() -> Snapshot {
        let snap = snapshot()
        counters.removeAll()
        return snap
    }
}

//
//  Localization.swift
//  10000hours
//
//  Created by GitHub Copilot on 3/31/26.
//

import Foundation

enum AppLocalization {
    static func localized(_ key: String, _ arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, locale: Locale.current, arguments: arguments)
    }

    static func duration(totalMinutes: Int) -> String {
        let clampedMinutes = max(0, totalMinutes)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = clampedMinutes >= 60 ? [.hour, .minute] : [.minute]
        formatter.zeroFormattingBehavior = .dropAll

        if let formatted = formatter.string(from: TimeInterval(clampedMinutes * 60)) {
            return formatted
        }

        return localized("duration.minutes_fallback", clampedMinutes)
    }

    static func duration(hours: Int, minutes: Int) -> String {
        duration(totalMinutes: (hours * 60) + minutes)
    }

    static func hourValue(_ hours: Int) -> String {
        localized("duration.hours_value", hours)
    }

    static func minuteValue(_ minutes: Int) -> String {
        localized("duration.minutes_value", minutes)
    }

    static func itemToday(hours: Int, minutes: Int) -> String {
        localized("item.today", duration(hours: hours, minutes: minutes))
    }

    static func itemTotalProgress(totalMinutes: Int) -> String {
        localized("item.total_progress", duration(totalMinutes: totalMinutes))
    }

    static func logAdded(minutes: Int) -> String {
        localized("log.added_duration", duration(totalMinutes: minutes))
    }

    static func logListTitle(itemName: String, count: Int) -> String {
        localized("log_list.title", itemName, count)
    }

    static func logDeleteMessage(minutes: Int) -> String {
        localized("log_list.delete.message", duration(totalMinutes: minutes))
    }

    static func summaryHours(minutes: Int) -> String {
        localized("summary.hours", Double(minutes) / 60.0)
    }
}
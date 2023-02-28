//
//  OpenAppLockScreenWidget.swift
//  WidgetsExtension
//
//  Created by kimhyungyu on 2023/02/05.
//

import WidgetKit
import SwiftUI

struct OpenAppLockScreenProvider: TimelineProvider {
    func placeholder(in context: Context) -> OpenAppLockScreenEntry {
        OpenAppLockScreenEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (OpenAppLockScreenEntry) -> Void) {
        let entry = OpenAppLockScreenEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [OpenAppLockScreenEntry] = []
        
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = OpenAppLockScreenEntry(date: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct OpenAppLockScreenEntry: TimelineEntry {
    let date: Date
}

struct OpenAppLockScreenEntryView: View {
    var entry: OpenAppLockScreenProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Image("widgetLogoWhite")
                    .resizable()
            }
        default:
            Image("widgetLogoWhite")
        }
    }
}

struct OpenAppLockScreenWidget: Widget {
    let kind: String = "OpenAppLockScreen"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: OpenAppLockScreenProvider()) { entry in
            OpenAppLockScreenEntryView(entry: entry)
        }
        .configurationDisplayName("나다 NADA")
        .description("나다 NADA를 실행합니다.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct OpenAppLockScreenWidget_Previews: PreviewProvider {
    static var previews: some View {
        OpenAppLockScreenEntryView(entry: OpenAppLockScreenEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
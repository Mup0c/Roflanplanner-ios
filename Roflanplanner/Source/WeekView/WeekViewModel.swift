import Foundation
import JZCalendarWeekView

class WeekViewModel: NSObject {

    private let firstDate = Date().add(component: .hour, value: 1)
    private let secondDate = Date().add(component: .day, value: 1)
    private let thirdDate = Date().add(component: .day, value: 2)

    lazy var events = [WeekEvent(id: "0", title: "One", startDate: firstDate, endDate: firstDate.add(component: .hour, value: 1), details: "Melbourne", isAllDay: false),
                       WeekEvent(id: "1", title: "Two", startDate: secondDate, endDate: secondDate.add(component: .hour, value: 4), details: "Sydney", isAllDay: false),
                       WeekEvent(id: "2", title: "Three", startDate: thirdDate, endDate: thirdDate.add(component: .hour, value: 2), details: "Tasmania", isAllDay: false),
                       WeekEvent(id: "3", title: "Four", startDate: thirdDate, endDate: thirdDate.add(component: .day, value: 4), details: "Canberra ыоа ыдлваоыопд ло ыоа ыдлваоыопд лоыоа ыдлваоыопд лоыоа ыдлваоыопд лоыоа ыдлваоыопд ло лорем ипсум да да \n кек", isAllDay: false)]

    lazy var eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
    
    func initEvents(from model: CalendarModel) {
        self.events = []
        for (date , instances) in model.instanes {
            for instance in instances {
                let pattern = model.patterns[instance.event_id!]!
                //Prevent showing line instead of cell in week view cause of too short event duration
                let endDate = CalendarModel.convertToDate(max(pattern.duration!, 1800000) + instance.started_at!)
                events.append(WeekEvent(
                    id: String(date) + String(instance.event_id!), // "yyyyMMdd<Event.id>"
                    title: model.events[instance.event_id!]!.name!,
                    startDate: CalendarModel.convertToDate(instance.started_at!),
                    endDate: endDate,
                    details: model.events[instance.event_id!]!.details!,
                    isAllDay: false)
                )
            }
        }
        self.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: self.events)
    }

}

import JZCalendarWeekView

class WeekEvent: JZAllDayEvent {

    var details: String
    var title: String

    init(id: String, title: String, startDate: Date, endDate: Date, details: String, isAllDay: Bool) {
        self.details = details
        self.title = title

        // If you want to have you custom uid, you can set the parent class's id with your uid or UUID().uuidString (In this case, we just use the base class id)
        super.init(id: id, startDate: startDate, endDate: endDate, isAllDay: isAllDay)
    }

    override func copy(with zone: NSZone?) -> Any {
        return WeekEvent(id: id, title: title, startDate: startDate, endDate: endDate, details: details, isAllDay: isAllDay)
    }
}

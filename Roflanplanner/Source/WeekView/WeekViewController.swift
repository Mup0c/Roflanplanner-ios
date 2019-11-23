import UIKit
import JZCalendarWeekView

class WeekViewController: UIViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var calendarWeekView: JZLongPressWeekView!
    let viewModel = WeekViewModel()
    
    
    @IBAction func backClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    var kek = "BEFORE"

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(kek)
        setupCalendarView()
        updateNaviBarTitle()
    }

    private func setupCalendarView() {
        calendarWeekView.baseDelegate = self

        calendarWeekView.setupCalendar(numOfDays: 7, setDate: Date(), allEvents: viewModel.eventsByDate, scrollType: .sectionScroll, firstDayOfWeek: .Monday, currentTimelineType: .page, visibleTime: Date())
    

        // LongPress delegate, datasorce and type setup
        calendarWeekView.longPressDelegate = self
        calendarWeekView.longPressDataSource = self
        // calendarWeekView.longPressTypes = [.addNew]                     //TODO: Implement creating events

        // Optional
        calendarWeekView.addNewDurationMins = 120
        calendarWeekView.moveTimeMinInterval = 15
    }

}

extension WeekViewController: JZBaseViewDelegate {
    func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date) {
        updateNaviBarTitle()
    }
}

// LongPress core
extension WeekViewController: JZLongPressViewDelegate, JZLongPressViewDataSource {

    func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {
        let newEvent = WeekEvent(id: UUID().uuidString, title: "Unnamed", startDate: startDate, endDate: startDate.add(component: .hour, value: weekView.addNewDurationMins/60),
                             details: "", isAllDay: false)

        if viewModel.eventsByDate[startDate.startOfDay] == nil {
            viewModel.eventsByDate[startDate.startOfDay] = [WeekEvent]()
        }
        viewModel.events.append(newEvent)
        viewModel.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: viewModel.events)
        weekView.forceReload(reloadEvents: viewModel.eventsByDate)
    }

    func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView {
        if let view = UINib(nibName: WeekEventCell.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? WeekEventCell {
            view.titleLabel.text = "Unnamed"
            return view
        }
        return UIView()
    }

    private func updateNaviBarTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM YYYY"
        navItem.title = dateFormatter.string(from: calendarWeekView.initDate.add(component: .day, value: calendarWeekView.numOfDays))
    }
}

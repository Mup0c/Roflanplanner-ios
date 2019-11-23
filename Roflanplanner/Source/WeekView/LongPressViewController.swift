import UIKit
import JZCalendarWeekView

class LongPressViewController: UIViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var calendarWeekView: JZLongPressWeekView!
    let viewModel = AllDayViewModel()

    @IBAction func backClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBasic()
        setupCalendarView()
        setupNaviBar()
    }

    // Support device orientation change
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendarWeekView)
    }

    private func setupCalendarView() {
        calendarWeekView.baseDelegate = self

        calendarWeekView.setupCalendar(numOfDays: 3,
                                       setDate: Date(),
                                       allEvents: viewModel.eventsByDate,
                                       scrollType: .pageScroll,
                                       scrollableRange: (nil, nil))
    

        // LongPress delegate, datasorce and type setup
        calendarWeekView.longPressDelegate = self
        calendarWeekView.longPressDataSource = self
        calendarWeekView.longPressTypes = [.addNew, .move]

        // Optional
        calendarWeekView.addNewDurationMins = 120
        calendarWeekView.moveTimeMinInterval = 15
    }

}

extension LongPressViewController: JZBaseViewDelegate {
    func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date) {
        updateNaviBarTitle()
    }
}

// LongPress core
extension LongPressViewController: JZLongPressViewDelegate, JZLongPressViewDataSource {

    func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {
        let newEvent = AllDayEvent(id: UUID().uuidString, title: "New Event", startDate: startDate, endDate: startDate.add(component: .hour, value: weekView.addNewDurationMins/60),
                             location: "Melbourne", isAllDay: false)

        if viewModel.eventsByDate[startDate.startOfDay] == nil {
            viewModel.eventsByDate[startDate.startOfDay] = [AllDayEvent]()
        }
        viewModel.events.append(newEvent)
        viewModel.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: viewModel.events)
        weekView.forceReload(reloadEvents: viewModel.eventsByDate)
    }

    func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
        guard let event = editingEvent as? AllDayEvent else { return }
        let duration = Calendar.current.dateComponents([.minute], from: event.startDate, to: event.endDate).minute!
        let selectedIndex = viewModel.events.firstIndex(where: { $0.id == event.id })!
        viewModel.events[selectedIndex].startDate = startDate
        viewModel.events[selectedIndex].endDate = startDate.add(component: .minute, value: duration)

        viewModel.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: viewModel.events)
        weekView.forceReload(reloadEvents: viewModel.eventsByDate)
    }

    func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView {
        if let view = UINib(nibName: EventCell.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? EventCell {
            view.titleLabel.text = "New Event"
            return view
        }
        return UIView()
    }

    func setupBasic() {
        // Add this to fix lower than iOS11 problems
        //  self.automaticallyAdjustsScrollViewInsets = false
    }

    private func setupNaviBar() {
        updateNaviBarTitle()
        let optionsButton = UIButton(type: .system)
        optionsButton.setTitle("D", for: .normal)
        optionsButton.frame.size = CGSize(width: 25, height: 25)
        if #available(iOS 11.0, *) {
            optionsButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
            optionsButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        }
        navItem.rightBarButtonItem = UIBarButtonItem(customView: optionsButton)
    }

    private func updateNaviBarTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM YYYY"
        navItem.title = dateFormatter.string(from: calendarWeekView.initDate.add(component: .day, value: calendarWeekView.numOfDays))
    }
}

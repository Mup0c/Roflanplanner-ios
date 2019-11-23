import UIKit
import JZCalendarWeekView

/// All-Day & Long Press
class WeekView: JZLongPressWeekView {

    override func registerViewClasses() {
        super.registerViewClasses()

        self.collectionView.register(UINib(nibName: WeekEventCell.className, bundle: nil), forCellWithReuseIdentifier: WeekEventCell.className)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeekEventCell.className, for: indexPath) as? WeekEventCell,
            let event = getCurrentEvent(with: indexPath) as? WeekEvent {
            cell.configureCell(event: event)
            return cell
        }
        preconditionFailure("LongPressEventCell and WeekEvent should be casted")
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == JZSupplementaryViewKinds.allDayHeader {
            guard let alldayHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as? JZAllDayHeader else {
                preconditionFailure("SupplementaryView should be JZAllDayHeader")
            }
            let date = flowLayout.dateForColumnHeader(at: indexPath)
            let events = allDayEventsBySection[date]
            let views = getAllDayHeaderViews(allDayEvents: events as? [WeekEvent] ?? [])
            alldayHeader.updateView(views: views)
            return alldayHeader
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }

    private func getAllDayHeaderViews(allDayEvents: [WeekEvent]) -> [UIView] {
        var allDayViews = [UIView]()
        for event in allDayEvents {
            if let view = UINib(nibName: WeekEventCell.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? WeekEventCell {
                view.configureCell(event: event, isAllDay: true)
                allDayViews.append(view)
            }
        }
        return allDayViews
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedEvent = getCurrentEvent(with: indexPath) as? WeekEvent {
            ToastUtil.toastMessageInTheMiddle(message: selectedEvent.title)
        }
    }
}

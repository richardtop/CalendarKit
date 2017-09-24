import UIKit

protocol DatePickerControllerDelegate: class {
  func datePicker(controller: DatePickerController, didSelect date: Date?)
}

class DatePickerController: UIViewController {

  weak var delegate: DatePickerControllerDelegate?

  var date: Date {
    get {
      return datePicker.date
    }
    set(value) {
      datePicker.setDate(value, animated: false)
    }
  }

  lazy var datePicker: UIDatePicker = {
    let v = UIDatePicker()
    v.datePickerMode = .date
    return v
  }()

  override func loadView() {
    view = datePicker
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                        target: self,
                                                        action: #selector(DatePickerController.doneButtonDidTap))

    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                       target: self,
                                                       action: #selector(DatePickerController.cancelButtonDidTap))
  }

  @objc func doneButtonDidTap() {
    delegate?.datePicker(controller: self, didSelect: date)
  }

  @objc func cancelButtonDidTap() {
    delegate?.datePicker(controller: self, didSelect: nil)
  }
}

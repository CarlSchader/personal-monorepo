{ self, ... }:
{
  lib.recurring-payments-systemd-units = [
    # (self.lib.make-echo-remind-service { tag = "test-reminder"; message = "testing 123"; calendar-rules = ["*-*-* *:*:30"]; })
    (self.lib.make-echo-remind-service { tag = "auto-loan-payment"; message = "Auto loan payment today. $773"; calendar-rules = ["*-*-1 00:00:00"]; })
    (self.lib.make-echo-remind-service { tag = "student-loans-payment"; message = "Student loans payment today. $590"; calendar-rules = ["*-*-4 00:00:00"]; })
    (self.lib.make-echo-remind-service { tag = "electricity-payment"; message = "Electricity payment today."; calendar-rules = ["*-*-19 00:00:00"]; })
    (self.lib.make-echo-remind-service { tag = "rent-payment"; message = "Rent payment today. $1667"; calendar-rules = ["*-*-1 00:00:00"]; })
    (self.lib.make-echo-remind-service { tag = "auto-insurance-payment-1"; message = "Auto insurance payment today. $1331.20"; calendar-rules = ["*-6-1 00:00:00"]; })
    (self.lib.make-echo-remind-service { tag = "auto-insurance-payment-2"; message = "Auto insurance payment today. $1331.20"; calendar-rules = ["*-12-1 00:00:00"]; })
    (self.lib.make-echo-remind-service { tag = "saronic-salary-income-1"; message = "Saronic paycheck close to today. $4700.71"; calendar-rules = ["*-*-15 00:00:00"]; })
    (self.lib.make-echo-remind-service { tag = "saronic-salary-income-2"; message = "Saronic paycheck close to today. $4700.71"; calendar-rules = ["*-*-28 00:00:00"]; })
    (self.lib.make-echo-remind-service { tag = "internet-payment"; message = "Internet payment today. $30.30"; calendar-rules = ["*-*-15 00:00:00"]; })
  ];
}

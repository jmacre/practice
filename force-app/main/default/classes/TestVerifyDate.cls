@isTest
private class TestVerifyDate {

    @isTest
    static void CheckDatesPastWithin30DaysTest() {
        VerifyDate.CheckDates(Date.today().addDays(-1), Date.today());
    }
    @isTest
    static void CheckDatesFutureNotWithin30DaysTest() {
        VerifyDate.CheckDates(Date.today().addDays(+51), Date.today());
    }
}

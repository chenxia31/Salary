import Testing
import Foundation
@testable import SalaryTickerCore

@Suite("SalaryEngine 纯逻辑测试套件")
struct SalaryEngineTests {

    let sampleSettings = SalarySettings(
        monthlySalary: 21750.0,
        workDaysPerMonth: 21.75,
        workStartHour: 9,
        workStartMinute: 30,
        workEndHour: 18,
        workEndMinute: 30,
        lunchStartHour: 12,
        lunchStartMinute: 0,
        lunchEndHour: 13,
        lunchEndMinute: 30,
        isLunchPaid: false,
        isContinuous247Mode: false,
        currencySymbol: "¥",
        displayMode: .todayEarned,
        decimalPrecision: 2
    )

    @Test("计算日薪 - 法定平均计薪天数 21.75 天")
    func testDailySalary() {
        let daily = SalaryEngine.dailySalary(for: sampleSettings)
        #expect(abs(daily - 1000.0) < 0.0001)
    }

    @Test("计算单日有效工作秒数 - 午休不计薪 vs 计薪")
    func testEffectiveWorkSeconds() {
        // 09:30 ~ 18:30 共 9 小时 (32400秒)，午休 12:00 ~ 13:30 (5400秒)
        // 午休不计薪：32400 - 5400 = 27000秒 (7.5小时)
        let unpaidSeconds = SalaryEngine.effectiveWorkSeconds(for: sampleSettings)
        #expect(unpaidSeconds == 27000.0)

        var paidSettings = sampleSettings
        paidSettings.isLunchPaid = true
        let paidSeconds = SalaryEngine.effectiveWorkSeconds(for: paidSettings)
        #expect(paidSeconds == 32400.0)
    }

    @Test("计算每秒流速与时薪")
    func testRates() {
        // 每日 1000 元，27000 秒工作制 => 1000 / 27000 = 0.037037... 元/秒
        let ratePerSec = SalaryEngine.ratePerSecond(for: sampleSettings)
        #expect(abs(ratePerSec - (1000.0 / 27000.0)) < 0.00001)

        let ratePerMin = SalaryEngine.ratePerMinute(for: sampleSettings)
        #expect(abs(ratePerMin - (ratePerSec * 60.0)) < 0.00001)

        let ratePerHour = SalaryEngine.ratePerHour(for: sampleSettings)
        #expect(abs(ratePerHour - (ratePerSec * 3600.0)) < 0.00001)
    }

    @Test("上班前收入为 0，状态为等待开工")
    func testBeforeWork() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current
        let date = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!

        let earnings = SalaryEngine.calculateTodayEarnings(at: date, settings: sampleSettings, calendar: calendar)
        let status = SalaryEngine.currentWorkStatus(at: date, settings: sampleSettings, calendar: calendar)

        #expect(earnings == 0.0)
        #expect(status == .beforeWork)
    }

    @Test("上午工作时间按秒累加，状态为正在入账")
    func testMorningWorking() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current
        // 10:30: 上班 1 小时 (3600 秒)
        let date = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: Date())!

        let earnings = SalaryEngine.calculateTodayEarnings(at: date, settings: sampleSettings, calendar: calendar)
        let status = SalaryEngine.currentWorkStatus(at: date, settings: sampleSettings, calendar: calendar)
        let expected = 3600.0 * (1000.0 / 27000.0)

        #expect(abs(earnings - expected) < 0.01)
        #expect(status == .working)
    }

    @Test("午休不计薪期间金额冻结，状态为午休充电")
    func testLunchBreakUnpaid() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current
        // 12:30: 午休中间。上午已工作 09:30 ~ 12:00 = 2.5小时 (9000秒)
        let date = calendar.date(bySettingHour: 12, minute: 30, second: 0, of: Date())!

        let earnings = SalaryEngine.calculateTodayEarnings(at: date, settings: sampleSettings, calendar: calendar)
        let status = SalaryEngine.currentWorkStatus(at: date, settings: sampleSettings, calendar: calendar)
        let expected = 9000.0 * (1000.0 / 27000.0)

        #expect(abs(earnings - expected) < 0.01)
        #expect(status == .lunchBreak)
    }

    @Test("下午工作时间排除午休时长，金额连续累加")
    func testAfternoonWorking() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current
        // 15:30: 上午 2.5h (9000s) + 下午 13:30 ~ 15:30 (7200s) = 16200s
        let date = calendar.date(bySettingHour: 15, minute: 30, second: 0, of: Date())!

        let earnings = SalaryEngine.calculateTodayEarnings(at: date, settings: sampleSettings, calendar: calendar)
        let status = SalaryEngine.currentWorkStatus(at: date, settings: sampleSettings, calendar: calendar)
        let expected = 16200.0 * (1000.0 / 27000.0)

        #expect(abs(earnings - expected) < 0.01)
        #expect(status == .working)
    }

    @Test("下班后金额封顶为全额日薪，状态为今日收工")
    func testAfterWork() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current
        // 19:30: 已经下班
        let date = calendar.date(bySettingHour: 19, minute: 30, second: 0, of: Date())!

        let earnings = SalaryEngine.calculateTodayEarnings(at: date, settings: sampleSettings, calendar: calendar)
        let status = SalaryEngine.currentWorkStatus(at: date, settings: sampleSettings, calendar: calendar)
        let progress = SalaryEngine.workProgress(at: date, settings: sampleSettings, calendar: calendar)

        #expect(abs(earnings - 1000.0) < 0.0001)
        #expect(status == .afterWork)
        #expect(progress == 1.0)
    }

    @Test("24/7 全天候流速计薪模式")
    func testContinuousMode() {
        var continuousSettings = sampleSettings
        continuousSettings.isContinuous247Mode = true

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current
        let date = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!

        let status = SalaryEngine.currentWorkStatus(at: date, settings: continuousSettings, calendar: calendar)
        #expect(status == .continuous)

        let rate = SalaryEngine.ratePerSecond(for: continuousSettings, date: date, calendar: calendar)
        #expect(rate > 0)
    }

    @Test("格式化工具输出验证")
    func testFormatters() {
        let currencyStr = SalaryEngine.formatCurrency(1234.56, symbol: "¥", precision: 2)
        #expect(currencyStr == "¥ 1,234.56")

        let rateStr = SalaryEngine.formatRatePerSecond(0.0482, symbol: "¥", precision: 4)
        #expect(rateStr == "+¥0.0482/s")

        let countdown = SalaryEngine.formatRemainingCountdown(3665)
        #expect(countdown.contains("1小时1分5秒"))
    }
}

import DatalinkService from "../../..";

let REQUEST_SIZE = 0

class customEventTest {
    countDownFrom(x: number): void {
        for (let index = 1; x; index) {
            print(script.Name, x - index)

            task.wait(1)
        }
    }

    run(): boolean {
        for (let index = 1; REQUEST_SIZE; index++) {
            task.spawn(() => {
                DatalinkService.FireLogEvent(Enum.AnalyticsLogLevel.Error, "Error Message", "Error Trace").Then(() => {
                    print("Completed", index)
                })
            })
        }

        return true
    }
}

export { customEventTest }
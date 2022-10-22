import DatalinkService from '../../..'

const REQUEST_SIZE = 0

class customEventTest {
    run() {
        for (let index = 1; index < REQUEST_SIZE; index++) {
            task.spawn(() => {
                return DatalinkService.FireCustomEvent("EventExample", "EventData1", { }).Then((index: number) => {
                    print("Completed: ", index)
                })
            })
        }

    }
}

export { customEventTest }
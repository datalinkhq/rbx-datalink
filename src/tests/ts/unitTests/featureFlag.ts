import DatalinkService from '../../..'

const FAST_FLAGS = [
    "ExampleFlag"
]

class fastFlagTest {
    run() {
        FAST_FLAGS.forEach((flagname: string)=> {
            print(`Fetching ${flagname}`, DatalinkService.GetFastFlag(flagname))
        })
    }
}

export { fastFlagTest }
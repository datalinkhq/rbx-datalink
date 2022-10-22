export {};

const DEVELOPER_ID: number = 1
const DEVELOPER_GAME_KEY: string = "cc5055f0-29e1-42d4-923f-11a00760a1a8"

function runUnitModule(unitModule: { run(id: number, key: string): any, Name: string }) {
    let success, message = unitModule.run(DEVELOPER_ID, DEVELOPER_GAME_KEY)

    if (!success) {
        return warn(`[UnitTest ${unitModule.Name}]: Fail (${message})`)
    }
}


//@ts-ignore
for (let _ of script.Parent.GetChildren()) {
    task.spawn(() => {
        //@ts-ignore
        const unitModule: { run(id: number, key: string), Name: string } = require(`${_[2]}`)
        runUnitModule(unitModule)
    })
}


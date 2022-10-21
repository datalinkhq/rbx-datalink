import DatalinkService from '../../../src/index'

class authenticationTest {
    run(id: number, key: string) {
        return DatalinkService.Initialize(id, key)
    }
}

export { authenticationTest }
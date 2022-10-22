import DatalinkService from '../../..'

class authenticationTest {
    run(id: number, key: string) {
        return DatalinkService.Initialize(id, key)
    }
}

export { authenticationTest }